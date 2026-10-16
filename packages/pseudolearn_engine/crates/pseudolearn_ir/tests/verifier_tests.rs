#![forbid(unsafe_code)]

use pseudolearn_ir::{parse_module, verify_module};

#[test]
fn accepts_well_formed_program() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Ok(()));
    }
}

#[test]
fn rejects_unknown_instruction_as_rule1() {
    let source =
        "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = int.teleport\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_err());
}

#[test]
fn rejects_use_before_definition_as_rule2() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = int.cmp lt, %1, %1\n  %1 = const.i64 1\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R2"));
    }
}

#[test]
fn rejects_operand_type_mismatch_as_rule3() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = const.bool true\n  %2 = int.add %0, %1 @1:1-1:2\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R3"));
    }
}

#[test]
fn rejects_missing_terminator_as_rule4() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R4"));
    }
}

#[test]
fn rejects_branch_arity_mismatch_as_rule5() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  jump b1()\nb1(%0: i64) mass 0:\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R5"));
    }
}

#[test]
fn accepts_derived_values_at_base_typed_block_parameters() {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nclass Other {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new Derived @1:1-1:2\n  jump b1(%0)\nb1(%1: obj<Base>) mass 0:\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Ok(()));
    }
}

#[test]
fn rejects_unrelated_values_at_base_typed_block_parameters() {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nclass Other {}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new Other @1:1-1:2\n  jump b1(%0)\nb1(%1: obj<Base>) mass 0:\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R5"));
    }
}

#[test]
fn accepts_derived_values_stored_through_base_typed_cells() {
    let source = "module P es\nclass Base {}\nclass Derived : Base {}\nfunc @main(%0: cell<obj<Base>>) -> unit {\nb0() mass 0:\n  %1 = object.new Derived @1:1-1:2\n  cell.store %0, %1\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Ok(()));
    }
}

#[test]
fn rejects_unrelated_values_stored_through_base_typed_cells() {
    let source = "module P es\nclass Base {}\nclass Other {}\nfunc @main(%0: cell<obj<Base>>) -> unit {\nb0() mass 0:\n  %1 = object.new Other @1:1-1:2\n  cell.store %0, %1\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R3"));
    }
}

#[test]
fn rejects_mass_mismatch_as_rule6() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 2:\n  stmt.enter @1:1-1:2\n  stmt.exit @1:1-1:2\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R6"));
    }
}

#[test]
fn rejects_missing_span_on_trapping_instruction_as_rule7() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = int.div %0, %0\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R7"));
    }
}

#[test]
fn rejects_missing_function_call_as_rule8() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  call @sub.missing() @1:1-1:2\n  return\n}\n";
    let module = parse_module(source);
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        assert_eq!(verify_module(&parsed), Err("IR.WELL-FORMEDNESS#R8"));
    }
}
