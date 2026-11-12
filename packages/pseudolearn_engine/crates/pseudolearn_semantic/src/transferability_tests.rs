use crate::hir::{HirModule, HirRecord, HirRecordField};
use crate::identities::{ClassId, RecordId};
use crate::types::Type;
use pseudolearn_source::Span;

#[test]
fn rejects_nested_mutable_fields_with_the_complete_path() {
    let mut module = HirModule::default();
    let customer = module.types.intern(Type::Object(ClassId(0)));
    module.records.push(HirRecord {
        name: "Request".to_owned(),
        fields: vec![HirRecordField {
            name: "customer".to_owned(),
            type_id: customer,
            offset: 0,
            width: 1,
        }],
        leaf_types: vec![customer],
        leaf_names: vec!["customer".to_owned()],
        span: Span::default(),
        syntax: 0,
    });
    let request = module.types.intern(Type::Record(RecordId(0)));
    let violation = super::transferability::violation(&module, request);
    assert_eq!(
        violation.map(|failure| failure.path),
        Some("Request.customer".to_owned())
    );
}

#[test]
fn rejects_opaque_records_and_task_handles() {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    let task = module.types.intern(Type::Task(integer));
    assert!(super::transferability::violation(&module, integer).is_none());
    assert!(super::transferability::violation(&module, task).is_some());
    module.records.push(HirRecord {
        name: "Empty".to_owned(),
        fields: Vec::new(),
        leaf_types: Vec::new(),
        leaf_names: Vec::new(),
        span: Span::default(),
        syntax: 0,
    });
    let empty = module.types.intern(Type::Record(RecordId(0)));
    assert!(super::transferability::violation(&module, empty).is_some());
}

#[test]
fn terminates_on_recursive_record_types() {
    let mut module = HirModule::default();
    let recursive = module.types.intern(Type::Record(RecordId(0)));
    module.records.push(HirRecord {
        name: "Recursive".to_owned(),
        fields: Vec::new(),
        leaf_types: vec![recursive],
        leaf_names: vec!["cycle".to_owned()],
        span: Span::default(),
        syntax: 0,
    });
    assert!(super::transferability::violation(&module, recursive).is_some());
}

#[test]
fn traverses_deep_record_graphs_without_host_recursion() {
    let mut module = HirModule::default();
    let integer = module.types.intern(Type::Integer);
    let mut current = integer;
    for index in 0_u32..4096 {
        module.records.push(HirRecord {
            name: format!("Owner{index}"),
            fields: vec![HirRecordField {
                name: "nested".to_owned(),
                type_id: current,
                offset: 0,
                width: 1,
            }],
            leaf_types: vec![integer],
            leaf_names: vec!["nested".to_owned()],
            span: Span::default(),
            syntax: 0,
        });
        current = module.types.intern(Type::Record(RecordId(index)));
    }
    assert!(super::transferability::violation(&module, current).is_none());
    assert!(super::snapshot_support::violation(&module, current).is_none());
}

#[test]
fn rejects_function_signatures_without_captures() {
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
    assert!(super::transferability::violation(&module, function).is_some());
}
