use pseudolearn_api::{ExecuteRequest, execute_program};

#[cfg(feature = "native")]
#[test]
fn native_build_rejects_each_new_numeric_operation_explicitly() {
    for (expression, operation) in [
        ("tan(1.0)", "math.tan"),
        ("asin(0.5)", "math.asin"),
        ("acos(0.5)", "math.acos"),
        ("atan2(1.0,2.0)", "math.atan2"),
        ("log2(3.0)", "math.log2"),
        ("log10(3.0)", "math.log10"),
        ("floor(1.5)", "real.floor"),
        ("ceil(1.5)", "real.ceil"),
        ("min(1.0,2.0)", "real.min"),
        ("max(1.0,2.0)", "real.max"),
        ("min(1,2)", "int.min"),
        ("max(1,2)", "int.max"),
    ] {
        let request = pseudolearn_api::conformance_build_request(&ExecuteRequest {
            program: format!("algorithm P\nwrite {expression};\nendAlgorithm\n"),
            profile: "en".to_owned(),
            ..Default::default()
        });
        let result = pseudolearn_api::build_native_object(&request);
        assert!(
            matches!(&result, Err(pseudolearn_api::NativeBuildFailure::Backend(message)) if message.contains(operation)),
            "{expression}: {result:?}"
        );
    }
}

#[test]
fn numeric_extensions_match_the_normative_cases() -> Result<(), String> {
    for source in [
        include_str!("../../../../pseudolearn_spec/specifications/lib/lib.core.math.md"),
        include_str!("../../../../pseudolearn_spec/specifications/lib/lib.core.rounding.md"),
    ] {
        for block in source.split("```caso\n").skip(1) {
            let case: serde_json::Value =
                serde_json::from_str(block.split("\n```").next().ok_or("missing case")?)
                    .map_err(|error| error.to_string())?;
            if case
                .get("operacion")
                .and_then(serde_json::Value::as_str)
                .unwrap_or("")
                != "execute"
            {
                continue;
            }
            for (profile, program) in case
                .get("programas")
                .and_then(serde_json::Value::as_object)
                .ok_or("missing programs")?
            {
                let result = execute_program(&ExecuteRequest {
                    program: program.as_str().ok_or("missing program")?.to_owned(),
                    profile: profile.clone(),
                    ..Default::default()
                });
                if let Some(code) = case
                    .pointer("/espera/fallo/codigo")
                    .and_then(serde_json::Value::as_str)
                {
                    assert!(
                        result
                            .diagnostics
                            .iter()
                            .any(|diagnostic| diagnostic.code == code),
                        "{:?}: {:?}",
                        case.get("id"),
                        result.diagnostics
                    );
                } else {
                    assert_eq!(
                        result.output,
                        case.pointer("/espera/salida")
                            .and_then(serde_json::Value::as_str)
                            .unwrap_or(""),
                        "{:?}: {:?}",
                        case.get("id"),
                        result.diagnostics
                    );
                }
            }
        }
    }
    Ok(())
}
