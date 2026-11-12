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
    failure: Option<String>,
}

impl Example {
    fn expected_kind(&self) -> &'static str {
        if self.failure.is_some() {
            "failed"
        } else {
            "completed"
        }
    }
}

const GENERIC: &str =
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.generic.md");
const VARIANT: &str =
    include_str!("../../../../pseudolearn_spec/specifications/lang/lang.types.variant.md");

fn examples(source: &str) -> Result<Vec<Example>, String> {
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
                failure: case
                    .pointer("/espera/fallo/codigo")
                    .and_then(Value::as_str)
                    .map(str::to_owned),
            });
        }
    }
    Ok(examples)
}

#[test]
fn generic_instances_preserve_normative_results_with_collection_in_both_twins() -> Result<(), String>
{
    twins(GENERIC)
}

#[test]
fn declared_variants_preserve_normative_results_with_collection_in_both_twins() -> Result<(), String>
{
    twins(VARIANT)
}

fn twins(source: &str) -> Result<(), String> {
    for example in examples(source)? {
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
                Some(example.expected_kind()),
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
fn native_generic_instances_match_vm_with_forced_collection() -> Result<(), String> {
    for example in examples(GENERIC)? {
        let expected_kind = example.expected_kind();
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
                Some(expected_kind),
                "{}: {:?}",
                example.identity,
                actual.termination
            );
        }
    }
    Ok(())
}

#[test]
fn each_class_instance_lowers_to_its_own_verified_class() -> Result<(), String> {
    let program = "class Box<T>\ndefine content as T;\nmethod current() as T\nreturn this.content;\nendMethod\nendClass\nalgorithm P\ndefine a as Box<integer> <- new Box<integer>();\ndefine b as Box<string> <- new Box<string>();\na.content <- 1;\nb.content <- \"xy\";\nwrite a.current(), b.current();\nendAlgorithm\n";
    let module = pseudolearn_api::compile_source_to_module(program, "en")
        .map_err(|errors| format!("{errors:?}"))?;
    pseudolearn_ir::verify_module(&module).map_err(|error| format!("{error:?}"))?;
    let text = pseudolearn_ir::print_canonical(&module);
    for name in ["Box<integer>", "Box<string>"] {
        assert!(text.contains(name), "{name}\n{text}");
    }
    assert!(!text.contains("Box<T>"), "{text}");
    let reparsed = pseudolearn_ir::parse_module(&text)?;
    pseudolearn_ir::verify_module(&reparsed).map_err(|error| format!("{error:?}"))?;
    assert_eq!(pseudolearn_ir::print_canonical(&reparsed), text);
    Ok(())
}
