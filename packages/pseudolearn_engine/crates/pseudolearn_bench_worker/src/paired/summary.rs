use crate::aot::statistics::{Sampler, geometric_mean, mean, median, percentile};
use serde_json::{Value, json};
use std::collections::BTreeMap;

type Processes = Vec<Vec<(f64, f64, f64)>>;

pub fn family(workload: &str) -> Result<&'static str, String> {
    match workload {
        "sieve" | "queens" => Ok("arrays"),
        "permute" => Ok("recursive"),
        "mandelbrot" | "nbody" => Ok("numeric"),
        "towers" | "list" | "storage" | "bounce" | "richards" => Ok("objects"),
        _ => Err(format!("Unknown workload {workload}")),
    }
}

fn durations(record: &Value) -> Result<Vec<(f64, f64, f64)>, String> {
    record
        .get("pairs")
        .and_then(Value::as_array)
        .ok_or("Missing pairs")?
        .iter()
        .map(|pair| {
            let time = |field| {
                pair.get(field)
                    .and_then(Value::as_f64)
                    .ok_or_else(|| format!("Missing {field}"))
            };
            Ok((
                time("native_nanoseconds")?,
                time("ceiling_nanoseconds")?,
                time("vm_nanoseconds")?,
            ))
        })
        .collect()
}

fn processes(records: &[Value]) -> Result<BTreeMap<String, Processes>, String> {
    let mut grouped: BTreeMap<String, Processes> = BTreeMap::new();
    for record in records {
        let workload = record
            .get("workload")
            .and_then(Value::as_str)
            .ok_or("Missing workload")?;
        grouped
            .entry(workload.to_owned())
            .or_default()
            .push(durations(record)?);
    }
    Ok(grouped)
}

fn medians(processes: &Processes) -> (f64, f64, f64) {
    let native: Vec<f64> = processes.iter().flatten().map(|sample| sample.0).collect();
    let ceiling: Vec<f64> = processes.iter().flatten().map(|sample| sample.1).collect();
    let machine: Vec<f64> = processes.iter().flatten().map(|sample| sample.2).collect();
    (median(&native), median(&ceiling), median(&machine))
}

fn process_means(processes: &Processes) -> Vec<(f64, f64)> {
    processes
        .iter()
        .map(|samples| {
            let native: Vec<f64> = samples.iter().map(|sample| sample.0).collect();
            let ceiling: Vec<f64> = samples.iter().map(|sample| sample.1).collect();
            (mean(&native), mean(&ceiling))
        })
        .collect()
}

fn bootstrap_ratio(means: &[(f64, f64)], sampler: &mut Sampler) -> f64 {
    let bound = u64::try_from(means.len()).unwrap_or(1).max(1);
    let mut native = Vec::new();
    let mut ceiling = Vec::new();
    for _ in means {
        let index =
            usize::try_from(sampler.next_word().checked_rem(bound).unwrap_or(0)).unwrap_or(0);
        if let Some(pair) = means.get(index) {
            native.push(pair.0);
            ceiling.push(pair.1);
        }
    }
    mean(&native) / mean(&ceiling)
}

fn intervals(groups: &BTreeMap<String, Processes>) -> Result<BTreeMap<String, Value>, String> {
    let mut sampler = Sampler::seeded(42);
    let mut draws: BTreeMap<String, Vec<f64>> = BTreeMap::new();
    for _ in 0..2000 {
        let mut ratios: BTreeMap<String, Vec<f64>> = BTreeMap::new();
        for (workload, samples) in groups {
            ratios
                .entry(family(workload)?.to_owned())
                .or_default()
                .push(bootstrap_ratio(&process_means(samples), &mut sampler));
        }
        for (family, values) in ratios {
            draws
                .entry(family)
                .or_default()
                .push(geometric_mean(&values));
        }
    }
    Ok(draws
        .into_iter()
        .map(|(family, values)| {
            (
                family,
                json!([percentile(&values, 0.025), percentile(&values, 0.975)]),
            )
        })
        .collect())
}

pub fn summarize(records: &[Value], emissions: &Value) -> Result<Value, String> {
    super::validation::records(records)?;
    let groups = processes(records)?;
    let confidence = intervals(&groups)?;
    let mut workloads = serde_json::Map::new();
    let mut families: BTreeMap<String, Vec<f64>> = BTreeMap::new();
    let mut speedups = Vec::new();
    let mut emission_maximum = 0.0_f64;
    for (workload, samples) in groups {
        let (native, ceiling, machine) = medians(&samples);
        let family = family(&workload)?;
        families
            .entry(family.to_owned())
            .or_default()
            .push(native / ceiling);
        speedups.push(machine / native);
        let emission = emission_median(emissions, &workload)?;
        emission_maximum = emission_maximum.max(emission);
        workloads.insert(
            workload,
            json!({"family":family, "ratio":native/ceiling,
            "nativeMedianNanoseconds":native,"ceilingMedianNanoseconds":ceiling,
            "vmApiMedianNanoseconds":machine,"speedupOverVmApi":machine/native,
            "emissionMedianMilliseconds":emission}),
        );
    }
    finish(
        workloads,
        families,
        confidence,
        (&speedups, emission_maximum),
    )
}

fn finish(
    workloads: serde_json::Map<String, Value>,
    families: BTreeMap<String, Vec<f64>>,
    confidence: BTreeMap<String, Value>,
    limits: (&[f64], f64),
) -> Result<Value, String> {
    let families: BTreeMap<String, Value> = families
        .into_iter()
        .map(|(name, ratios)| {
            let ratio = geometric_mean(&ratios);
            let interval = confidence.get(&name).cloned().unwrap_or(Value::Null);
            (
                name,
                json!({"medianRatio":ratio,"passed":ratio<=1.3,
            "processMeanRatioConfidence95":interval}),
            )
        })
        .collect();
    let families_passed =
        families.len() == 4 && families.values().all(|family| family["passed"] == true);
    let speedup_passed = limits.0.iter().all(|speedup| *speedup >= 1.0);
    let emission_passed = limits.1 <= 15.0;
    Ok(json!({"workloads":workloads,"families":families,
        "criteria":{"familiesPassed":families_passed,"speedupPassed":speedup_passed,"emissionPassed":emission_passed},
        "targetReached":families_passed && speedup_passed && emission_passed,
        "maximumEmissionMedianMilliseconds":limits.1,
        "estimator":"geometric mean per family of ratios of pooled workload medians",
        "bootstrap":{"method":"paired resampling of per-process means; interval does not estimate median ratios", "rounds":2000,"seed":42}}))
}

fn emission_median(emissions: &Value, workload: &str) -> Result<f64, String> {
    let times: Vec<f64> =
        serde_json::from_value(emissions.get(workload).cloned().ok_or("Missing emission")?)
            .map_err(|error| error.to_string())?;
    if times.len() != 30 || times.iter().any(|time| !time.is_finite() || *time <= 0.0) {
        return Err("Invalid emission samples".to_owned());
    }
    Ok(median(&times))
}
