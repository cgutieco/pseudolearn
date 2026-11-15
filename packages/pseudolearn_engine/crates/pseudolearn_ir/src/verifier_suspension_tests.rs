use crate::{parse_module, print_canonical, verify_module};

#[test]
fn rejects_yields_outside_suspendible_units_and_loop_backedges() -> Result<(), String> {
    for text in [
        "module P es\nfunc @worker() -> unit {\nb0() mass 0:\n task.yield_check\n return\n}\n",
        "module P es\nfunc suspendible @worker() -> unit {\nb0() mass 0:\n task.yield_check\n return\n}\n",
    ] {
        let module = parse_module(text)?;
        assert_eq!(verify_module(&module), Err("IR.WELL-FORMEDNESS#R12"));
    }
    Ok(())
}

#[test]
fn accepts_and_roundtrips_a_suspendible_loop() -> Result<(), String> {
    let text = "module P es\nfunc suspendible @worker() -> unit {\nb0() mass 0:\n jump b1()\nb1() mass 0:\n task.yield_check\n jump b1()\n}\n";
    let module = parse_module(text)?;
    assert_eq!(verify_module(&module), Ok(()));
    let printed = print_canonical(&module);
    assert!(printed.contains("func suspendible"));
    assert_eq!(parse_module(&printed)?, module);
    Ok(())
}
