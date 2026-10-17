use super::{CheckpointStore, event_distance, is_better_victim};
use crate::checkpoint::Checkpoint;
use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Fuel, RunOptions, create_machine, load};

fn checkpoints_with_different_deltas() -> Result<CheckpointStore, String> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  out.write %0 @1:1-1:2\n  %1 = const.i64 2\n  out.write %1 @1:1-1:2\n  %2 = const.i64 3\n  out.write %2 @1:1-1:2\n  %3 = const.i64 4\n  out.write %3 @1:1-1:2\n  %4 = const.i64 5\n  out.write %4 @1:1-1:2\n  %5 = const.i64 6\n  out.write %5 @1:1-1:2\n  %6 = const.i64 7\n  out.write %6 @1:1-1:2\n  return\n}\n";
    let bytecode = compile_text(source).map_err(|error| format!("{error:?}"))?;
    let program = load(&bytecode).map_err(|error| format!("{error:?}"))?;
    let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    let mut store = CheckpointStore::new(12);
    for event_index in 0..7 {
        store
            .record(&machine, event_index)
            .map_err(|error| error.to_string())?;
        if machine.step_instruction().is_some() {
            return Err("Program ended before all checkpoint states were captured".to_owned());
        }
    }
    Ok(store)
}

#[test]
fn equal_density_candidates_use_composed_slots_then_keep_the_first_exact_tie() -> Result<(), String>
{
    let mut store = checkpoints_with_different_deltas()?;
    let event_positions = [0, 1, 2, 3, 4, 6, 8];
    for (checkpoint, event_index) in store.checkpoints.iter_mut().zip(event_positions) {
        checkpoint.event_index = event_index;
    }
    let first_slots = store.combined_retained_slots(3);
    let second_slots = store.combined_retained_slots(5);
    let expected = if second_slots < first_slots { 5 } else { 3 };
    assert_eq!(store.sparsest_interior_position(), Some(expected));
    Ok(())
}

#[test]
fn density_ties_prefer_fewer_composed_slots_and_keep_stable_order() {
    assert!(is_better_victim((2, 6, 4), (3, 4, 5)));
    assert!(!is_better_victim((2, 6, 5), (3, 4, 4)));
    assert!(!is_better_victim((2, 6, 4), (3, 4, 4)));
}

#[test]
fn event_distance_saturates_when_checkpoints_are_reversed() {
    let later = Checkpoint {
        event_index: 4,
        statement_index: 0,
        undo: None,
    };
    let earlier = Checkpoint {
        event_index: 9,
        statement_index: 0,
        undo: None,
    };
    assert_eq!(event_distance(&later, &earlier), 0);
}
