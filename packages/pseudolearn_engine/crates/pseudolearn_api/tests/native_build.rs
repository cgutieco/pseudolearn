#![cfg(feature = "native")]

use pseudolearn_api::{
    ExecutionLimits, NativeBuildFailure, NativeBuildRequest, build_native_object,
};

fn request(program: &str) -> NativeBuildRequest {
    NativeBuildRequest {
        program: program.to_owned(),
        profile: "es".to_owned().to_owned(),
        forced_collection: false,
        limits: ExecutionLimits::default(),
        source_name: "p.pseudo".to_owned(),
        source: None,
        locale: "es".to_owned(),
        error_template: "{path}\n".to_owned(),
        warning_template: "{path}:{line}:{column}: warning: {message} [{code}]\n".to_owned(),
        information_template: "{path}:{line}:{column}: info: {message} [{code}]\n".to_owned(),
        exhausted_template: "{path}\n".to_owned(),
        target: None,
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
fn explicit_limits_are_accepted() -> Check {
    let mut custom = request("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n");
    custom.limits = ExecutionLimits {
        depth: Some(5),
        statements: Some(100),
        cells: Some(10),
        micro_steps: None,
        tasks: None,
        channel_capacity: None,
        max_json_depth: None,
        max_http_body_bytes: None,
        max_http_wire_bytes: None,
        max_http_header_bytes: None,
        max_http_headers: None,
        max_pending_network: None,
        max_http_timeout_nanos: None,
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
        let module = pseudolearn_api::compile_source_to_module(&build.program, &build.profile)
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
fn a_program_with_tasks_compiles_natively() -> Check {
    let program = "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n";
    build_native_object(&request(program))
        .map(|_| ())
        .map_err(failure)
}

#[test]
fn a_program_with_channels_but_no_task_scope_compiles_natively() -> Check {
    let program = "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nFinAlgoritmo\n";
    build_native_object(&request(program))
        .map(|_| ())
        .map_err(failure)
}

#[test]
fn a_windows_target_object_carries_its_own_process_entry() -> Check {
    let mut windows = request("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n");
    windows.target = Some("x86_64-pc-windows-msvc".to_owned());
    let object = build_native_object(&windows).map_err(failure)?;
    assert!(object.bytes.starts_with(&[0x64, 0x86]));
    assert!(contains(&object.bytes, b"mainCRTStartup"));
    assert!(contains(&object.bytes, b"_tls_used"));
    Ok(())
}

#[test]
fn a_host_object_has_no_windows_process_entry() -> Check {
    let object = build_native_object(&request("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"))
        .map_err(failure)?;
    assert_eq!(
        contains(&object.bytes, b"mainCRTStartup"),
        cfg!(target_os = "windows")
    );
    Ok(())
}

#[test]
fn an_unparsable_target_is_a_backend_failure() {
    let mut unknown = request("Algoritmo P\nEscribir 1;\nFinAlgoritmo\n");
    unknown.target = Some("not a triple".to_owned());
    assert!(matches!(
        build_native_object(&unknown),
        Err(NativeBuildFailure::Backend(_))
    ));
}
