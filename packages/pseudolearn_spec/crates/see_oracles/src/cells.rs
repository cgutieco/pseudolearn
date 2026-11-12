use std::collections::{BTreeMap, BTreeSet};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum AllocationKind {
    Object { fields: u64 },
    Array { elements: u64 },
    Text { code_points: u64 },
    Literal,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Allocation {
    pub kind: AllocationKind,
    pub references: Vec<u64>,
}

pub fn reachable_cells(
    allocations: &BTreeMap<u64, Allocation>,
    roots: &[u64],
) -> Result<u64, String> {
    let mut pending = roots.to_vec();
    let mut visited = BTreeSet::new();
    let mut total = 0_u64;
    while let Some(identity) = pending.pop() {
        if identity == 0 || !visited.insert(identity) {
            continue;
        }
        let allocation = allocations
            .get(&identity)
            .ok_or("Oracle dangling identity")?;
        total = total
            .checked_add(cost(allocation.kind)?)
            .ok_or("Oracle cell count overflow")?;
        pending.extend(allocation.references.iter().copied());
    }
    Ok(total)
}

pub fn cost(kind: AllocationKind) -> Result<u64, String> {
    let payload = match kind {
        AllocationKind::Object { fields } => fields,
        AllocationKind::Array { elements } => elements,
        AllocationKind::Text { code_points } => code_points
            .checked_div(8)
            .and_then(|whole| {
                whole.checked_add(u64::from(
                    code_points
                        .checked_rem(8)
                        .is_some_and(|remaining| remaining > 0),
                ))
            })
            .ok_or("Oracle text count overflow")?,
        AllocationKind::Literal => return Ok(0),
    };
    payload
        .checked_add(1)
        .ok_or_else(|| "Oracle cell count overflow".to_owned())
}
