use crate::wait_queue::WaitQueue;
use crate::{TaskChannelId, TaskId};
use std::collections::{BTreeMap, VecDeque};

#[path = "channel_selection.rs"]
mod channel_selection;
pub use channel_selection::{buffered_slot, pending_values, take_buffer_change};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ChannelError {
    InvalidCapacity,
    CapacityExceeded,
    IdentityExhausted,
    UnknownChannel,
    InsufficientBranches,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ChannelStep<Value> {
    Ready(Value),
    Waiting,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ChannelReply<Value> {
    Sent(bool),
    Received(Option<Value>),
    Selected(usize, Option<Value>),
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct TaskChannel<Value> {
    head: usize,
    capacity: usize,
    closed: bool,
    values: VecDeque<Value>,
    senders: WaitQueue<Value>,
    receivers: WaitQueue<Option<usize>>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct TaskChannels<Value> {
    changed: VecDeque<(TaskChannelId, usize)>,
    next_channel: u64,
    channels: BTreeMap<TaskChannelId, TaskChannel<Value>>,
    ready: VecDeque<(TaskId, ChannelReply<Value>)>,
}

impl<Value> Default for TaskChannels<Value> {
    fn default() -> Self {
        Self {
            changed: VecDeque::new(),
            next_channel: 1,
            channels: BTreeMap::new(),
            ready: VecDeque::new(),
        }
    }
}

impl<Value> TaskChannels<Value> {
    pub fn create(
        &mut self,
        capacity: usize,
        maximum: usize,
    ) -> Result<TaskChannelId, ChannelError> {
        if capacity == 0 {
            return Err(ChannelError::InvalidCapacity);
        }
        if capacity > maximum {
            return Err(ChannelError::CapacityExceeded);
        }
        let identifier = TaskChannelId(self.next_channel);
        self.next_channel = self
            .next_channel
            .checked_add(1)
            .ok_or(ChannelError::IdentityExhausted)?;
        self.channels.insert(
            identifier,
            TaskChannel {
                head: 0,
                capacity,
                closed: false,
                values: VecDeque::new(),
                senders: WaitQueue::default(),
                receivers: WaitQueue::default(),
            },
        );
        Ok(identifier)
    }

    pub fn send(
        &mut self,
        channel: TaskChannelId,
        task: TaskId,
        value: Value,
    ) -> Result<ChannelStep<bool>, ChannelError> {
        let stream = self
            .channels
            .get_mut(&channel)
            .ok_or(ChannelError::UnknownChannel)?;
        if stream.closed {
            return Ok(ChannelStep::Ready(false));
        }
        if let Some((receiver, branch)) = stream.receivers.pop() {
            self.deliver(receiver, branch, Some(value));
            return Ok(ChannelStep::Ready(true));
        }
        if stream.values.len() < stream.capacity {
            let slot = stream
                .head
                .saturating_add(stream.values.len())
                .checked_rem(stream.capacity)
                .ok_or(ChannelError::InvalidCapacity)?;
            stream.values.push_back(value);
            self.changed.push_back((channel, slot));
            Ok(ChannelStep::Ready(true))
        } else {
            stream.senders.push(task, value);
            Ok(ChannelStep::Waiting)
        }
    }

    pub fn receive(
        &mut self,
        channel: TaskChannelId,
        task: TaskId,
    ) -> Result<ChannelStep<Option<Value>>, ChannelError> {
        let stream = self
            .channels
            .get_mut(&channel)
            .ok_or(ChannelError::UnknownChannel)?;
        if let Some(value) = stream.values.pop_front() {
            self.changed.push_back((channel, stream.head));
            stream.head = stream
                .head
                .saturating_add(1)
                .checked_rem(stream.capacity)
                .ok_or(ChannelError::InvalidCapacity)?;
            if let Some((sender, pending)) = stream.senders.pop() {
                let slot = stream
                    .head
                    .saturating_add(stream.values.len())
                    .checked_rem(stream.capacity)
                    .ok_or(ChannelError::InvalidCapacity)?;
                stream.values.push_back(pending);
                self.changed.push_back((channel, slot));
                self.ready.push_back((sender, ChannelReply::Sent(true)));
            }
            return Ok(ChannelStep::Ready(Some(value)));
        }
        if stream.closed {
            return Ok(ChannelStep::Ready(None));
        }
        stream.receivers.push(task, None);
        Ok(ChannelStep::Waiting)
    }

    pub fn close(&mut self, channel: TaskChannelId) -> Result<(), ChannelError> {
        let stream = self
            .channels
            .get_mut(&channel)
            .ok_or(ChannelError::UnknownChannel)?;
        stream.closed = true;
        while let Some((sender, _)) = stream.senders.pop() {
            self.ready.push_back((sender, ChannelReply::Sent(false)));
        }
        loop {
            let receiver = self
                .channels
                .get_mut(&channel)
                .and_then(|stream| stream.receivers.pop());
            let Some((receiver, branch)) = receiver else {
                break;
            };
            self.deliver(receiver, branch, None);
        }
        Ok(())
    }

    fn deliver(&mut self, task: TaskId, branch: Option<usize>, value: Option<Value>) {
        let reply = match branch {
            Some(branch) => {
                self.unregister(task);
                ChannelReply::Selected(branch, value)
            }
            None => ChannelReply::Received(value),
        };
        self.ready.push_back((task, reply));
    }

    fn unregister(&mut self, task: TaskId) {
        for stream in self.channels.values_mut() {
            stream.senders.remove(task);
            stream.receivers.remove(task);
        }
    }
}

pub fn channel_values<Value>(channels: &TaskChannels<Value>) -> impl Iterator<Item = &Value> {
    let buffered = channels
        .channels
        .values()
        .flat_map(|channel| channel.values.iter().chain(channel.senders.values()));
    let delivered = channels.ready.iter().filter_map(|(_, reply)| match reply {
        ChannelReply::Received(value) | ChannelReply::Selected(_, value) => value.as_ref(),
        ChannelReply::Sent(_) => None,
    });
    buffered.chain(delivered)
}
