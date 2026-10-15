use pseudolearn_ir::{parse_module, verify_module};

#[test]
fn checks_and_preserves_the_type_of_required_values() {
    let source_text = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = value.undefined i64\n  %1 = value.require %0 @3:1-3:5\n  %2 = int.add %1, %1 @4:1-4:4\n  return %2\n}\n";
    let parsed = parse_module(source_text);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        assert_eq!(verify_module(&module), Ok(()));
    }
}

#[test]
fn rejects_a_required_value_used_as_an_incompatible_type() {
    let source_text = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.bool true\n  %1 = value.require %0 @4:1-4:5\n  %2 = int.add %1, %1 @5:1-5:4\n  return %2\n}\n";
    let parsed = parse_module(source_text);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        assert_eq!(verify_module(&module), Err("IR.WELL-FORMEDNESS#R3"));
    }
}
