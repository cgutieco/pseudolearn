use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::Value;

#[cfg(feature = "native")]
#[path = "native_access/support.rs"]
mod native_support;

const SOURCES: &[&str] = &[
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.interface.md"),
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.vector.md"),
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.dictionary.md"),
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.control.for-each.md"),
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.control.exit.md"),
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.control.cleanup.md"),
];

fn cases() -> Result<Vec<Value>, String> {
    SOURCES
        .iter()
        .flat_map(|source| source.split("```caso\n").skip(1))
        .map(|block| {
            serde_json::from_str(block.split("\n```").next().ok_or("missing case")?)
                .map_err(|error| error.to_string())
        })
        .collect()
}

fn requests(case: &Value) -> Result<Vec<ExecuteRequest>, String> {
    let programs = case
        .get("programas")
        .and_then(Value::as_object)
        .ok_or("missing programs")?;
    let mut requests = Vec::new();
    for (profile, program) in programs {
        for strictness in ["estricto", "flexible"] {
            requests.push(ExecuteRequest {
                program: program.as_str().ok_or("invalid program")?.to_owned(),
                profile: profile.clone(),
                strictness: strictness.to_owned(),
                host: case.get("anfitrion").cloned(),
                ..Default::default()
            });
        }
    }
    Ok(requests)
}

fn expected_output<'case>(case: &'case Value, profile: &str) -> &'case str {
    case.pointer(&format!("/esperas/{profile}/salida"))
        .or_else(|| case.pointer("/espera/salida"))
        .and_then(Value::as_str)
        .unwrap_or("")
}

#[test]
fn collections_and_cleanup_match_the_corpus_with_both_twins_and_forced_collection()
-> Result<(), String> {
    for case in cases()?
        .iter()
        .filter(|case| case.get("operacion").and_then(Value::as_str) == Some("execute"))
    {
        for mut request in requests(case)? {
            for observe in ["none", "events"] {
                request.observe = observe.to_owned();
                request.gc_stress = false;
                let normal = execute_program(&request);
                assert_eq!(
                    normal.output,
                    expected_output(case, &request.profile),
                    "{}: {:?}",
                    case["id"],
                    normal.diagnostics
                );
                if let Some(expected) = case.pointer("/espera/fallo/codigo").and_then(Value::as_str)
                {
                    assert!(
                        normal
                            .diagnostics
                            .iter()
                            .any(|diagnostic| diagnostic.code == expected),
                        "{}: {:?}",
                        case["id"],
                        normal.diagnostics
                    );
                } else {
                    assert_eq!(
                        normal.termination.get("kind").and_then(Value::as_str),
                        Some("completed"),
                        "{}: {:?}",
                        case["id"],
                        normal.diagnostics
                    );
                }
                request.gc_stress = true;
                let forced = execute_program(&request);
                assert_eq!(
                    forced.output,
                    normal.output,
                    "{} {} {} {}: {:?} {:?}",
                    case["id"],
                    request.profile,
                    request.strictness,
                    observe,
                    forced.termination,
                    forced.diagnostics
                );
                assert_eq!(forced.termination, normal.termination, "{}", case["id"]);
                assert_eq!(forced.diagnostics, normal.diagnostics, "{}", case["id"]);
                assert_eq!(forced.events, normal.events, "{}", case["id"]);
            }
        }
    }
    Ok(())
}

#[cfg(feature = "native")]
#[test]
fn native_collections_and_cleanup_match_vm() -> Result<(), String> {
    for case in cases()?
        .iter()
        .filter(|case| case.get("operacion").and_then(Value::as_str) == Some("execute"))
    {
        let program = case
            .pointer("/programas/es")
            .and_then(Value::as_str)
            .ok_or("missing program")?;
        if program.contains("Tareas") {
            continue;
        }
        native_support::compare(program)?;
    }
    Ok(())
}
