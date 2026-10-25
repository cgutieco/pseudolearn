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

#[test]
fn reinterpretation_preserves_the_bank_and_forbids_cell_casts() {
    for (source_type, target, valid) in [
        ("i64", "f64", true),
        ("str", "i64", false),
        ("i64", "str", false),
        ("cell<str>", "str", false),
    ] {
        let source = format!(
            "module P en\nfunc @main() -> unit {{\nb0() mass 0:\n  %0 = value.undefined {source_type}\n  %1 = value.reinterpret {target}, %0\n  return\n}}\n"
        );
        let parsed = parse_module(&source);
        assert!(parsed.is_ok(), "{parsed:?}");
        if let Ok(module) = parsed {
            assert_eq!(verify_module(&module).is_ok(), valid);
        }
    }
}

#[test]
fn transport_load_is_typed_without_changing_checked_cell_load() {
    for operand in ["%0", "i64"] {
        let source = format!(
            "module P en\nfunc @main() -> unit {{\nb0() mass 0:\n  %0 = cell.local str\n  %1 = cell.load_raw {operand} @4:1-4:5\n  return\n}}\n"
        );
        let parsed = parse_module(&source);
        assert!(parsed.is_ok(), "{parsed:?}");
        if let Ok(module) = parsed {
            assert_eq!(verify_module(&module).is_ok(), operand == "%0");
        }
    }
}
