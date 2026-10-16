use pseudolearn_vm::{Machine, MachineStateRecord, machine_statements_executed};

use crate::shadow::{ShadowHeap, UndoSegment};

#[derive(Clone, Debug, PartialEq)]
pub struct Checkpoint {
    pub event_index: usize,
    pub statement_index: u64,
    pub machine_state: MachineStateRecord,
    pub heap_words: Vec<u64>,
    pub undo_segment: UndoSegment,
}

pub fn capture_checkpoint(
    machine: &Machine,
    event_index: usize,
    shadow: &mut ShadowHeap,
) -> Checkpoint {
    let machine_state = machine.capture_machine_state();
    let statement_index = machine_statements_executed(machine);
    let live_words = pseudolearn_runtime::heap_words(machine.heap());
    let undo_segment = shadow.synchronize_and_record(live_words, machine_state.heap_used);
    let heap_words = live_words.to_vec();
    Checkpoint {
        event_index,
        statement_index,
        machine_state,
        heap_words,
        undo_segment,
    }
}

pub fn restore_checkpoint(
    machine: &mut Machine,
    checkpoint: &Checkpoint,
) -> Result<(), pseudolearn_runtime::MemoryError> {
    machine.restore_machine_state(&checkpoint.machine_state);
    let target_heap = machine.heap_mut();
    pseudolearn_runtime::restore_heap_block(target_heap, 0, &checkpoint.heap_words)
}
