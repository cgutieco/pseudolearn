#![forbid(unsafe_code)]

use pseudolearn_ir::{parse_module, print_canonical};

#[test]
fn parses_and_prints_valid_module_with_classes_and_subprograms() {
    let source = "module P es\nclass C { valor: i64 }\nfunc @sub.inc(%0: cell<i64>) -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %1 = cell.load %0 @2:6-2:7\n  %2 = const.i64 1\n  %3 = int.add %1, %2 @2:6-2:11\n  cell.store %0, %3\n  stmt.exit @2:1-2:12\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new C @6:6-6:17\n  %1 = cell.field %0, valor\n  %2 = const.i64 0\n  cell.store %1, %2\n  call @sub.inc(%1) @7:1-7:9\n  return\n}\n";
    let module = parse_module(source).map_err(|error| error.to_string());
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        let canonical = print_canonical(&parsed);
        assert_eq!(canonical, source);
    }
}

#[test]
fn normalizes_non_canonical_formatting_and_renumbers_blocks_and_values() {
    let non_canonical = "module P es\nfunc @main() -> unit {\nb3() mass 1:\n  stmt.enter @2:1-2:12\n  %7   =  const.i64   1\n  out.write %7, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n\n";
    let expected = "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n";
    let module = parse_module(non_canonical).map_err(|error| error.to_string());
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        let canonical = print_canonical(&parsed);
        assert_eq!(canonical, expected);
    }
}

#[test]
fn roundtrips_loop_and_branches_canonically() {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n";
    let module = parse_module(source).map_err(|error| error.to_string());
    assert!(module.is_ok());
    if let Ok(parsed) = module {
        let canonical = print_canonical(&parsed);
        assert_eq!(canonical, source);
    }
}

#[test]
fn preserves_real_literal_types_when_the_value_is_an_integer() {
    let source_text =
        "module P es\nfunc @main() -> f64 {\nb0() mass 0:\n  %0 = const.f64 2.0\n  return %0\n}\n";
    let parsed = parse_module(source_text);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        let canonical = print_canonical(&module);
        assert_eq!(canonical, source_text);
        let reparsed = parse_module(&canonical);
        assert!(reparsed.is_ok());
        if let Ok(roundtrip) = reparsed {
            assert_eq!(pseudolearn_ir::verify_module(&roundtrip), Ok(()));
        }
    }
}

#[test]
fn round_trips_array_type_operands_of_array_creation() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:27\n  %0 = const.i64 2 @2:13-2:14\n  %1 = array.new array<i64, 1>, %0 @2:1-2:27\n  stmt.exit @2:1-2:27\n  return @3:1-3:13\n}\n";
    let parsed = parse_module(source_text);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        assert_eq!(print_canonical(&module), source_text);
        assert_eq!(pseudolearn_ir::verify_module(&module), Ok(()));
    }
}

#[test]
fn rejects_array_type_operand_without_rank() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:27\n  %0 = const.i64 2 @2:13-2:14\n  %1 = array.new array<i64>, %0 @2:1-2:27\n  stmt.exit @2:1-2:27\n  return @3:1-3:13\n}\n";
    assert!(parse_module(source_text).is_err());
}

#[test]
fn round_trips_non_ascii_character_and_string_literals() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:23\n  %0 = const.char '😀' @2:19-2:22\n  %1 = const.str \"añ😀\" @2:19-2:22\n  out.write %1, newline @2:1-2:23\n  stmt.exit @2:1-2:23\n  return @3:1-3:13\n}\n";
    let parsed = parse_module(source_text);
    assert!(parsed.is_ok());
    if let Ok(module) = parsed {
        assert_eq!(print_canonical(&module), source_text);
    }
}

#[test]
fn rejects_unterminated_non_ascii_character_literal() {
    let source_text = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.char '😀 @2:19-2:22\n  return\n}\n";
    assert!(parse_module(source_text).is_err());
}
