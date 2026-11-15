use pseudolearn_api::{ExecuteRequest, NativeObject};

#[test]
fn absent_receivers_force_each_slow_path_and_match_the_vm() -> Result<(), String> {
    for (kind, access) in [
        ("array<i64, 1>", "%2 = array.load %0, %1"),
        ("array<i64, 1>", "array.store %0, %1, %1"),
        ("obj<Node>", "%2 = object.load %0, value"),
        ("obj<Node>", "object.store %0, value, %1"),
    ] {
        let text = format!(
            "module P es\nclass Node {{ value: i64 }}\nfunc @main() -> unit {{\nb0() mass 0:\n  %0 = value.undefined {kind}\n  %1 = const.i64 0\n  {access} @7:3-7:9\n  return\n}}\n"
        );
        compare(&text)?;
    }
    Ok(())
}

fn compare(text: &str) -> Result<(), String> {
    let module = pseudolearn_ir::parse_module(text).map_err(|error| format!("{error:?}"))?;
    let bytecode =
        pseudolearn_bytecode::compile_module(&module).map_err(|error| format!("{error:?}"))?;
    let loaded = pseudolearn_vm::load(&bytecode).map_err(|error| format!("{error:?}"))?;
    let expected = pseudolearn_vm::run_with_options(
        &loaded,
        pseudolearn_vm::Fuel {
            statements: 100,
            probes: 100,
        },
        pseudolearn_vm::RunOptions::default(),
    );
    let pseudolearn_vm::RunExit::Trap(trap) = expected.exit else {
        return Err("Expected VM fault".to_owned());
    };
    let request = ExecuteRequest {
        program: "Algoritmo P\nFinAlgoritmo\n".to_owned(),
        ..Default::default()
    };
    let build = pseudolearn_api::conformance_build_request(&request);
    let benchmark =
        pseudolearn_api::build_benchmark_object(&build).map_err(|error| format!("{error:?}"))?;
    let metadata =
        pseudolearn_aot_rt::decode_metadata(&benchmark.metadata).ok_or("Invalid metadata")?;
    let compiled = pseudolearn_codegen::compile_module_to_executable_object(
        &module,
        &pseudolearn_codegen::TargetConfig::host().with_verification(),
        &metadata.settings,
    )
    .map_err(|error| format!("{error:?}"))?;
    let actual = super::support::run_object(
        &request,
        NativeObject {
            bytes: compiled.bytes,
            warnings: Vec::new(),
        },
    )?;
    let diagnostic = actual.diagnostics.first().ok_or("Missing native fault")?;
    assert_eq!(diagnostic.code, trap.code);
    assert_eq!(actual.output, expected.output);
    let arguments: std::collections::BTreeMap<_, _> = trap
        .arguments
        .iter()
        .map(|(name, argument)| ((*name).to_owned(), argument.wire()))
        .collect();
    assert_eq!(diagnostic.arguments, arguments);
    let span = trap.span.ok_or("Missing VM span")?;
    assert_eq!(
        (diagnostic.span.start.line, diagnostic.span.start.column),
        (span.start_line, span.start_column)
    );
    assert_eq!(
        (diagnostic.span.end.line, diagnostic.span.end.column),
        (span.end_line, span.end_column)
    );
    Ok(())
}
