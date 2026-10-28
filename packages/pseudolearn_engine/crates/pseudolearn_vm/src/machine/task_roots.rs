use super::tasks::VmTasks;
use crate::RuntimeValue;
use pseudolearn_runtime::{ChannelReply, Handle};

impl VmTasks {
    pub(super) fn value_roots(&self) -> Vec<pseudolearn_runtime::Handle> {
        let pending = self.channel_replies.values().filter_map(reply_values);
        let values = pseudolearn_runtime::channel_values(&self.channels)
            .chain(self.transport_values.values().flatten())
            .chain(pending)
            .flatten();
        values
            .copied()
            .chain(self.results.values().copied().flatten())
            .chain(
                self.channel_storage
                    .values()
                    .map(|handle| RuntimeValue::Reference(handle.0)),
            )
            .chain(self.task_values.values().flatten().copied())
            .chain(
                self.outcomes
                    .values()
                    .flat_map(|(_, values)| values)
                    .copied(),
            )
            .chain(
                self.failures
                    .values()
                    .flat_map(|failure| failure.errors())
                    .flatten()
                    .copied(),
            )
            .filter_map(reference_root)
            .collect()
    }
}

fn reply_values(reply: &ChannelReply<Vec<RuntimeValue>>) -> Option<&Vec<RuntimeValue>> {
    match reply {
        ChannelReply::Received(value) | ChannelReply::Selected(_, value) => value.as_ref(),
        _ => None,
    }
}

fn reference_root(value: RuntimeValue) -> Option<Handle> {
    match value {
        RuntimeValue::Reference(handle) if handle != 0 => Some(Handle(handle)),
        _ => None,
    }
}
