use pseudolearn_ir::{parse_module, verify_module};

fn verify(source: &str) -> Result<(), &'static str> {
    let module = parse_module(source).map_err(|_| "parse failed")?;
    verify_module(&module)
}

#[test]
fn verifies_switch_edges_and_rejects_duplicate_or_negative_ordinals() {
    for labels in ["0, b1(), 1, b1()", "0, b1(), 0, b1()", "-1, b1()"] {
        let source = format!(
            "module P en\nfunc @main() -> unit {{\nb0() mass 0:\n  %0 = const.i64 0\n  switch %0, b1(), {labels}\nb1() mass 0:\n  return\n}}\n"
        );
        let result = verify(&source);
        if labels == "0, b1(), 1, b1()" {
            assert_eq!(result, Ok(()));
        } else {
            assert_eq!(result, Err("IR.WELL-FORMEDNESS#R3"));
        }
    }
}

#[test]
fn checks_switch_argument_contracts_and_missing_targets() {
    for target in ["b1()", "b2()"] {
        let source = format!(
            "module P en\nfunc @main() -> unit {{\nb0() mass 0:\n  %0 = const.i64 0\n  switch %0, {target}, 0, {target}\nb1(%1: i64) mass 0:\n  return\n}}\n"
        );
        assert!(verify(&source).is_err());
    }
}
