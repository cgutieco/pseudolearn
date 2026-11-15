use super::task_spill::SpilledFrame;
use crate::{Fault, evaluate::INVALID_BYTECODE};
use pseudolearn_runtime::{Handle, Heap};

pub(super) fn save_frame(
    heap: &mut Heap,
    frame: &SpilledFrame,
    (parent, mut scalars, mut references): (Handle, Vec<u64>, Vec<Handle>),
    roots: &[Handle],
) -> Result<Handle, Fault> {
    let capacity = frame.capacity;
    if scalars.len() > capacity.0 || references.len() > capacity.1 {
        return Err(INVALID_BYTECODE);
    }
    scalars.resize(capacity.0, 0);
    references.resize(capacity.1, Handle(0));
    let values = pseudolearn_runtime::continuation::ContinuationValues {
        function: u64::try_from(frame.function).map_err(|_| INVALID_BYTECODE)?,
        state: u64::try_from(frame.position).map_err(|_| INVALID_BYTECODE)?,
        parent,
        scalars: &scalars,
        references: &references,
    };
    if frame.handle == Handle(0) {
        return pseudolearn_runtime::continuation::new_continuation(heap, values, roots)
            .map_err(super::memory::memory_fault);
    }
    let layout = pseudolearn_runtime::continuation::continuation_capacity(heap, frame.handle)
        .map_err(super::memory::memory_fault)?;
    if usize::try_from(layout.scalar_slots()).ok() != Some(scalars.len())
        || usize::try_from(layout.reference_slots()).ok() != Some(references.len())
    {
        return Err(INVALID_BYTECODE);
    }
    pseudolearn_runtime::continuation::write_continuation(heap, frame.handle, layout, values)
        .map_err(super::memory::memory_fault)?;
    Ok(frame.handle)
}
