use crate::hir::HirModule;
use crate::identities::{ClassId, RecordId};
use crate::types::Type;

#[test]
fn accepts_collection_graphs_and_rejects_class_elements() {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    let collection = module.types.intern(Type::Object(ClassId(0)));
    module.collections.insert(
        ClassId(0),
        crate::collection_model::HirCollection {
            class: ClassId(0),
            key: None,
            value: integer,
            leaves: vec![integer],
            canonical: vec![0],
        },
    );
    assert!(super::snapshot_support::violation(&module, collection).is_none());
    let object = module.types.intern(Type::Object(ClassId(1)));
    if let Some(model) = module.collections.get_mut(&ClassId(0)) {
        model.value = object;
    }
    let failure = super::snapshot_support::violation(&module, collection);
    assert_eq!(
        failure.map(|failure| (failure.kind, failure.path)),
        Some((object, "$.element".to_owned()))
    );
}

#[test]
fn rejects_function_values_even_without_captures() {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    let function = module.types.intern(Type::Record(RecordId(0)));
    module.function_types.insert(
        RecordId(0),
        crate::function_model::FunctionSignature {
            parameters: Vec::new(),
            result: integer,
            pure: true,
        },
    );
    assert!(super::snapshot_support::violation(&module, function).is_some());
}
