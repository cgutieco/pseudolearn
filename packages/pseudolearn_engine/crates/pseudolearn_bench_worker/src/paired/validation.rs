use serde_json::Value;
use std::collections::BTreeSet;

pub fn pairs(samples: &[Value], process: u32) -> Result<(), String> {
    if samples.len() != 30 {
        return Err("Expected thirty paired samples".to_owned());
    }
    let mut seen = BTreeSet::new();
    for sample in samples {
        let iteration = sample
            .get("iteration")
            .and_then(Value::as_u64)
            .ok_or("Missing iteration")?;
        if iteration >= 30 || !seen.insert(iteration) {
            return Err("Duplicate or out-of-range iteration".to_owned());
        }
        let expected_order = (u64::from(process).wrapping_add(iteration) & 1) == 0;
        if sample.get("native_first").and_then(Value::as_bool) != Some(expected_order) {
            return Err("Unexpected pair order".to_owned());
        }
        for field in [
            "native_nanoseconds",
            "ceiling_nanoseconds",
            "vm_nanoseconds",
        ] {
            if sample
                .get(field)
                .and_then(Value::as_u64)
                .is_none_or(|time| time == 0)
            {
                return Err(format!("Invalid duration: {field}"));
            }
        }
    }
    Ok(())
}

pub fn records(records: &[Value]) -> Result<(), String> {
    if records.len() != 100 {
        return Err("Expected ten processes for ten workloads".to_owned());
    }
    let mut seen = BTreeSet::new();
    for record in records {
        let workload = record
            .get("workload")
            .and_then(Value::as_str)
            .ok_or("Missing workload")?;
        super::summary::family(workload)?;
        let process = record
            .get("process")
            .and_then(Value::as_u64)
            .ok_or("Missing process")?;
        if process >= 10 || !seen.insert((workload, process)) {
            return Err("Duplicate or out-of-range process".to_owned());
        }
        pairs(
            record
                .get("pairs")
                .and_then(Value::as_array)
                .ok_or("Missing pairs")?,
            u32::try_from(process).map_err(|error| error.to_string())?,
        )?;
    }
    Ok(())
}
