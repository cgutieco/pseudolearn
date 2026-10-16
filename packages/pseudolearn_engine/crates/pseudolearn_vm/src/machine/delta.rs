use pseudolearn_runtime::{
    BlockDelta, DeltaError, HeapDelta, TailDelta, advance_heap, compose_heap_deltas, revert_heap,
};

use super::inspection::capture_saved_frames;
use super::{Machine, MachineImage, MachineStateRecord};
use crate::{ChangeBuffer, VmTrap};
use pseudolearn_runtime::Handle;

#[derive(Clone, Debug, PartialEq)]
pub struct MachineDelta {
    control: MachineStateRecord,
    frames: BlockDelta<super::SavedControlFrame>,
    cells: BlockDelta<super::Cell>,
    scalars: BlockDelta<u64>,
    references: BlockDelta<u32>,
    defined: BlockDelta<bool>,
    heap: HeapDelta,
    output: TailDelta<String>,
    literals: TailDelta<Vec<Handle>>,
    inputs: TailDelta<Vec<String>>,
    diagnostics: TailDelta<Vec<VmTrap>>,
    changes: ChangeBuffer,
    flags: ImageFlags,
    remaining: crate::Fuel,
}

#[derive(Clone, Copy, Debug, PartialEq)]
struct ImageFlags {
    probed: bool,
    input_requested: bool,
    output_suppressed: bool,
    events_dropped: usize,
}

impl MachineDelta {
    pub fn copied_slots(&self) -> usize {
        self.frames
            .copied_slots()
            .saturating_add(self.cells.copied_slots())
            .saturating_add(self.scalars.copied_slots())
            .saturating_add(self.references.copied_slots())
            .saturating_add(self.defined.copied_slots())
            .saturating_add(self.heap.copied_slots())
            .saturating_add(self.output.copied_slots())
            .saturating_add(self.literals.copied_slots())
            .saturating_add(self.inputs.copied_slots())
            .saturating_add(self.diagnostics.copied_slots())
    }

    pub fn bank_slots(&self) -> usize {
        self.scalars
            .copied_slots()
            .saturating_add(self.references.copied_slots())
            .saturating_add(self.defined.copied_slots())
    }
}

pub fn advance_image(tip: &mut MachineImage, machine: &Machine<'_>) -> MachineDelta {
    let live_frames = capture_saved_frames(machine);
    let delta = MachineDelta {
        control: control_of(&tip.state),
        frames: BlockDelta::advance(&mut tip.state.frames, &live_frames),
        cells: BlockDelta::advance(&mut tip.state.cells, &machine.cells),
        scalars: BlockDelta::advance(&mut tip.state.scalars, &machine.scalars),
        references: BlockDelta::advance(&mut tip.state.references, &machine.references),
        defined: BlockDelta::advance(&mut tip.state.defined, &machine.defined),
        heap: advance_heap(&mut tip.heap, &machine.heap),
        output: TailDelta::advance(&mut tip.output, &machine.output),
        literals: TailDelta::advance(&mut tip.literals, &machine.literals),
        inputs: TailDelta::advance(&mut tip.inputs, &machine.inputs),
        diagnostics: TailDelta::advance(&mut tip.diagnostics, &machine.diagnostics),
        changes: std::mem::replace(&mut tip.changes, machine.change_buffer.clone()),
        flags: ImageFlags {
            probed: std::mem::replace(&mut tip.probed, machine.probed),
            input_requested: std::mem::replace(
                &mut tip.input_requested,
                machine.input_requested_emitted,
            ),
            output_suppressed: std::mem::replace(
                &mut tip.output_suppressed,
                machine.output_suppressed,
            ),
            events_dropped: std::mem::replace(
                &mut tip.events_dropped,
                machine.events_dropped.saturating_add(machine.events.len()),
            ),
        },
        remaining: std::mem::replace(&mut tip.remaining, machine.remaining),
    };
    replace_control(&mut tip.state, &machine.capture_control_record());
    delta
}

pub fn revert_image(image: &mut MachineImage, delta: &MachineDelta) -> Result<(), DeltaError> {
    delta.frames.revert(&mut image.state.frames)?;
    delta.cells.revert(&mut image.state.cells)?;
    delta.scalars.revert(&mut image.state.scalars)?;
    delta.references.revert(&mut image.state.references)?;
    delta.defined.revert(&mut image.state.defined)?;
    revert_heap(&mut image.heap, &delta.heap)?;
    delta.output.revert(&mut image.output);
    delta.literals.revert(&mut image.literals);
    delta.inputs.revert(&mut image.inputs);
    delta.diagnostics.revert(&mut image.diagnostics);
    image.changes.clone_from(&delta.changes);
    image.probed = delta.flags.probed;
    image.input_requested = delta.flags.input_requested;
    image.output_suppressed = delta.flags.output_suppressed;
    image.events_dropped = delta.flags.events_dropped;
    image.remaining = delta.remaining;
    replace_control(&mut image.state, &delta.control);
    Ok(())
}

pub fn compose_machine_deltas(first_applied: &MachineDelta, older: &MachineDelta) -> MachineDelta {
    MachineDelta {
        control: older.control.clone(),
        frames: BlockDelta::compose(&first_applied.frames, &older.frames),
        cells: BlockDelta::compose(&first_applied.cells, &older.cells),
        scalars: BlockDelta::compose(&first_applied.scalars, &older.scalars),
        references: BlockDelta::compose(&first_applied.references, &older.references),
        defined: BlockDelta::compose(&first_applied.defined, &older.defined),
        heap: compose_heap_deltas(&first_applied.heap, &older.heap),
        output: TailDelta::compose(&first_applied.output, &older.output),
        literals: TailDelta::compose(&first_applied.literals, &older.literals),
        inputs: TailDelta::compose(&first_applied.inputs, &older.inputs),
        diagnostics: TailDelta::compose(&first_applied.diagnostics, &older.diagnostics),
        changes: older.changes.clone(),
        flags: older.flags,
        remaining: older.remaining,
    }
}

fn control_of(state: &MachineStateRecord) -> MachineStateRecord {
    let mut control = state.clone_control();
    control.frames = Vec::new();
    control
}

fn replace_control(state: &mut MachineStateRecord, control: &MachineStateRecord) {
    let frames = std::mem::take(&mut state.frames);
    let cells = std::mem::take(&mut state.cells);
    let scalars = std::mem::take(&mut state.scalars);
    let references = std::mem::take(&mut state.references);
    let defined = std::mem::take(&mut state.defined);
    *state = control.clone_control();
    state.frames = frames;
    state.cells = cells;
    state.scalars = scalars;
    state.references = references;
    state.defined = defined;
}
