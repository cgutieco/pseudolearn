use crate::context::{AotRuntimeContext, STATUS_CONTINUE, STATUS_FAILED};
use crate::guard::{Entry, borrow_slice, with_entry};
use crate::task_switch::{Resumed, block_current};
use crate::task_values::{TaskValue, decode_packet, packet_length};
use crate::trap::Trap;

pub(crate) enum Step {
    Done(u64),
    Block,
    BlockThenDone(u64),
}

enum Attempt {
    Finished(u32),
    Wait(Option<u64>),
}

pub(crate) fn blocking_entry(
    context: *mut AotRuntimeContext,
    site: u32,
    mut step: impl FnMut(&mut Entry<'_>) -> Result<Step, Trap>,
) -> u32 {
    loop {
        let attempt = with_entry(context, site, |entry| match step(entry) {
            Ok(Step::Done(word)) => {
                entry.context.result_word = word;
                entry.refresh();
                Attempt::Finished(STATUS_CONTINUE)
            }
            Ok(Step::Block) => Attempt::Wait(None),
            Ok(Step::BlockThenDone(word)) => Attempt::Wait(Some(word)),
            Err(trap) => Attempt::Finished(entry.fail(trap)),
        });
        let after = match attempt {
            None => return STATUS_FAILED,
            Some(Attempt::Finished(status)) => return status,
            Some(Attempt::Wait(after)) => after,
        };
        match block_current(context, site) {
            Resumed::Status(status) => return status,
            Resumed::Continue => {
                if let Some(word) = after {
                    return finish_with(context, site, word);
                }
            }
        }
    }
}

fn finish_with(context: *mut AotRuntimeContext, site: u32, word: u64) -> u32 {
    with_entry(context, site, |entry| {
        entry.context.result_word = word;
        entry.refresh();
        STATUS_CONTINUE
    })
    .unwrap_or(STATUS_FAILED)
}

pub(crate) fn packet_values(packet: *const u64) -> Result<Vec<TaskValue>, Trap> {
    let head = borrow_slice(packet, 1).ok_or_else(|| Trap::named("internalFault"))?;
    let length = packet_length(head).ok_or_else(|| Trap::named("internalFault"))?;
    let words = borrow_slice(packet, length).ok_or_else(|| Trap::named("internalFault"))?;
    decode_packet(words)
}
