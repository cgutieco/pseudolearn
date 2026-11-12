use super::baseline::Reference;
use super::statistics::{Sampler, geometric_mean, mean, median, percentile};
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub const FAMILY_THRESHOLD: f64 = 1.30;
pub const EMISSION_THRESHOLD_MILLISECONDS: f64 = 15.0;
pub const BOOTSTRAP_ROUNDS: usize = 2000;
pub const BOOTSTRAP_SEED: u64 = 42;

pub struct Sample {
    pub workload: String,
    pub process: u32,
    pub nanoseconds: f64,
}

pub struct SummaryInput<'input> {
    pub samples: &'input [Sample],
    pub references: &'input BTreeMap<String, Reference>,
    pub emission_milliseconds: &'input BTreeMap<String, f64>,
}

struct WorkloadResult<'input> {
    name: &'input str,
    reference: &'input Reference,
    native_means: Vec<f64>,
    emission_milliseconds: f64,
}

impl WorkloadResult<'_> {
    fn native_nanoseconds(&self) -> f64 {
        mean(&self.native_means)
    }

    fn ceiling_nanoseconds(&self) -> f64 {
        mean(&self.reference.v1f_process_means)
    }

    fn ratio(&self) -> f64 {
        self.native_nanoseconds() / self.ceiling_nanoseconds()
    }

    fn speedup_over_machine(&self) -> f64 {
        self.reference.vm_microseconds * 1000.0 / self.native_nanoseconds()
    }

    fn bootstrap_ratio(&self, sampler: &mut Sampler) -> f64 {
        let native = mean(&sampler.resample(&self.native_means));
        let ceiling = mean(&sampler.resample(&self.reference.v1f_process_means));
        native / ceiling
    }
}

fn native_process_means(samples: &[Sample], workload: &str) -> Vec<f64> {
    let mut sums: BTreeMap<u32, (f64, u32)> = BTreeMap::new();
    for sample in samples.iter().filter(|sample| sample.workload == workload) {
        let entry = sums.entry(sample.process).or_insert((0.0, 0));
        entry.0 += sample.nanoseconds;
        entry.1 = entry.1.saturating_add(1);
    }
    sums.values()
        .map(|(total, count)| total / f64::from(*count))
        .collect()
}

fn workload_results<'input>(
    input: &'input SummaryInput<'input>,
) -> Result<Vec<WorkloadResult<'input>>, String> {
    input
        .references
        .iter()
        .map(|(name, reference)| {
            let native_means = native_process_means(input.samples, name);
            if native_means.is_empty() || reference.v1f_process_means.is_empty() {
                return Err(format!("No samples for {name}"));
            }
            Ok(WorkloadResult {
                name,
                reference,
                native_means,
                emission_milliseconds: *input
                    .emission_milliseconds
                    .get(name)
                    .ok_or_else(|| format!("No emission time for {name}"))?,
            })
        })
        .collect()
}

struct Intervals {
    workloads: BTreeMap<String, (f64, f64)>,
    families: BTreeMap<String, (f64, f64)>,
}

fn family_ratio(results: &[&WorkloadResult<'_>], ratios: &BTreeMap<&str, f64>) -> f64 {
    let values: Vec<f64> = results
        .iter()
        .filter_map(|result| ratios.get(result.name).copied())
        .collect();
    geometric_mean(&values)
}

fn group_by_family<'results, 'input>(
    results: &'results [WorkloadResult<'input>],
) -> BTreeMap<&'input str, Vec<&'results WorkloadResult<'input>>> {
    let mut families: BTreeMap<&str, Vec<&WorkloadResult<'_>>> = BTreeMap::new();
    for result in results {
        families
            .entry(result.reference.family.as_str())
            .or_default()
            .push(result);
    }
    families
}

