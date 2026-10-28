use crate::types::Type;

#[test]
fn immutable_types_keep_the_underlying_bank_without_implicit_conversion() {
    let mut types = crate::types::TypeInterner::default();
    let integer = types.intern(Type::Integer);
    let immutable = types.intern(Type::Immutable(integer));
    assert_ne!(types.get(integer), types.get(immutable));
    assert_eq!(types.value_class(integer), types.value_class(immutable));
    assert_eq!(types.representation(immutable), Type::Integer);
}

#[test]
fn immutable_references_remain_gc_references() {
    let mut types = crate::types::TypeInterner::default();
    let text = types.intern(Type::String);
    let immutable = types.intern(Type::Immutable(text));
    assert_eq!(
        types.value_class(immutable),
        crate::types::ValueClass::Reference
    );
}

#[test]
fn unwraps_deep_immutable_types_iteratively_and_rejects_cycles() {
    let mut types = crate::types::TypeInterner::default();
    let mut current = types.intern(Type::Integer);
    for _ in 0..4096 {
        current = types.intern(Type::Immutable(current));
    }
    assert_eq!(types.representation(current), Type::Integer);
    let mut cyclic = crate::types::TypeInterner::default();
    let recursive = cyclic.intern(Type::Immutable(crate::TypeId(0)));
    assert_eq!(cyclic.representation(recursive), Type::Error);
}
