use pseudolearn_ir::ValueId;

#[test]
fn nan_constants_and_unknown_parameters_keep_their_presence_checks() -> Result<(), String> {
    let module = pseudolearn_ir::parse_module("module P es\nfunc @probe(%0: f64) -> f64 {\nb0() mass 0:\n  %1 = const.f64 NaN\n  %2 = const.f64 1.5\n  %3 = value.require %1\n  %4 = value.require %2\n  %5 = value.require %0\n  return %4\n}\n").map_err(|error| error.to_string())?;
    let function = module.functions.first().ok_or("Missing function")?;
    let defined = super::collect(function);
    assert!(!defined.contains(&ValueId(0)));
    assert!(!defined.contains(&ValueId(1)));
    assert!(!defined.contains(&ValueId(3)));
    assert!(!defined.contains(&ValueId(5)));
    assert!(defined.contains(&ValueId(2)));
    assert!(defined.contains(&ValueId(4)));
    Ok(())
}
