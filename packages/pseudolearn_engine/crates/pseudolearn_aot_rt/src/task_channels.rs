use crate::context::AotRuntimeContext;
use crate::guard::Entry;
use crate::task_blocking::{Step, blocking_entry, packet_values};
use crate::task_state::AotTasks;
use crate::task_values::TaskValue;
use crate::trap::Trap;
use pseudolearn_runtime::{ChannelError, ChannelReply, ChannelStep, Handle, TaskChannelId};

pub const CHANNEL_NEW: u32 = 0;
pub const CHANNEL_SEND: u32 = 1;
pub const CHANNEL_RECEIVE: u32 = 2;
pub const CHANNEL_CLOSE: u32 = 3;
pub const CHANNEL_SELECT: u32 = 4;
pub const CHANNEL_SELECTED_PRESENT: u32 = 5;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_task_channel(
    context: *mut AotRuntimeContext,
    site: u32,
    command: u32,
    packet: *const u64,
) -> u32 {
    blocking_entry(context, site, |entry| {
        let values = packet_values(packet)?;
        run_command(entry, command, &values)
    })
}

fn internal() -> Trap {
    Trap::named("internalFault")
}

fn run_command(entry: &mut Entry<'_>, command: u32, values: &[TaskValue]) -> Result<Step, Trap> {
    if command == CHANNEL_NEW {
        return create(entry, values).map(Step::Done);
    }
    if command == CHANNEL_SELECTED_PRESENT {
        let tasks = entry.engine.tasks_mut()?;
        let present = tasks
            .transport_values
            .get(&tasks.current)
            .is_some_and(Option::is_some);
        return Ok(Step::Done(u64::from(present)));
    }
    let first = identity(entry, *values.first().ok_or_else(internal)?)?;
    match command {
        CHANNEL_SEND => send(entry, first, values),
        CHANNEL_RECEIVE => receive(entry, first),
        CHANNEL_CLOSE => close(entry, first),
        CHANNEL_SELECT => {
            let channels = values
                .iter()
                .map(|value| identity(entry, *value))
                .collect::<Result<Vec<_>, _>>()?;
            select(entry, &channels)
        }
        _ => Err(internal()),
    }
}

fn identity(entry: &Entry<'_>, value: TaskValue) -> Result<TaskChannelId, Trap> {
    let TaskValue::Reference(handle) = value else {
        return Err(internal());
    };
    pseudolearn_runtime::channel_references::channel_identity(&entry.engine.heap, Handle(handle))
        .map(TaskChannelId)
        .map_err(Trap::from)
}

fn channel_fault(error: ChannelError) -> Trap {
    Trap::named(match error {
        ChannelError::InvalidCapacity => "channelCapacityInvalid",
        ChannelError::CapacityExceeded => "channelCapacityExceeded",
        ChannelError::IdentityExhausted => "resourceLimit",
        ChannelError::UnknownChannel | ChannelError::InsufficientBranches => "internalFault",
    })
}

fn create(entry: &mut Entry<'_>, values: &[TaskValue]) -> Result<u64, Trap> {
    let [TaskValue::Scalar(capacity), TaskValue::Scalar(width)] = values else {
        return Err(internal());
    };
    let maximum = entry.engine.tasks_mut()?.channel_capacity_limit;
    let capacity = capacity_of(*capacity, maximum)?;
    let layout = pseudolearn_runtime::ChannelLayout::new(
        u32::try_from(capacity).map_err(|_| Trap::named("channelCapacityExceeded"))?,
        u32::try_from(*width).map_err(|_| Trap::named("resourceLimit"))?,
    )
    .ok_or_else(|| Trap::named("resourceLimit"))?;
    let roots = entry.roots()?;
    let storage = pseudolearn_runtime::new_channel_storage(&mut entry.engine.heap, layout, &roots)?;
    let tasks = entry.engine.tasks_mut()?;
    let channel = tasks
        .channels
        .create(capacity, maximum)
        .map_err(channel_fault)?;
    tasks.channel_storage.insert(channel, storage);
    pseudolearn_runtime::channel_references::set_channel_identity(
        &mut entry.engine.heap,
        storage,
        channel.0,
    )?;
    Ok(u64::from(storage.0))
}

fn capacity_of(capacity: u64, maximum: usize) -> Result<usize, Trap> {
    let capacity = usize::try_from(capacity).map_err(|_| Trap::named("channelCapacityInvalid"))?;
    if capacity == 0 || capacity > usize::try_from(i64::MAX).unwrap_or(usize::MAX) {
        return Err(Trap::named("channelCapacityInvalid"));
    }
    if capacity > maximum {
        return Err(Trap::named("channelCapacityExceeded"));
    }
    Ok(capacity)
}

