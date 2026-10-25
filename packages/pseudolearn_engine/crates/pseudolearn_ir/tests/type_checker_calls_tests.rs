use pseudolearn_ir::{parse_module, verify_module};

#[test]
fn accepts_call_result_with_the_callee_return_type() {
    let source_text = "module P es\nfunc @increment(%0: i64) -> i64 {\nb0() mass 0:\n  %1 = const.i64 1\n  %2 = int.add %0, %1 @2:1-2:4\n  return %2\n}\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 41\n  %1 = call @increment(%0) @8:1-8:5\n  %2 = const.i64 1\n  %3 = int.add %1, %2 @9:1-9:4\n  return %3\n}\n";
    let parsed = parse_module(source_text);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        assert_eq!(verify_module(&module), Ok(()));
    }
}

#[test]
fn rejects_call_result_used_as_the_wrong_type() {
    let source_text = "module P es\nfunc @predicate() -> bool {\nb0() mass 0:\n  %0 = const.bool true\n  return %0\n}\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = call @predicate() @8:1-8:5\n  %1 = int.add %0, %0 @9:1-9:4\n  return %1\n}\n";
    let parsed = parse_module(source_text);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        assert_eq!(verify_module(&module), Err("IR.WELL-FORMEDNESS#R3"));
    }
}

#[test]
fn verifies_indirect_call_code_and_prototype_types() -> Result<(), String> {
    for (instruction, expected) in [
        (
            "%0 = const.i64 0\n  %1 = call.indirect %0, @predicate() @8:1-8:5",
            true,
        ),
        (
            "%0 = const.bool true\n  %1 = call.indirect %0, @predicate() @8:1-8:5",
            false,
        ),
        (
            "%0 = const.i64 0\n  %1 = call.indirect %0, @predicate(%0) @8:1-8:5",
            false,
        ),
        (
            "%0 = const.i64 0\n  %1 = call.indirect %0, @missing() @8:1-8:5",
            false,
        ),
    ] {
        let text = format!(
            "module P es\nfunc @predicate() -> bool {{\nb0() mass 0:\n  %0 = const.bool true\n  return %0\n}}\nfunc @main() -> bool {{\nb0() mass 0:\n  {instruction}\n  return %1\n}}\n"
        );
        let module = parse_module(&text).map_err(|error| error.to_string())?;
        assert_eq!(verify_module(&module).is_ok(), expected, "{instruction}");
    }
    Ok(())
}
