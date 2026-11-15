use pseudolearn_ir::ValueId;

#[test]
fn borrowed_parameters_do_not_extend_to_new_allocations_or_join_values() -> Result<(), String> {
    let module = pseudolearn_ir::parse_module("module P es\nfunc @probe(%0: array<i64, 1>) -> i64 {\nb0() mass 0:\n  %1 = value.require %0\n  %2 = const.i64 1\n  %3 = array.new array<i64, 1>, %2\n  jump b1(%1)\nb1(%4: array<i64, 1>) mass 0:\n  return %2\n}\n").map_err(|error| error.to_string())?;
    let function = module.functions.first().ok_or("Missing function")?;
    let types = crate::value_types::infer(&module, function);
    let borrowed = super::collect(function, &types);
    assert!(borrowed.contains(&ValueId(0)));
    assert!(borrowed.contains(&ValueId(1)));
    assert!(!borrowed.contains(&ValueId(3)));
    assert!(!borrowed.contains(&ValueId(4)));
    Ok(())
}
