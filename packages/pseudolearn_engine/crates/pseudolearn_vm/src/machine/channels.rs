use super::{Flow, Machine};
use crate::{Fault, RuntimeValue, evaluate::INVALID_BYTECODE};
use pseudolearn_bytecode::{Register, RegisterClass};
use pseudolearn_runtime::{ChannelError, ChannelReply, ChannelStep, TaskChannelId};

impl Machine<'_> {
    pub(crate) fn channel_operation(&mut self, site: u32) -> Result<Flow, Fault> {
        let site = self
            .current
            .channel_sites
            .get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?)
            .cloned()
            .ok_or(INVALID_BYTECODE)?;
        let arguments = site
            .arguments
            .iter()
            .map(|register| self.channel_argument(*register))
            .collect::<Result<Vec<_>, _>>()?;
        self.run_channel_command(&site.command, site.destination, &arguments)
    }

    fn run_channel_command(
        &mut self,
        command: &str,
        destination: Register,
        arguments: &[RuntimeValue],
    ) -> Result<Flow, Fault> {
        if command == "new" {
            return self.create_channel_result(destination, arguments);
        }
        let channel = arguments
            .first()
            .and_then(|value| self.channel_identity(*value).ok());
        let status = match command {
            "send" => {
                return self.channel_send(
                    TaskChannelId(channel.ok_or(INVALID_BYTECODE)?),
                    destination,
                    arguments,
                );
            }
            "receive" => {
                return self
                    .channel_receive(TaskChannelId(channel.ok_or(INVALID_BYTECODE)?), destination);
            }
            "close" => self.close_task_channel(TaskChannelId(channel.ok_or(INVALID_BYTECODE)?))?,
            "select" => return self.select_channels(arguments, destination),
            "selected_present" => u64::from(
                self.tasks
                    .transport_values
                    .get(&self.tasks.current)
                    .is_some_and(Option::is_some),
            ),
            _ => return Err(INVALID_BYTECODE),
        };
        self.set_scalar(destination.index, status)?;
        Ok(Flow::Continue)
    }

    fn create_channel_result(
        &mut self,
        destination: Register,
        arguments: &[RuntimeValue],
    ) -> Result<Flow, Fault> {
        let handle = self.new_task_channel(arguments)?;
        self.set_reference(
            destination.index,
            u32::try_from(handle).map_err(|_| INVALID_BYTECODE)?,
        )?;
        Ok(Flow::Continue)
    }

    fn close_task_channel(&mut self, channel: TaskChannelId) -> Result<u64, Fault> {
        self.tasks.channels.close(channel).map_err(channel_fault)?;
        self.wake_channel_tasks()?;
        Ok(0)
    }

    pub(super) fn channel_argument(&self, register: Register) -> Result<RuntimeValue, Fault> {
        match register.class {
            RegisterClass::Scalar => self.scalar(register.index).map(RuntimeValue::Scalar),
            RegisterClass::Reference => self.reference(register.index).map(RuntimeValue::Reference),
        }
    }

    fn new_task_channel(&mut self, arguments: &[RuntimeValue]) -> Result<u64, Fault> {
        let capacity = channel_capacity(arguments)?;
        let Some(RuntimeValue::Scalar(width)) = arguments.get(1) else {
            return Err(INVALID_BYTECODE);
        };
        let layout = pseudolearn_runtime::ChannelLayout::new(
            u32::try_from(capacity).map_err(|_| "channelCapacityExceeded")?,
            u32::try_from(*width).map_err(|_| "resourceLimit")?,
        )
        .ok_or("resourceLimit")?;
        let roots = self.memory_roots()?;
        let storage = pseudolearn_runtime::new_channel_storage(&mut self.heap, layout, &roots)
            .map_err(super::memory::memory_fault)?;
        let channel = self
            .tasks
            .channels
            .create(capacity, 65_536)
            .map_err(channel_fault)?;
        self.tasks.channel_storage.insert(channel, storage);
        pseudolearn_runtime::channel_references::set_channel_identity(
            &mut self.heap,
            storage,
            channel.0,
        )
        .map_err(super::memory::memory_fault)?;
        Ok(u64::from(storage.0))
    }

    fn channel_send(
        &mut self,
        channel: TaskChannelId,
        destination: Register,
        arguments: &[RuntimeValue],
    ) -> Result<Flow, Fault> {
        let pending = self.tasks.channel_replies.remove(&self.tasks.current);
        let step = match pending {
            Some(ChannelReply::Sent(sent)) => ChannelStep::Ready(sent),
            Some(_) => return Err(INVALID_BYTECODE),
            None => self
                .tasks
                .channels
                .send(
                    channel,
                    self.tasks.current,
                    arguments.get(1..).ok_or(INVALID_BYTECODE)?.to_vec(),
                )
                .map_err(channel_fault)?,
        };
        self.wake_channel_tasks()?;
        match step {
            ChannelStep::Ready(sent) => {
                self.set_scalar(destination.index, u64::from(sent))?;
                Ok(Flow::Continue)
            }
            ChannelStep::Waiting => self.wait_for_channel(channel),
        }
    }

    fn channel_receive(
        &mut self,
        channel: TaskChannelId,
        destination: Register,
    ) -> Result<Flow, Fault> {
        let step = match self.tasks.channel_replies.remove(&self.tasks.current) {
            Some(ChannelReply::Received(value)) => ChannelStep::Ready(value),
            Some(_) => return Err(INVALID_BYTECODE),
            None => self
                .tasks
                .channels
                .receive(channel, self.tasks.current)
                .map_err(channel_fault)?,
        };
        self.wake_channel_tasks()?;
        match step {
            ChannelStep::Ready(value) => {
                self.set_scalar(destination.index, u64::from(value.is_some()))?;
                self.tasks
                    .transport_values
                    .insert(self.tasks.current, value);
                Ok(Flow::Continue)
            }
            ChannelStep::Waiting => self.wait_for_channel(channel),
        }
    }

    pub(crate) fn channel_load(
        &mut self,
        destination: Register,
        index: u32,
    ) -> Result<Flow, Fault> {
        let value = self
            .tasks
            .transport_values
            .get(&self.tasks.current)
            .and_then(Option::as_ref)
            .and_then(|values| values.get(usize::try_from(index).ok()?))
            .copied();
        match (destination.class, value) {
            (RegisterClass::Scalar, Some(RuntimeValue::Scalar(word))) => {
                self.set_scalar(destination.index, word)?
            }
            (RegisterClass::Reference, Some(RuntimeValue::Reference(handle))) => {
                self.set_reference(destination.index, handle)?
            }
            (RegisterClass::Scalar, None) => self.set_scalar(destination.index, 0)?,
            (RegisterClass::Reference, None) => self.set_reference(destination.index, 0)?,
            _ => return Err(INVALID_BYTECODE),
        }
        Ok(Flow::Continue)
    }

    pub(super) fn wait_for_channel(&mut self, channel: TaskChannelId) -> Result<Flow, Fault> {
        self.cursor.program_counter = self
            .cursor
            .program_counter
            .checked_sub(1)
            .ok_or(INVALID_BYTECODE)?;
        self.tasks
            .agenda
            .execution()
            .waiting()
            .for_channel(self.tasks.current, channel)
            .map_err(super::tasks::task_fault)?;
        self.schedule_next(true, true)?;
        Ok(Flow::Continue)
    }

    pub(super) fn wake_channel_tasks(&mut self) -> Result<(), Fault> {
        self.flush_channel_buffers()?;
        while let Some((task, reply)) = self.tasks.channels.take_ready() {
            self.tasks.channel_replies.insert(task, reply);
            self.tasks
                .agenda
                .execution()
                .resume(task)
                .map_err(super::tasks::task_fault)?;
        }
        Ok(())
    }
}

pub(super) fn channel_fault(error: ChannelError) -> Fault {
    match error {
        ChannelError::InvalidCapacity => "channelCapacityInvalid",
        ChannelError::CapacityExceeded => "channelCapacityExceeded",
        ChannelError::IdentityExhausted => "resourceLimit",
        ChannelError::UnknownChannel | ChannelError::InsufficientBranches => INVALID_BYTECODE,
    }
}

fn channel_capacity(arguments: &[RuntimeValue]) -> Result<usize, Fault> {
    let Some(RuntimeValue::Scalar(capacity)) = arguments.first() else {
        return Err(INVALID_BYTECODE);
    };
    let capacity = usize::try_from(*capacity).map_err(|_| "channelCapacityInvalid")?;
    if capacity == 0 || capacity > usize::try_from(i64::MAX).unwrap_or(usize::MAX) {
        return Err("channelCapacityInvalid");
    }
    if capacity > 65_536 {
        return Err("channelCapacityExceeded");
    }
    Ok(capacity)
}
