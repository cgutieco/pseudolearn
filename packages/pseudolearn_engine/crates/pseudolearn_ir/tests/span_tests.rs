use pseudolearn_ir::{IrPosition, IrSpan, parse_module, print_canonical, verify_module};
use pseudolearn_source::SourceId;

#[test]
fn lexical_visibility_respects_boundaries_and_source_identity() {
    let scope = IrSpan::new(2, 3, 5, 9);
    assert!(scope.contains_start(IrSpan::new(2, 3, 2, 8)));
    assert!(scope.contains_start(IrSpan::new(5, 8, 5, 9)));
    assert!(!scope.contains_start(IrSpan::new(5, 9, 5, 10)));
    assert!(!scope.contains_start(IrSpan::new(1, 1, 2, 3)));
    assert!(!scope.contains_start(IrSpan::in_source(
        SourceId::new(1),
        IrPosition::new(3, 1),
        IrPosition::new(3, 2)
    )));
}

#[test]
fn source_qualified_spans_round_trip_canonically() -> Result<(), String> {
    let span = IrSpan::in_source(
        SourceId::new(4),
        IrPosition::new(2, 3),
        IrPosition::new(2, 8),
    );
    assert_eq!(span.to_string(), "@f4:2:3-2:8");
    assert_eq!(IrSpan::parse("@f4:2:3-2:8"), Some(span));
    assert_eq!(IrSpan::parse("@f0:2:3-2:8"), None);
    assert_eq!(IrSpan::parse("@2:3-2:8"), Some(IrSpan::new(2, 3, 2, 8)));
    Ok(())
}

#[test]
fn canonical_ir_preserves_distinct_source_ids_for_equal_ranges() -> Result<(), String> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @f1:2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @f2:2:1-2:12\n  stmt.exit @f1:2:1-2:12\n  return\n}\n";
    let module = parse_module(source).map_err(|error| error.to_string())?;
    verify_module(&module).map_err(str::to_owned)?;
    assert_eq!(print_canonical(&module), source);
    Ok(())
}

#[test]
fn verifier_rejects_empty_and_reversed_source_ranges() -> Result<(), String> {
    for span in ["@0:1-2:1", "@2:3-2:1"] {
        let source = format!(
            "module P es\nfunc @main() -> unit {{\nb0() mass 1:\n  stmt.enter {span}\n  %0 = const.i64 1\n  out.write %0, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}}\n"
        );
        let module = parse_module(&source).map_err(|error| error.to_string())?;
        assert_eq!(verify_module(&module), Err("IR.WELL-FORMEDNESS#R7"));
    }
    Ok(())
}

#[test]
fn source_map_span_storage_adds_one_source_identifier() {
    let previous_span_bytes = std::mem::size_of::<u32>() * 4;
    assert_eq!(
        std::mem::size_of::<IrSpan>(),
        previous_span_bytes + std::mem::size_of::<SourceId>()
    );
}
