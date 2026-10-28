use crate::{ChannelError, ChannelReply, ChannelStep, TaskChannels, TaskId};

#[test]
fn capacity_bounds_are_checked_before_registration() {
    let mut channels = TaskChannels::<u64>::default();
    assert_eq!(channels.create(0, 4), Err(ChannelError::InvalidCapacity));
    assert_eq!(channels.create(5, 4), Err(ChannelError::CapacityExceeded));
    assert_eq!(channels.create(4, 4).map(|channel| channel.0), Ok(1));
}

#[test]
fn full_channel_suspends_and_receive_wakes_oldest_sender() -> Result<(), ChannelError> {
    let mut channels = TaskChannels::default();
    let channel = channels.create(1, 4)?;
    assert_eq!(
        channels.send(channel, TaskId(1), 10)?,
        ChannelStep::Ready(true)
    );
    assert_eq!(channels.send(channel, TaskId(9), 20)?, ChannelStep::Waiting);
    assert_eq!(channels.send(channel, TaskId(2), 30)?, ChannelStep::Waiting);
    assert_eq!(
        channels.receive(channel, TaskId(0))?,
        ChannelStep::Ready(Some(10))
    );
    assert_eq!(
        channels.take_ready(),
        Some((TaskId(9), ChannelReply::Sent(true)))
    );
    assert_eq!(
        channels.receive(channel, TaskId(0))?,
        ChannelStep::Ready(Some(20))
    );
    assert_eq!(
        channels.take_ready(),
        Some((TaskId(2), ChannelReply::Sent(true)))
    );
    Ok(())
}

#[test]
fn direct_delivery_wakes_first_receiver() -> Result<(), ChannelError> {
    let mut channels = TaskChannels::default();
    let channel = channels.create(4, 4)?;
    assert_eq!(channels.receive(channel, TaskId(9))?, ChannelStep::Waiting);
    assert_eq!(channels.receive(channel, TaskId(1))?, ChannelStep::Waiting);
    assert_eq!(
        channels.send(channel, TaskId(0), 42)?,
        ChannelStep::Ready(true)
    );
    assert_eq!(
        channels.take_ready(),
        Some((TaskId(9), ChannelReply::Received(Some(42))))
    );
    assert_eq!(channels.take_ready(), None);
    Ok(())
}

#[test]
fn closing_preserves_buffer_and_rejects_waiting_senders() -> Result<(), ChannelError> {
    let mut channels = TaskChannels::default();
    let channel = channels.create(1, 1)?;
    channels.send(channel, TaskId(0), 1)?;
    channels.send(channel, TaskId(1), 2)?;
    channels.close(channel)?;
    channels.close(channel)?;
    assert_eq!(
        channels.take_ready(),
        Some((TaskId(1), ChannelReply::Sent(false)))
    );
    assert_eq!(
        channels.receive(channel, TaskId(0))?,
        ChannelStep::Ready(Some(1))
    );
    assert_eq!(
        channels.receive(channel, TaskId(0))?,
        ChannelStep::Ready(None)
    );
    assert_eq!(
        channels.send(channel, TaskId(0), 3)?,
        ChannelStep::Ready(false)
    );
    Ok(())
}

#[test]
fn closed_channel_wakes_all_receivers_in_wait_order() -> Result<(), ChannelError> {
    let mut channels = TaskChannels::<u64>::default();
    let channel = channels.create(1, 1)?;
    channels.receive(channel, TaskId(9))?;
    channels.receive(channel, TaskId(1))?;
    channels.close(channel)?;
    assert_eq!(
        channels.take_ready(),
        Some((TaskId(9), ChannelReply::Received(None)))
    );
    assert_eq!(
        channels.take_ready(),
        Some((TaskId(1), ChannelReply::Received(None)))
    );
    Ok(())
}

#[test]
fn select_prefers_textual_order_and_unregisters_other_branches() -> Result<(), ChannelError> {
    let mut channels = TaskChannels::<u64>::default();
    let first = channels.create(1, 1)?;
    let second = channels.create(1, 1)?;
    channels.send(second, TaskId(0), 2)?;
    channels.send(first, TaskId(0), 1)?;
    assert_eq!(
        channels.select(&[first, second], TaskId(1))?,
        ChannelStep::Ready((0, Some(1)))
    );
    channels.receive(second, TaskId(0))?;
    assert_eq!(
        channels.select(&[first, second, second], TaskId(1))?,
        ChannelStep::Waiting
    );
    channels.close(second)?;
    assert_eq!(
        channels.take_ready(),
        Some((TaskId(1), ChannelReply::Selected(1, None)))
    );
    channels.send(first, TaskId(0), 3)?;
    assert_eq!(channels.take_ready(), None);
    assert_eq!(
        channels.receive(first, TaskId(0))?,
        ChannelStep::Ready(Some(3))
    );
    Ok(())
}

#[test]
fn cancelled_waiters_do_not_steal_values_or_wake_again() -> Result<(), ChannelError> {
    let mut channels = TaskChannels::default();
    let channel = channels.create(1, 1)?;
    channels.receive(channel, TaskId(1))?;
    channels.cancel(TaskId(1));
    channels.send(channel, TaskId(0), 7)?;
    assert_eq!(channels.take_ready(), None);
    assert_eq!(
        channels.receive(channel, TaskId(0))?,
        ChannelStep::Ready(Some(7))
    );
    assert_eq!(
        channels.select(&[channel], TaskId(0)),
        Err(ChannelError::InsufficientBranches)
    );
    Ok(())
}

#[test]
fn invalid_channel_operations_do_not_publish_partial_selection_waits() -> Result<(), ChannelError> {
    let mut channels = TaskChannels::default();
    let valid = channels.create(1, 1)?;
    let invalid = crate::TaskChannelId(99);
    assert_eq!(
        channels.send(invalid, TaskId(0), 1),
        Err(ChannelError::UnknownChannel)
    );
    assert_eq!(
        channels.receive(invalid, TaskId(0)),
        Err(ChannelError::UnknownChannel)
    );
    assert_eq!(channels.close(invalid), Err(ChannelError::UnknownChannel));
    assert_eq!(
        channels.select(&[valid, invalid], TaskId(0)),
        Err(ChannelError::UnknownChannel)
    );
    assert_eq!(
        channels.send(valid, TaskId(1), 2)?,
        ChannelStep::Ready(true)
    );
    assert_eq!(channels.take_ready(), None);
    Ok(())
}

#[test]
fn capacity_equal_to_the_maximum_is_accepted_and_one_above_is_rejected() {
    let mut channels = TaskChannels::<u8>::default();
    assert!(channels.create(4, 4).is_ok());
    assert_eq!(channels.create(5, 4), Err(ChannelError::CapacityExceeded));
}
