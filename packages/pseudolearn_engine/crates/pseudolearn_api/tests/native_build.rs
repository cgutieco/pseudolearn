use pseudolearn_api::{
    ExecutionLimits, NativeBuildFailure, NativeBuildRequest, build_native_object,
};

fn request(program: &str) -> NativeBuildRequest {
    NativeBuildRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        seed: 42,
        limits: ExecutionLimits::default(),
        source_name: "p.pseudo".to_owned(),
        locale: "es".to_owned(),
        error_template: "{path}\n".to_owned(),
        exhausted_template: "{path}\n".to_owned(),
    }
}

type Check = Result<(), String>;

fn failure(error: impl std::fmt::Debug) -> String {
    format!("{error:?}")
}

fn contains(haystack: &[u8], needle: &[u8]) -> bool {
    haystack
        .windows(needle.len())
        .any(|window| window == needle)
}

#[test]
fn a_valid_program_becomes_an_object_that_calls_the_runtime_main() -> Check {
    let object = build_native_object(&request("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"))
        .map_err(failure)?;
    assert!(contains(&object.bytes, b"pseudolearn_aot_main"));
    assert!(object.warnings.is_empty());
    Ok(())
}

#[test]
fn explicit_limits_and_flexible_strictness_are_accepted() -> Check {
    let mut custom = request("Algoritmo P\nEscribir 1\nFinAlgoritmo\n");
    custom.strictness = "flexible".to_owned();
    custom.limits = ExecutionLimits {
        depth: Some(5),
        statements: Some(100),
        cells: Some(10),
        micro_steps: None,
    };
    assert!(build_native_object(&custom).is_ok());
    Ok(())
}

#[test]
fn a_program_with_semantic_errors_is_rejected_with_its_diagnostics() -> Check {
    match build_native_object(&request("Algoritmo P\nEscribir total;\nFinAlgoritmo\n")) {
        Err(NativeBuildFailure::Rejected(diagnostics)) => {
            let codes: Vec<&str> = diagnostics
                .iter()
                .map(|entry| entry.code.as_str())
                .collect();
            assert_eq!(codes, ["undeclaredVariable"]);
            Ok(())
        }
        other => Err(failure(other)),
    }
}

#[test]
fn an_empty_program_is_rejected() -> Check {
    assert!(matches!(
        build_native_object(&request("")),
        Err(NativeBuildFailure::Rejected(_))
    ));
    Ok(())
}
