use crate::cells::rooted_handles;
use crate::task_state::AotTasks;
use crate::task_values::TaskValue;
use pseudolearn_runtime::{ChannelReply, Handle};

pub(crate) fn extend_roots(tasks: &AotTasks, handles: &mut Vec<Handle>) {
    suspended_roots(tasks, handles);
    value_roots(tasks, handles);
}

fn suspended_roots(tasks: &AotTasks, handles: &mut Vec<Handle>) {
    for frames in tasks.suspended.values() {
        let top = usize::try_from(frames.root_top).unwrap_or(0);
        handles.extend(
            frames
                .roots
                .iter()
                .take(top)
                .copied()
                .filter(|handle| *handle != 0)
                .map(Handle),
        );
        handles.extend(rooted_handles(&frames.cells));
    }
}

fn value_roots(tasks: &AotTasks, handles: &mut Vec<Handle>) {
    let starts = tasks
        .pending_starts
        .values()
        .flat_map(|start| start.arguments.iter());
    let replies = tasks
        .channel_replies
        .values()
        .filter_map(reply_values)
        .flatten();
    let values = pseudolearn_runtime::channel_values(&tasks.channels)
        .flatten()
        .chain(tasks.transport_values.values().flatten().flatten())
        .chain(replies)
        .chain(tasks.results.values().flatten())
        .chain(tasks.task_values.values().flatten())
        .chain(tasks.outcomes.values().flat_map(|(_, values)| values))
        .chain(
            tasks
                .failures
                .values()
                .flat_map(|failure| failure.errors())
                .flatten(),
        )
        .chain(starts);
    handles.extend(values.copied().filter_map(TaskValue::root));
    handles.extend(tasks.task_storage.values().copied());
}

fn reply_values(reply: &ChannelReply<Vec<TaskValue>>) -> Option<&Vec<TaskValue>> {
    match reply {
        ChannelReply::Received(value) | ChannelReply::Selected(_, value) => value.as_ref(),
        ChannelReply::Sent(_) => None,
    }
}
