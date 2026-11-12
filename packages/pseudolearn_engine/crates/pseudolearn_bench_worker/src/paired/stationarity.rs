use crate::aot::statistics::{count_to_float, mean};
use serde_json::{Value, json};

fn variance(values: &[f64]) -> f64 {
    let average = mean(values);
    values
        .iter()
        .map(|value| (value - average).powi(2))
        .sum::<f64>()
        / count_to_float(values.len().saturating_sub(1))
}

pub fn analyze(records: &[Value]) -> Result<Value, String> {
    let mut candidates = Vec::new();
    for record in records {
        for field in [
            "native_nanoseconds",
            "ceiling_nanoseconds",
            "vm_nanoseconds",
        ] {
            let values = record["pairs"]
                .as_array()
                .ok_or("Missing pairs")?
                .iter()
                .map(|pair| pair[field].as_f64().ok_or("Missing time".to_owned()))
                .collect::<Result<Vec<_>, _>>()?;
            for split in 5..=values.len().saturating_sub(5) {
                let left = values.get(..split).ok_or("Invalid split")?;
                let right = values.get(split..).ok_or("Invalid split")?;
                let difference = (mean(left) - mean(right)).abs();
                let error = (variance(left) / count_to_float(left.len())
                    + variance(right) / count_to_float(right.len()))
                .sqrt();
                let candidate = difference > mean(left).abs() * 0.05 && difference > 3.3 * error;
                candidates.extend(candidate.then(||json!({"workload":record["workload"],"process":record["process"],"metric":field,"split":split})));
            }
        }
    }
    Ok(
        json!({"stationarityDemonstrated":false,"samplesDiscarded":0,"changePointCandidates":candidates}),
    )
}
