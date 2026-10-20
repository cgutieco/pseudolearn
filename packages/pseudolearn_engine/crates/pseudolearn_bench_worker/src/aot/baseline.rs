use serde_json::Value;
use std::collections::BTreeMap;
use std::path::Path;

const V1F_VARIANT: u64 = 4;

pub struct Reference {
    pub family: String,
    pub v1f_process_means: Vec<f64>,
    pub vm_microseconds: f64,
}

pub fn load(
    ceiling_path: &Path,
    machine_path: &Path,
) -> Result<BTreeMap<String, Reference>, String> {
    let ceiling = read(ceiling_path)?;
    let machine = read(machine_path)?;
    parse(&ceiling, &machine)
}

fn read(path: &Path) -> Result<Value, String> {
    let text =
        std::fs::read_to_string(path).map_err(|error| format!("{}: {error}", path.display()))?;
    serde_json::from_str(&text).map_err(|error| format!("{}: {error}", path.display()))
}

pub fn parse(ceiling: &Value, machine: &Value) -> Result<BTreeMap<String, Reference>, String> {
    let records = ceiling.as_array().ok_or("Ceiling samples are not a list")?;
    let mut sums: BTreeMap<(String, u64), (f64, u32)> = BTreeMap::new();
    let mut families = BTreeMap::new();
    for record in records {
        if record.get("variant").and_then(Value::as_u64) != Some(V1F_VARIANT) {
            continue;
        }
        let workload = text_of(record, "workload")?;
        let process = record
            .get("process")
            .and_then(Value::as_u64)
            .ok_or("Ceiling sample without process")?;
        let nanoseconds = record
            .get("nanoseconds")
            .and_then(Value::as_f64)
            .ok_or("Ceiling sample without time")?;
        families.insert(workload.clone(), text_of(record, "family")?);
        let entry = sums.entry((workload, process)).or_insert((0.0, 0));
        entry.0 += nanoseconds;
        entry.1 = entry.1.saturating_add(1);
    }
    references(&sums, &families, machine)
}

fn references(
    sums: &BTreeMap<(String, u64), (f64, u32)>,
    families: &BTreeMap<String, String>,
    machine: &Value,
) -> Result<BTreeMap<String, Reference>, String> {
    let mut references = BTreeMap::new();
    for (workload, family) in families {
        let means: Vec<f64> = sums
            .iter()
            .filter(|((name, _), _)| name == workload)
            .map(|(_, (total, count))| total / f64::from(*count))
            .collect();
        let vm_microseconds = machine
            .pointer(&format!(
                "/measurements/native~1{workload}~1false/meanWallMicroseconds"
            ))
            .and_then(Value::as_f64)
            .ok_or_else(|| format!("Missing virtual machine baseline for {workload}"))?;
        references.insert(
            workload.clone(),
            Reference {
                family: family.clone(),
                v1f_process_means: means,
                vm_microseconds,
            },
        );
    }
    Ok(references)
}

fn text_of(record: &Value, name: &str) -> Result<String, String> {
    record
        .get(name)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("Ceiling sample without {name}"))
}
