use pseudolearn_aot_rt::EntryFunction;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Configuration {
    pub workload: String,
    pub source: String,
    pub size: i64,
    pub input: String,
    pub expected: String,
    pub metadata: Vec<u8>,
    pub process: u32,
    pub iterations: u32,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Pair {
    pub iteration: u32,
    pub native_first: bool,
    pub native_nanoseconds: u64,
    pub ceiling_nanoseconds: u64,
    pub vm_nanoseconds: u64,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub telemetry: Option<serde_json::Value>,
}

pub fn native_first(process: u32, iteration: u32) -> bool {
    process.wrapping_add(iteration) & 1 == 0
}

pub fn measure(entry: EntryFunction, configuration: &Configuration) -> Result<Vec<Pair>, String> {
    if configuration.iterations == 0 || configuration.iterations > 100_000 {
        return Err("Invalid iteration count".to_owned());
    }
    let request = pseudolearn_api::ExecuteRequest {
        program: configuration.source.clone(),
        inputs: configuration.input.lines().map(str::to_owned).collect(),
        ..Default::default()
    };
    let prepared = pseudolearn_api::prepare_program(&request)
        .map_err(|errors| format!("VM preparation failed: {errors:?}"))?;
    let mut pairs = Vec::new();
    for iteration in 0..configuration.iterations {
        let first = native_first(configuration.process, iteration);
        let (native, ceiling) = if first {
            (
                crate::execution::native(entry, configuration)?,
                crate::execution::ceiling(configuration)?,
            )
        } else {
            let ceiling = crate::execution::ceiling(configuration)?;
            (crate::execution::native(entry, configuration)?, ceiling)
        };
        pairs.push(Pair {
            iteration,
            native_first: first,
            native_nanoseconds: native.0,
            telemetry: native.1,
            ceiling_nanoseconds: ceiling,
            vm_nanoseconds: crate::execution::machine(
                &prepared,
                &request,
                &configuration.expected,
            )?,
        });
    }
    Ok(pairs)
}
