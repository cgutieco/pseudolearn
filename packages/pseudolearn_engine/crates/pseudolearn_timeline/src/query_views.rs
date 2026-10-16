use crate::{ArraySliceRange, FrameView, TimelineError, VariableValue};
use pseudolearn_vm::Machine;

pub fn capture_frame(machine: &Machine<'_>, position: usize) -> Result<FrameView, TimelineError> {
    let frame = machine
        .active_frame(position)
        .ok_or(TimelineError::InvalidFrame {
            frame_position: position,
            total_frames: machine.active_frames_count(),
        })?;
    Ok(crate::inspect::build_frame_view(machine, position, &frame))
}

pub fn capture_array_slice(
    machine: &Machine<'_>,
    ordinal: u64,
    range: ArraySliceRange,
) -> Result<Vec<VariableValue>, TimelineError> {
    crate::array_view::read_slice(machine, ordinal, range)
}
