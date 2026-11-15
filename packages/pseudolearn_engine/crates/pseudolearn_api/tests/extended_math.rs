use pseudolearn_api::{ExecuteRequest, execute_program};

#[cfg(feature = "native")]
#[test]
fn native_build_compiles_each_new_numeric_operation() {
    for expression in [
        "tan(1.0)",
        "asin(0.5)",
        "acos(0.5)",
        "atan2(1.0,2.0)",
        "log2(3.0)",
        "log10(3.0)",
        "floor(1.5)",
        "ceil(1.5)",
        "min(1.0,2.0)",
        "max(1.0,2.0)",
        "min(1,2)",
        "max(1,2)",
    ] {
        let request = pseudolearn_api::conformance_build_request(&ExecuteRequest {
            program: format!("algorithm P\nwrite {expression};\nendAlgorithm\n"),
            profile: "en".to_owned(),
            ..Default::default()
        });
        let result = pseudolearn_api::build_native_object(&request);
        assert!(result.is_ok(), "{expression}: {result:?}");
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