fn bootstrap(results: &[WorkloadResult<'_>]) -> Intervals {
    let mut sampler = Sampler::seeded(BOOTSTRAP_SEED);
    let families = group_by_family(results);
    let mut workload_draws: BTreeMap<&str, Vec<f64>> = BTreeMap::new();
    let mut family_draws: BTreeMap<&str, Vec<f64>> = BTreeMap::new();
    for _ in 0..BOOTSTRAP_ROUNDS {
        let ratios: BTreeMap<&str, f64> = results
            .iter()
            .map(|result| (result.name, result.bootstrap_ratio(&mut sampler)))
            .collect();
        for (name, ratio) in &ratios {
            workload_draws.entry(name).or_default().push(*ratio);
        }
        for (family, members) in &families {
            family_draws
                .entry(family)
                .or_default()
                .push(family_ratio(members, &ratios));
        }
    }
    Intervals {
        workloads: interval_of(&workload_draws),
        families: interval_of(&family_draws),
    }
}

fn interval_of(draws: &BTreeMap<&str, Vec<f64>>) -> BTreeMap<String, (f64, f64)> {
    draws
        .iter()
        .map(|(name, values)| {
            (
                (*name).to_owned(),
                (percentile(values, 0.025), percentile(values, 0.975)),
            )
        })
        .collect()
}

fn workload_json(result: &WorkloadResult<'_>, interval: (f64, f64)) -> Value {
    json!({
        "family": result.reference.family,
        "processes": result.native_means.len(),
        "nativeNanoseconds": result.native_nanoseconds(),
        "ceilingNanoseconds": result.ceiling_nanoseconds(),
        "machineMicroseconds": result.reference.vm_microseconds,
        "ratio": result.ratio(),
        "confidence95": [interval.0, interval.1],
        "speedupOverMachine": result.speedup_over_machine(),
        "emissionMilliseconds": result.emission_milliseconds,
    })
}

fn family_json(ratio: f64, interval: (f64, f64)) -> Value {
    json!({
        "ratio": ratio,
        "confidence95": [interval.0, interval.1],
        "passed": ratio <= FAMILY_THRESHOLD,
    })
}

pub fn summarize(input: &SummaryInput<'_>) -> Result<Value, String> {
    let results = workload_results(input)?;
    let intervals = bootstrap(&results);
    let mut workloads = serde_json::Map::new();
    for result in &results {
        let interval = intervals
            .workloads
            .get(result.name)
            .copied()
            .unwrap_or_default();
        workloads.insert(result.name.to_owned(), workload_json(result, interval));
    }
    let ratios: BTreeMap<&str, f64> = results
        .iter()
        .map(|result| (result.name, result.ratio()))
        .collect();
    let mut families = serde_json::Map::new();
    for (family, members) in group_by_family(&results) {
        let interval = intervals.families.get(family).copied().unwrap_or_default();
        families.insert(
            family.to_owned(),
            family_json(family_ratio(&members, &ratios), interval),
        );
    }
    Ok(conclusions(
        &results,
        workloads,
        families,
        input.samples.len(),
    ))
}

fn emission_times(results: &[WorkloadResult<'_>]) -> Vec<f64> {
    results
        .iter()
        .map(|result| result.emission_milliseconds)
        .collect()
}

fn conclusions(
    results: &[WorkloadResult<'_>],
    workloads: serde_json::Map<String, Value>,
    families: serde_json::Map<String, Value>,
    samples: usize,
) -> Value {
    let speedups: Vec<f64> = results
        .iter()
        .map(WorkloadResult::speedup_over_machine)
        .collect();
    let emissions = emission_times(results);
    let ratios: Vec<f64> = results.iter().map(WorkloadResult::ratio).collect();
    let families_passed = families
        .values()
        .all(|family| family.get("passed") == Some(&json!(true)));
    let minimum_speedup = speedups.iter().copied().fold(f64::INFINITY, f64::min);
    let emission_median = median(&emissions);
    let emission_maximum = emissions.iter().copied().fold(0.0, f64::max);
    let speedup_passed = minimum_speedup >= 1.0;
    let emission_passed = emission_maximum <= EMISSION_THRESHOLD_MILLISECONDS;
    json!({
        "workloads": workloads,
        "families": families,
        "geometricMeanRatio": geometric_mean(&ratios),
        "geometricMeanSpeedupOverMachine": geometric_mean(&speedups),
        "minimumSpeedupOverMachine": minimum_speedup,
        "emissionMedianMilliseconds": emission_median,
        "emissionMaximumMilliseconds": emission_maximum,
        "criteria": {
            "familiesPassed": families_passed,
            "speedupPassed": speedup_passed,
            "emissionPassed": emission_passed,
        },
        "targetReached": families_passed && speedup_passed && emission_passed,
        "samples": samples,
        "bootstrap": bootstrap_description(),
    })
}

fn bootstrap_description() -> Value {
    json!({
        "rounds": BOOTSTRAP_ROUNDS,
        "seed": BOOTSTRAP_SEED,
        "method": "independent resampling of per-process means",
    })
}
