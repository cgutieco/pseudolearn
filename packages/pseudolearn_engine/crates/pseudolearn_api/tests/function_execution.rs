use pseudolearn_api::{ExecuteRequest, execute_program};
use serde_json::Value;

#[cfg(feature = "native")]
#[path = "native_access/support.rs"]
mod native_support;

struct Example {
    identity: String,
    profile: String,
    program: String,
    output: String,
}

fn examples() -> Result<Vec<Example>, String> {
    let source =
        include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.function.md");
    let mut examples = Vec::new();
    for block in source.split("```caso\n").skip(1) {
        let json = block.split("\n```").next().ok_or("missing case")?;
        let case: Value = serde_json::from_str(json).map_err(|error| error.to_string())?;
        if case.get("operacion").and_then(Value::as_str) != Some("execute") {
            continue;
        }
        let programs = case
            .get("programas")
            .and_then(Value::as_object)
            .ok_or("missing programs")?;
        for (profile, program) in programs {
            examples.push(Example {
                identity: case
                    .get("id")
                    .and_then(Value::as_str)
                    .ok_or("missing identity")?
                    .to_owned(),
                profile: profile.clone(),
                program: program.as_str().ok_or("invalid program")?.to_owned(),
                output: case
                    .pointer("/espera/salida")
                    .and_then(Value::as_str)
                    .ok_or("missing output")?
                    .to_owned(),
            });
        }
    }
    Ok(examples)
}

#[test]
fn closures_preserve_normative_results_with_collection_in_both_twins() -> Result<(), String> {
    for example in examples()? {
        for observe in ["none", "events"] {
            let mut request = ExecuteRequest {
                program: example.program.clone(),
                profile: example.profile.clone(),
                observe: observe.to_owned(),
                ..Default::default()
            };
            let normal = execute_program(&request);
            assert_eq!(
                normal.output, example.output,
                "{}: {:?}",
                example.identity, normal.diagnostics
            );
            assert_eq!(
                normal.termination.get("kind").and_then(Value::as_str),
                Some("completed"),
                "{}: {:?}",
                example.identity,
                normal.termination
            );
            request.gc_stress = true;
            let forced = execute_program(&request);
            assert_eq!(forced.output, normal.output, "{}", example.identity);
            assert_eq!(
                forced.termination, normal.termination,
                "{}",
                example.identity
            );
            assert_eq!(
                forced.diagnostics, normal.diagnostics,
                "{}",
                example.identity
            );
            assert_eq!(forced.events, normal.events, "{}", example.identity);
        }
    }
    Ok(())
}

#[cfg(feature = "native")]
#[test]
fn native_closures_match_vm_with_forced_collection() -> Result<(), String> {
    for example in examples()? {
        if example.profile == "es" {
            native_support::compare(&example.program)?;
        } else {
            let request = ExecuteRequest {
                program: example.program,
                profile: example.profile,
                gc_stress: true,
                ..Default::default()
            };
            let object = pseudolearn_api::build_native_object(
                &pseudolearn_api::conformance_build_request(&request),
            )
            .map_err(|error| format!("{error:?}"))?;
            let actual = native_support::run_object(&request, object)?;
            assert_eq!(
                actual.output, example.output,
                "{}: {:?}",
                example.identity, actual.diagnostics
            );
            assert_eq!(
                actual.termination.get("kind").and_then(Value::as_str),
                Some("completed"),
                "{}: {:?}",
                example.identity,
                actual.termination
            );
        }
    }
    Ok(())
}
