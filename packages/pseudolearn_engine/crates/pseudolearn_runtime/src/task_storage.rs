use crate::heap::{AllocationRequest, Shape};
use crate::{Handle, Heap, MemoryError};
use pseudolearn_abi::task_layout::*;

pub struct TaskStorage {
    pub identity: u64,
    pub parent: u64,
    pub scope: u64,
    pub continuation: Handle,
}

pub fn new_task_storage(
    heap: &mut Heap,
    task: TaskStorage,
    roots: &[Handle],
) -> Result<Handle, MemoryError> {
    let mut retained = roots.to_vec();
    retained.push(task.continuation);
    let handle = heap.allocate(
        AllocationRequest {
            shape: Shape::Task,
            payload: TASK_HEADER_WORDS,
            elements: 0,
            auxiliary: 0,
            cells: TASK_LOGICAL_CELLS,
            literal: false,
        },
        &retained,
    )?;
    for (offset, word) in [
        (TASK_ID_OFFSET, task.identity),
        (TASK_PARENT_OFFSET, task.parent),
        (TASK_SCOPE_OFFSET, task.scope),
        (TASK_CONTINUATION_OFFSET, u64::from(task.continuation.0)),
    ] {
        heap.store(handle, offset, word)?;
    }
    Ok(handle)
}

pub fn set_task_continuation(
    heap: &mut Heap,
    task: Handle,
    continuation: Handle,
) -> Result<(), MemoryError> {
    if heap.header(task)?.shape_tag != TASK_SHAPE_TAG {
        return Err(MemoryError::Internal);
    }
    heap.store(task, TASK_CONTINUATION_OFFSET, u64::from(continuation.0))
}

pub(crate) fn references(
    heap: &Heap,
    handle: Handle,
    pending: &mut Vec<Handle>,
) -> Result<(), MemoryError> {
    for offset in TASK_REFERENCE_OFFSETS {
        pending.push(Handle(
            u32::try_from(heap.word(handle, offset)?).map_err(|_| MemoryError::Internal)?,
        ));
    }
    Ok(())
}
