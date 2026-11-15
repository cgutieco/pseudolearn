use pseudolearn_ir::{IrType, collection_types::from_fields};

#[test]
fn canonical_banks_accept_scalar_then_reference_leaves() {
    let fields = [
        ("$leaf:value", IrType::I64),
        ("$leaf:record:name", IrType::Str),
    ];
    let layout = from_fields(
        "$vector<Row>",
        fields.iter().map(|(name, kind)| (*name, kind)),
    );
    assert!(layout.is_some_and(
        |layout| layout.key.is_none() && layout.leaves == vec![IrType::I64, IrType::Str]
    ));
}

#[test]
fn malformed_metadata_rejects_mixed_banks_and_invalid_keys() {
    let reversed = [("$leaf:first", IrType::Str), ("$leaf:second", IrType::I64)];
    assert!(
        from_fields(
            "$vector<Row>",
            reversed.iter().map(|(name, kind)| (*name, kind))
        )
        .is_none()
    );
    let invalid = [("$key", IrType::F64), ("$leaf:value", IrType::I64)];
    assert!(
        from_fields(
            "$dictionary<real,integer>",
            invalid.iter().map(|(name, kind)| (*name, kind))
        )
        .is_none()
    );
    assert!(from_fields("Ordinary", invalid.iter().map(|(name, kind)| (*name, kind))).is_none());
}

#[test]
fn quoted_collection_metadata_round_trips_and_validates() -> Result<(), String> {
    use pseudolearn_ir::{parse_module, print_canonical, verify_module};
    let source = "module P es\nclass \"$vector<integer>\" { \"$leaf:value\": i64 }\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = collection.new obj<\"$vector<integer>\"> @1:1-1:2\n  %1 = collection.length %0 @1:1-1:2\n  return\n}\n";
    let module = parse_module(source)?;
    assert_eq!(print_canonical(&module), source);
    assert_eq!(verify_module(&module), Ok(()));
    Ok(())
}

#[test]
fn rejects_collection_leaf_from_the_wrong_bank() -> Result<(), String> {
    let source = "module P es\nclass \"$vector<integer>\" { \"$leaf:value\": i64 }\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = collection.new obj<\"$vector<integer>\"> @1:1-1:2\n  %1 = const.i64 0\n  %2 = collection.load str, %0, %1, 0 @1:1-1:2\n  return\n}\n";
    let module = pseudolearn_ir::parse_module(source)?;
    assert!(pseudolearn_ir::verify_module(&module).is_err());
    Ok(())
}
