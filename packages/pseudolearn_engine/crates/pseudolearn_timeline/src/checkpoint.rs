use pseudolearn_vm::{
    Machine, MachineImage, machine_statements_executed, restore_machine_image, snapshot_machine,
};

use crate::shadow::{ShadowHeap, UndoSegment};

#[derive(Clone, Debug, PartialEq)]
pub struct Checkpoint {
    pub event_index: usize,
    pub statement_index: u64,
    pub image: MachineImage,
    pub undo_segment: UndoSegment,
}

pub fn capture_checkpoint(
    machine: &Machine,
    event_index: usize,
    shadow: &mut ShadowHeap,
) -> Checkpoint {
    let image = snapshot_machine(machine);
    let statement_index = machine_statements_executed(machine);
    let live_words = pseudolearn_runtime::heap_words(machine.heap());
    let undo_segment = shadow.synchronize_and_record(live_words, image.state.heap_used);
    Checkpoint {
        event_index,
        statement_index,
        image,
        undo_segment,
    }
}

pub fn restore_checkpoint(
    machine: &mut Machine,
    checkpoint: &Checkpoint,
) -> Result<(), pseudolearn_runtime::MemoryError> {
    restore_machine_image(machine, &checkpoint.image);
    Ok(())
}
