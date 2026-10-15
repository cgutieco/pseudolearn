use see_oracles::cells::{Allocation, AllocationKind, cost, reachable_cells};
use std::collections::BTreeMap;

#[test]
fn counts_aliases_cycles_and_distinct_text_headers_once() -> Result<(), String> {
    let allocations = BTreeMap::from([
        (
            1,
            Allocation {
                kind: AllocationKind::Object { fields: 1 },
                references: vec![2],
            },
        ),
        (
            2,
            Allocation {
                kind: AllocationKind::Object { fields: 1 },
                references: vec![1],
            },
        ),
        (
            3,
            Allocation {
                kind: AllocationKind::Text { code_points: 9 },
                references: vec![],
            },
        ),
        (
            4,
            Allocation {
                kind: AllocationKind::Text { code_points: 9 },
                references: vec![],
            },
        ),
    ]);
    assert_eq!(reachable_cells(&allocations, &[1, 1, 3, 4, 0])?, 10);
    assert_eq!(reachable_cells(&allocations, &[])?, 0);
    assert!(reachable_cells(&allocations, &[5]).is_err());
    Ok(())
}

#[test]
fn handles_zero_sizes_rounding_and_count_overflow() {
    assert_eq!(cost(AllocationKind::Array { elements: 0 }), Ok(1));
    assert_eq!(cost(AllocationKind::Text { code_points: 0 }), Ok(1));
    assert_eq!(cost(AllocationKind::Text { code_points: 8 }), Ok(2));
    assert_eq!(cost(AllocationKind::Text { code_points: 9 }), Ok(3));
    assert_eq!(cost(AllocationKind::Literal), Ok(0));
    assert!(cost(AllocationKind::Array { elements: u64::MAX }).is_err());
}
