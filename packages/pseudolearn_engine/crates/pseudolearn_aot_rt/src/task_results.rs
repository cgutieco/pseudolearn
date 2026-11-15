use crate::context::AotRuntimeContext;
use crate::guard::{Entry, borrow_slice, run_entry};
use crate::task_blocking::packet_values;
use crate::task_values::TaskValue;
use crate::trap::Trap;
use pseudolearn_runtime::{CollectionWords, Handle, TaskScopeId, VectorLayout};

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_outcome(
    context: *mut AotRuntimeContext,
    site: u32,
    failure: u32,
    packet: *const u64,
) -> u32 {
    run_entry(context, site, |entry| {
        let values = packet_values(packet)?;
        let tasks = entry.engine.tasks_mut()?;
        let current = tasks.current;
        tasks.outcomes.insert(current, (failure != 0, values));
        Ok(0)
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_value_load(
    context: *mut AotRuntimeContext,
    site: u32,
    index: u64,
) -> u32 {
    run_entry(context, site, |entry| {
        let tasks = entry.engine.tasks_mut()?;
        let position = usize::try_from(index).map_err(|_| Trap::named("internalFault"))?;
        Ok(tasks
            .transport_values
            .get(&tasks.current)
            .and_then(Option::as_ref)
            .and_then(|values| values.get(position))
            .map_or(0, |value| value.word()))
    })
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_scope_result(
    context: *mut AotRuntimeContext,
    site: u32,
    scope: u64,
    layout: *const u64,
) -> u32 {
    let words = borrow_slice(layout, 3).map(<[u64]>::to_vec);
    run_entry(context, site, |entry| {
        let layout = vector_layout(words.as_deref())?;
        scope_result(entry, TaskScopeId(scope), layout)
    })
}

fn vector_layout(words: Option<&[u64]>) -> Result<VectorLayout, Trap> {
    let number = |index: usize| {
        words
            .and_then(|words| words.get(index))
            .and_then(|word| u32::try_from(*word).ok())
            .ok_or_else(|| Trap::named("internalFault"))
    };
    Ok(VectorLayout {
        scalar_words: number(0)?,
        reference_words: number(1)?,
        type_identity: number(2)?,
    })
}

fn scope_result(
    entry: &mut Entry<'_>,
    scope: TaskScopeId,
    layout: VectorLayout,
) -> Result<u64, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    let failure = tasks
        .failures
        .remove(&scope)
        .and_then(pseudolearn_runtime::TaskFailures::finish);
    let Some(failure) = failure else {
        tasks.transport_values.insert(current, None);
        return Ok(0);
    };
    let vector = associated_errors(entry, layout, failure.associated)?;
    let mut payload = failure.first;
    payload.push(TaskValue::Reference(vector.0));
    payload.push(TaskValue::Scalar(failure.cancelled));
    entry
        .engine
        .tasks_mut()?
        .transport_values
        .insert(current, Some(payload));
    Ok(1)
}

fn associated_errors(
    entry: &mut Entry<'_>,
    layout: VectorLayout,
    associated: Vec<Vec<TaskValue>>,
) -> Result<Handle, Trap> {
    let mut roots = entry.roots()?;
    roots.extend(associated.iter().flatten().filter_map(|value| value.root()));
    let vector = pseudolearn_runtime::new_vector(&mut entry.engine.heap, layout, &roots)?;
    roots.push(vector);
    for (index, error) in associated.into_iter().enumerate() {
        let mut words = CollectionWords::default();
        for value in error {
            match value {
                TaskValue::Scalar(word) => words.scalars.push(word),
                TaskValue::Reference(handle) => words.references.push(Handle(handle)),
            }
        }
        let position = i64::try_from(index).map_err(|_| Trap::named("internalFault"))?;
        pseudolearn_runtime::vector_insert(
            &mut entry.engine.heap,
            vector,
            (position, words),
            &roots,
        )?;
    }
    Ok(vector)
}
