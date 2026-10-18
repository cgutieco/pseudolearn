#![forbid(unsafe_code)]

use super::is_supported;
use pseudolearn_ir::Operation;

#[test]
fn every_operation_of_the_instruction_catalog_has_a_lowering() {
    let missing: Vec<&str> = Operation::ALL
        .iter()
        .filter(|operation| !is_supported(**operation))
        .map(Operation::as_str)
        .collect();
    assert!(
        missing.is_empty(),
        "operations without lowering: {missing:?}"
    );
}

#[test]
fn no_operation_is_claimed_by_two_families() {
    for operation in Operation::ALL {
        let claims = super::FAMILIES
            .iter()
            .filter(|(operations, _)| operations.contains(operation))
            .count();
        assert!(
            claims <= 1,
            "{} is lowered by {claims} families",
            operation.as_str()
        );
    }
}
