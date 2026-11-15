use super::collection_sort::{SortPlan, build};
use pseudolearn_ir::{IrType, Operation};

#[test]
fn synthesized_merge_observes_only_the_user_comparator() {
    let plan = SortPlan {
        kind: IrType::Object("$vector<integer>".to_owned()),
        leaves: vec![IrType::I64],
        canonical: vec![0],
        signature: Some(0),
    };
    let function = build("@__collection.sort".to_owned(), &plan, None);
    assert!(function.blocks.iter().all(|block| block.mass == 0));
    let operations = function
        .blocks
        .iter()
        .flat_map(|block| &block.instructions)
        .filter_map(|instruction| function.columns.operation(*instruction))
        .collect::<Vec<_>>();
    assert!(
        operations
            .iter()
            .filter(|operation| operation.is_observation())
            .all(|operation| *operation == Operation::CallIndirect)
    );
    assert!(operations.contains(&Operation::CallIndirect));
    assert!(operations.contains(&Operation::CollectionCheck));
    assert!(operations.contains(&Operation::CollectionCommit));
}
