#![cfg(feature = "native")]

use pseudolearn_api::{
    ExecutionLimits, NativeBuildFailure, NativeBuildRequest, build_native_object,
};

fn request(program: &str) -> NativeBuildRequest {
    NativeBuildRequest {
        program: program.to_owned(),
        profile: "es".to_owned(),
        strictness: "strict".to_owned(),
        seed: 42,
        forced_collection: false,
        limits: ExecutionLimits::default(),
        source_name: "p.pseudo".to_owned(),
        source: None,
        locale: "es".to_owned(),
        error_template: "{path}\n".to_owned(),
        warning_template: "{path}:{line}:{column}: warning: {message} [{code}]\n".to_owned(),
        information_template: "{path}:{line}:{column}: info: {message} [{code}]\n".to_owned(),
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
        tasks: None,
        channel_capacity: None,
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

#[test]
fn inspection_preserves_bytes_and_benchmark_functions_match_product_functions() -> Check {
    use pseudolearn_api::{
        emit_benchmark_object, inspect_benchmark_object, prepare_native_benchmark,
    };
    for statements in [None, Some(100)] {
        let mut build = request("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n");
        build.limits.statements = statements;
        let prepared = prepare_native_benchmark(&build).map_err(failure)?;
        let measured = emit_benchmark_object(&prepared).map_err(failure)?;
        let inspected = inspect_benchmark_object(&prepared).map_err(failure)?;
        assert_eq!(measured.bytes, inspected.bytes);
        assert_eq!(measured.metadata, inspected.metadata);
        assert!(measured.inspection.is_empty());
        assert!(!inspected.inspection.is_empty());
        let metadata = pseudolearn_aot_rt::decode_metadata(&measured.metadata)
            .ok_or("Invalid benchmark metadata")?;
        let module = pseudolearn_api::compile_source_to_module(
            &build.program,
            &build.profile,
            &build.strictness,
        )
        .map_err(failure)?;
        let product = pseudolearn_codegen::compile_module_to_executable_object(
            &module,
            &pseudolearn_codegen::TargetConfig::host().with_inspection(),
            &metadata.settings,
        )
        .map_err(failure)?;
        assert_eq!(inspected.inspection, product.inspection);
    }
    Ok(())
}

#[test]
fn a_program_with_tasks_is_rejected_with_an_explicit_native_diagnostic() -> Check {
    let program = "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n";
    match build_native_object(&request(program)) {
        Err(NativeBuildFailure::Rejected(diagnostics)) => {
            let codes: Vec<&str> = diagnostics.iter().map(|diagnostic| diagnostic.code.as_str()).collect();
            assert_eq!(codes, ["nativeTasksUnsupported"]);
            assert!(diagnostics.iter().all(|diagnostic| !diagnostic.message.is_empty()));
            Ok(())
        }
        other => Err(failure(other.map(|object| object.bytes.len()))),
    }
}

#[test]
fn a_program_with_channels_but_no_task_scope_is_rejected_too() -> Check {
    let program = "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nFinAlgoritmo\n";
    match build_native_object(&request(program)) {
        Err(NativeBuildFailure::Rejected(diagnostics)) => {
            assert_eq!(diagnostics.first().map(|diagnostic| diagnostic.code.as_str()), Some("nativeTasksUnsupported"));
            Ok(())
        }
        other => Err(failure(other.map(|object| object.bytes.len()))),
    }
}
