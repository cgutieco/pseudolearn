use pseudolearn_ir::{Operation, ValueId, parse_module};

const MODULE: &str = "module P es\nclass \"$effect:JsonValue\" {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = value.undefined obj<\"$effect:JsonValue\">\n  %1 = const.str \"b\"\n  %2 = cell.local obj<\"$effect:JsonValue\">\n  %3 = effect_call %0, json_with_field, obj<\"$effect:JsonValue\">, n1, %1, %0, %2 @1:1-1:2\n  return\n}\n";

fn effect_call_roots() -> Result<Vec<ValueId>, String> {
    let module = parse_module(MODULE).map_err(|error| error.to_string())?;
    let function = module.functions.first().ok_or("missing main")?;
    let types = crate::value_types::infer(&module, function);
    let roots = crate::liveness::live_roots(
        function,
        &types,
        crate::ParameterRoots::AllLive,
        &module.origins.entries,
    );
    let call = function
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .find(|id| function.columns.operation(**id) == Some(Operation::EffectCall))
        .ok_or("missing effect call")?;
    roots
        .get(call)
        .cloned()
        .ok_or_else(|| "effect call is not a safe point".to_owned())
}

#[test]
fn roots_reference_operands_of_an_effect_call() -> Result<(), String> {
    let roots = effect_call_roots()?;
    assert!(roots.contains(&ValueId(0)));
    assert!(roots.contains(&ValueId(1)));
    Ok(())
}

#[test]
fn does_not_root_the_result_cell_of_an_effect_call() -> Result<(), String> {
    let roots = effect_call_roots()?;
    assert!(!roots.contains(&ValueId(2)));
    Ok(())
}
