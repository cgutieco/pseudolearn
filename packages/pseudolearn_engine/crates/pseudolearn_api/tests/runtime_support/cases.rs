use pseudolearn_runtime::{CollectionPolicy, MemoryOptions};
use pseudolearn_vm::{Fuel, RunExit, RunOptions, run_with_options};
use serde_json::Value;

pub(super) fn verify(fixtures: &Value) -> Result<(), String> {
    let mut checked = 0_usize;
    let mut failures = Vec::new();
    for case in fixtures
        .get("cases")
        .and_then(Value::as_array)
        .ok_or("Missing cases")?
    {
        let identity = case
            .get("specification")
            .and_then(Value::as_str)
            .ok_or("Missing specification")?;
        let request = case.get("request").ok_or("Missing request")?;
        if !selected(identity)
            || request
                .get("inputs")
                .and_then(Value::as_array)
                .is_some_and(|inputs| !inputs.is_empty())
            || request.pointer("/limits/statements").is_some()
        {
            continue;
        }
        checked = checked.saturating_add(1);
        if let Err(error) = check(case) {
            failures.push(format!(
                "{identity}#{}: {error}",
                case.get("case").unwrap_or(&Value::Null)
            ));
        }
    }
    if checked < 100 {
        return Err("Insufficient runtime corpus coverage".to_owned());
    }
    println!(
        "Runtime corpus: {checked} profile/strictness configurations, three collection policies"
    );
    if !failures.is_empty() {
        return Err(format!(
            "{} runtime failures:\n{}",
            failures.len(),
            failures.join("\n")
        ));
    }
    Ok(())
}

fn selected(identity: &str) -> bool {
    [
        "LANG.ARRAY.",
        "LANG.SUBPROGRAM.",
        "LANG.CLASS.",
        "LIB.CORE.TEXT",
        "LIB.CORE.CONVERSION",
        "LIB.CORE.COPY",
        "LIB.CORE.RANDOM",
        "MEM.",
        "RT.HOST.INTERFACE",
        "LANG.TYPES.TEXT",
        "LANG.TYPES.ARRAY",
        "LANG.OPS.CONCATENATION",
        "LANG.IO.VALUE-FORMAT",
        "ENG.LIMITS",
    ]
    .iter()
    .any(|prefix| identity.starts_with(prefix))
}

fn check(case: &Value) -> Result<(), String> {
    let request = case.get("request").ok_or("Missing request")?;
    let source = request
        .get("program")
        .and_then(Value::as_str)
        .ok_or("Missing program")?;
    let profile = request
        .get("profile")
        .and_then(Value::as_str)
        .ok_or("Missing profile")?;
    let strictness = request
        .get("strictness")
        .and_then(Value::as_str)
        .ok_or("Missing strictness")?;
    let loaded = super::compile(source, profile, strictness)?;
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let options = RunOptions {
            seed: request.get("seed").and_then(Value::as_i64).unwrap_or(42),
            depth: request
                .pointer("/limits/depth")
                .and_then(Value::as_u64)
                .and_then(|depth| usize::try_from(depth).ok())
                .unwrap_or(1000),
            memory: MemoryOptions {
                collection_minimum: 4096,
                cells: request
                    .pointer("/limits/cells")
                    .and_then(Value::as_u64)
                    .unwrap_or(1 << 22),
                collection,
            },
            ..RunOptions::default()
        };
        let result = run_with_options(
            &loaded,
            Fuel {
                statements: 100000,
                probes: 100000,
            },
            options,
        );
        compare(case.get("expected").ok_or("Missing expectation")?, &result)?;
    }
    Ok(())
}

fn compare(expected: &Value, result: &pseudolearn_vm::RunResult) -> Result<(), String> {
    if let Some(output) = expected.get("salida").and_then(Value::as_str)
        && output != result.output
    {
        return Err(format!(
            "Output {:?}, expected {:?}; exit {:?}",
            result.output, output, result.exit
        ));
    }
    if let RunExit::Trap(trap) = &result.exit {
        super::diagnostics::verify(expected, trap)?;
    }
    let failure = expected.pointer("/fallo/codigo").and_then(Value::as_str);
    match (&result.exit, failure) {
        (RunExit::Completed(_), None) => Ok(()),
        (RunExit::Trap(trap), Some(code)) if trap.code == code => Ok(()),
        _ => Err(format!(
            "Exit {:?}, expected failure {failure:?}",
            result.exit
        )),
    }
}
