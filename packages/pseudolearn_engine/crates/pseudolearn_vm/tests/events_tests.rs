#![forbid(unsafe_code)]

use pseudolearn_vm::ChangeBuffer;

#[test]
fn records_and_clears_object_field_changes() {
    let mut changes = ChangeBuffer::new();
    changes.record_object_field(12, 3, 91);
    assert_eq!(changes.modified_object_fields, vec![(12, 3, 91)]);
    changes.clear();
    assert!(changes.modified_object_fields.is_empty());
}
