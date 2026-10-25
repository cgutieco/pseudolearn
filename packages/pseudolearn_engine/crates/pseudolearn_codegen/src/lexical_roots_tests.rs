use pseudolearn_ir::{IrSpan, ValueId, VariableId, parse_module};

#[test]
fn retains_only_dominating_variables_inside_their_lexical_scope() -> Result<(), String> {
    let text = "module P es\nfunc @visit() -> unit {\nb0() mass 0:\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.str \"owned\"\n  call @visit() @3:1-3:8\n  call @visit() @6:1-6:8\n  return\n}\n";
    let mut module = parse_module(text).map_err(|error| error.to_string())?;
    module
        .origins
        .record(ValueId(0), VariableId(0), "value".to_owned());
    let origin = module.origins.entries.first_mut().ok_or("missing origin")?;
    origin.function = "@main".to_owned();
    origin.visibility = Some(IrSpan::new(2, 1, 5, 1));
    let function = module.functions.get(1).ok_or("missing main")?;
    let types = crate::value_types::infer(&module, function);
    let roots = crate::liveness::live_roots(
        function,
        &types,
        crate::ParameterRoots::AllLive,
        &module.origins.entries,
    );
    let mut calls = function
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .filter(|id| function.columns.operation(**id) == Some(pseudolearn_ir::Operation::Call));
    let first = calls.next().ok_or("missing first call")?;
    let second = calls.next().ok_or("missing second call")?;
    assert!(
        roots
            .get(first)
            .is_some_and(|roots| roots.contains(&ValueId(0)))
    );
    assert!(roots.get(second).is_some_and(Vec::is_empty));
    Ok(())
}
