use pseudolearn_runtime::CollectionPolicy;
use pseudolearn_vm::{Fuel, RunExit, RunOptions, run_with_options};
use serde_json::Value;

pub(super) fn verify(fixtures: &Value) -> Result<(), String> {
    let scenarios = fixtures
        .get("memory")
        .and_then(Value::as_array)
        .ok_or("Missing generated memory scenarios")?;
    if scenarios.len()
        != fixtures
            .get("samples")
            .and_then(Value::as_u64)
            .and_then(|count| usize::try_from(count).ok())
            .ok_or("Missing sample count")?
    {
        return Err("Incomplete memory fixtures".to_owned());
    }
    for scenario in scenarios {
        for (profile, field) in [("es", "program"), ("en", "english")] {
            for strictness in ["strict", "flexible"] {
                check(scenario, (profile, field, strictness))?;
            }
        }
    }
    println!(
        "Memory oracle: {} generated programs, two profiles, two strictness modes, three collection policies",
        scenarios.len()
    );
    Ok(())
}

fn check(scenario: &Value, (profile, field, strictness): (&str, &str, &str)) -> Result<(), String> {
    let source = scenario
        .get(field)
        .and_then(Value::as_str)
        .ok_or("Missing generated program")?;
    let expected = scenario
        .get("expectedCells")
        .and_then(Value::as_u64)
        .ok_or("Missing cell expectation")?;
    let loaded = super::compile(source, profile, strictness)?;
    let mut previous = None;
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let mut options = RunOptions::default();
        options.inspect_memory = true;
        options.memory.collection = collection;
        let result = run_with_options(
            &loaded,
            Fuel {
                statements: 100000,
                probes: 100000,
            },
            options,
        );
        if !matches!(result.exit, RunExit::Completed(_)) || result.output != "ok\n" {
            return Err(format!(
                "Generated memory program failed: {scenario}; {result:?}"
            ));
        }
        let count = result
            .memory_counts
            .iter()
            .rev()
            .find(|count| count.function == "@main")
            .ok_or("Missing main allocation count")?;
        if count.cells != expected {
            return Err(format!(
                "Cell oracle mismatch: expected {expected}, actual {}; scenario {scenario}",
                count.cells
            ));
        }
        if previous
            .as_ref()
            .is_some_and(|previous| *previous != result)
        {
            return Err(format!("Collection changed execution: {scenario}"));
        }
        previous = Some(result);
    }
    Ok(())
}
