use pseudolearn_bytecode::RegisterClass;

use super::parallel_copy::sequentialize;
use super::{Definition, Move};

fn copy(source: u16, destination: u16) -> Move {
    Move {
        source,
        destination,
        class: RegisterClass::Scalar,
        definition: Definition::Copied,
    }
}

fn simulate(moves: &[Move], registers: &mut [u64]) {
    for entry in moves {
        let value = registers.get(usize::from(entry.source)).copied();
        if let (Some(value), Some(slot)) =
            (value, registers.get_mut(usize::from(entry.destination)))
        {
            *slot = value;
        }
    }
}

#[test]
fn empty_copy_produces_no_moves() {
    assert!(sequentialize(Vec::new(), 9).is_empty());
}

#[test]
fn self_copies_are_dropped() {
    assert!(sequentialize(vec![copy(1, 1)], 9).is_empty());
}

#[test]
fn chain_reads_every_source_before_overwriting_it() {
    let moves = sequentialize(vec![copy(0, 1), copy(1, 2)], 9);
    let mut registers = [10, 11, 12, 0, 0, 0, 0, 0, 0, 0];
    simulate(&moves, &mut registers);
    assert_eq!(registers.get(..3), Some(&[10, 10, 11][..]));
}

#[test]
fn swap_cycle_uses_the_scratch_register() {
    let moves = sequentialize(vec![copy(0, 1), copy(1, 0)], 2);
    assert_eq!(moves.len(), 3);
    assert!(moves.iter().any(|entry| entry.destination == 2));
    let mut registers = [10, 11, 0];
    simulate(&moves, &mut registers);
    assert_eq!(registers.get(..2), Some(&[11, 10][..]));
}

#[test]
fn three_cycle_rotates_values() {
    let moves = sequentialize(vec![copy(0, 1), copy(1, 2), copy(2, 0)], 3);
    let mut registers = [10, 11, 12, 0];
    simulate(&moves, &mut registers);
    assert_eq!(registers.get(..3), Some(&[12, 10, 11][..]));
}

#[test]
fn static_definitions_do_not_track_the_scratch_register() {
    let mut first = copy(0, 1);
    first.definition = Definition::Defined;
    let moves = sequentialize(vec![first, copy(1, 0)], 2);
    let scratch = moves.iter().find(|entry| entry.destination == 2);
    assert_eq!(
        scratch.map(|entry| entry.definition),
        Some(Definition::Untracked)
    );
}
