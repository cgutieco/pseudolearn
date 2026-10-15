#![forbid(unsafe_code)]

use super::{Definition, Move};

pub(super) fn sequentialize(pending: Vec<Move>, scratch: u16) -> Vec<Move> {
    let mut pending = pending
        .into_iter()
        .filter(|entry| entry.source != entry.destination)
        .collect::<Vec<_>>();
    let mut ordered = Vec::with_capacity(pending.len().saturating_add(1));
    while !pending.is_empty() {
        match pending
            .iter()
            .position(|entry| !is_read(&pending, entry.destination))
        {
            Some(position) => ordered.push(pending.remove(position)),
            None => break_cycle(&mut pending, &mut ordered, scratch),
        }
    }
    ordered
}

fn is_read(pending: &[Move], register: u16) -> bool {
    pending.iter().any(|entry| entry.source == register)
}

fn break_cycle(pending: &mut [Move], ordered: &mut Vec<Move>, scratch: u16) {
    let Some(first) = pending.first_mut() else {
        return;
    };
    ordered.push(Move {
        source: first.source,
        destination: scratch,
        class: first.class,
        definition: scratch_definition(first.definition),
    });
    first.source = scratch;
}

fn scratch_definition(definition: Definition) -> Definition {
    match definition {
        Definition::Copied => Definition::Copied,
        Definition::Untracked | Definition::Defined | Definition::Undefined => {
            Definition::Untracked
        }
    }
}
