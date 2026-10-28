use super::{ChannelError, ChannelReply, ChannelStep, TaskChannels};
use crate::{TaskChannelId, TaskId};

impl<Value> TaskChannels<Value> {
    pub fn select(
        &mut self,
        channels: &[TaskChannelId],
        task: TaskId,
    ) -> Result<ChannelStep<(usize, Option<Value>)>, ChannelError> {
        if channels.len() < 2 {
            return Err(ChannelError::InsufficientBranches);
        }
        if channels
            .iter()
            .any(|channel| !self.channels.contains_key(channel))
        {
            return Err(ChannelError::UnknownChannel);
        }
        for (branch, channel) in channels.iter().enumerate() {
            let stream = self
                .channels
                .get(channel)
                .ok_or(ChannelError::UnknownChannel)?;
            if stream.closed || !stream.values.is_empty() {
                let ChannelStep::Ready(value) = self.receive(*channel, task)? else {
                    return Err(ChannelError::UnknownChannel);
                };
                return Ok(ChannelStep::Ready((branch, value)));
            }
        }
        for (branch, channel) in channels.iter().enumerate() {
            let stream = self
                .channels
                .get_mut(channel)
                .ok_or(ChannelError::UnknownChannel)?;
            stream.receivers.push(task, Some(branch));
        }
        Ok(ChannelStep::Waiting)
    }

    pub fn cancel(&mut self, task: TaskId) {
        self.unregister(task);
        self.ready.retain(|(waiting, _)| *waiting != task);
    }

    pub fn take_ready(&mut self) -> Option<(TaskId, ChannelReply<Value>)> {
        self.ready.pop_front()
    }
}
