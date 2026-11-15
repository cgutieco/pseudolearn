use pseudolearn_semantic::{ClassId, Type, TypeId, TypeInterner, ValueClass};

#[test]
fn interns_types_by_role_and_rejects_unknown_indices() {
    let mut types = TypeInterner::default();
    let integer = types.intern(Type::Integer);
    assert_eq!(types.intern(Type::Integer), integer);
    let object = types.intern(Type::Object(ClassId(8)));
    let array = types.intern(Type::Array {
        element: integer,
        rank: 2,
    });
    assert_ne!(object, array);
    assert_eq!(types.value_class(integer), ValueClass::Scalar);
    assert_eq!(types.value_class(object), ValueClass::Reference);
    assert_eq!(types.get(TypeId(u32::MAX)), Type::Error);
}