fn send(entry: &mut Entry<'_>, channel: TaskChannelId, values: &[TaskValue]) -> Result<Step, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    let step = match tasks.channel_replies.remove(&current) {
        Some(ChannelReply::Sent(sent)) => ChannelStep::Ready(sent),
        Some(_) => return Err(internal()),
        None => tasks
            .channels
            .send(
                channel,
                current,
                values.get(1..).unwrap_or_default().to_vec(),
            )
            .map_err(channel_fault)?,
    };
    wake_channel_tasks(entry)?;
    match step {
        ChannelStep::Ready(sent) => Ok(Step::Done(u64::from(sent))),
        ChannelStep::Waiting => wait(entry, channel),
    }
}

fn receive(entry: &mut Entry<'_>, channel: TaskChannelId) -> Result<Step, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    let step = match tasks.channel_replies.remove(&current) {
        Some(ChannelReply::Received(value)) => ChannelStep::Ready(value),
        Some(_) => return Err(internal()),
        None => tasks
            .channels
            .receive(channel, current)
            .map_err(channel_fault)?,
    };
    wake_channel_tasks(entry)?;
    match step {
        ChannelStep::Ready(value) => {
            let present = value.is_some();
            let tasks = entry.engine.tasks_mut()?;
            tasks.transport_values.insert(current, value);
            Ok(Step::Done(u64::from(present)))
        }
        ChannelStep::Waiting => wait(entry, channel),
    }
}

fn close(entry: &mut Entry<'_>, channel: TaskChannelId) -> Result<Step, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    tasks.channels.close(channel).map_err(channel_fault)?;
    wake_channel_tasks(entry)?;
    Ok(Step::Done(0))
}

fn select(entry: &mut Entry<'_>, channels: &[TaskChannelId]) -> Result<Step, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    let step = match tasks.channel_replies.remove(&current) {
        Some(ChannelReply::Selected(branch, value)) => ChannelStep::Ready((branch, value)),
        Some(_) => return Err(internal()),
        None => tasks
            .channels
            .select(channels, current)
            .map_err(channel_fault)?,
    };
    wake_channel_tasks(entry)?;
    match step {
        ChannelStep::Ready((branch, value)) => {
            let tasks = entry.engine.tasks_mut()?;
            tasks.transport_values.insert(current, value);
            Ok(Step::Done(u64::try_from(branch).map_err(|_| internal())?))
        }
        ChannelStep::Waiting => wait(entry, *channels.first().ok_or_else(internal)?),
    }
}

fn wait(entry: &mut Entry<'_>, channel: TaskChannelId) -> Result<Step, Trap> {
    let tasks = entry.engine.tasks_mut()?;
    let current = tasks.current;
    tasks
        .agenda
        .execution()
        .waiting()
        .for_channel(current, channel)
        .map_err(crate::task_scheduler::task_fault)?;
    Ok(Step::Block)
}

fn wake_channel_tasks(entry: &mut Entry<'_>) -> Result<(), Trap> {
    flush_channel_buffers(entry)?;
    let tasks = entry.engine.tasks_mut()?;
    while let Some((task, reply)) = tasks.channels.take_ready() {
        tasks.channel_replies.insert(task, reply);
        tasks
            .agenda
            .execution()
            .resume(task)
            .map_err(crate::task_scheduler::task_fault)?;
    }
    Ok(())
}

fn flush_channel_buffers(entry: &mut Entry<'_>) -> Result<(), Trap> {
    loop {
        let tasks: &mut AotTasks = entry.engine.tasks_mut()?;
        let Some((channel, slot)) = pseudolearn_runtime::take_buffer_change(&mut tasks.channels)
        else {
            return Ok(());
        };
        let handle = *tasks.channel_storage.get(&channel).ok_or_else(internal)?;
        let words: Vec<(u64, bool)> =
            pseudolearn_runtime::buffered_slot(&tasks.channels, channel, slot)
                .into_iter()
                .flatten()
                .map(|value| match value {
                    TaskValue::Scalar(word) => (*word, false),
                    TaskValue::Reference(handle) => (u64::from(*handle), true),
                })
                .collect();
        pseudolearn_runtime::channel_references::store_channel_slot(
            &mut entry.engine.heap,
            handle,
            slot,
            &words,
        )?;
    }
}
