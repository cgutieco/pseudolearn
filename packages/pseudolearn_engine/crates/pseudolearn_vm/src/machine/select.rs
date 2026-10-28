use super::{Flow, Machine};
use crate::{Fault, RuntimeValue, evaluate::INVALID_BYTECODE};
use pseudolearn_bytecode::Register;
use pseudolearn_runtime::{ChannelReply, ChannelStep, TaskChannelId};

impl Machine<'_> {
    pub(super) fn select_channels(
        &mut self,
        arguments: &[RuntimeValue],
        destination: Register,
    ) -> Result<Flow, Fault> {
        let channels = arguments
            .iter()
            .map(|value| self.channel_identity(*value).map(TaskChannelId))
            .collect::<Result<Vec<_>, _>>()?;
        let step = match self.tasks.channel_replies.remove(&self.tasks.current) {
            Some(ChannelReply::Selected(branch, value)) => ChannelStep::Ready((branch, value)),
            Some(_) => return Err(INVALID_BYTECODE),
            None => self
                .tasks
                .channels
                .select(&channels, self.tasks.current)
                .map_err(super::channels::channel_fault)?,
        };
        self.wake_channel_tasks()?;
        match step {
            ChannelStep::Ready((branch, value)) => {
                self.set_scalar(
                    destination.index,
                    u64::try_from(branch).map_err(|_| INVALID_BYTECODE)?,
                )?;
                self.tasks
                    .transport_values
                    .insert(self.tasks.current, value);
                Ok(Flow::Continue)
            }
            ChannelStep::Waiting => {
                self.wait_for_channel(*channels.first().ok_or(INVALID_BYTECODE)?)
            }
        }
    }
}
