use crate::guard::Entry;
use crate::trap::Trap;
use pseudolearn_runtime::{EffectOperation, EffectValueKind, Handle, HostReply, HostValue};
use std::io::Write;

fn internal() -> Trap {
    Trap::named("internalFault")
}

pub(crate) fn remember_exit_code(
    entry: &mut Entry<'_>,
    operation: &EffectOperation,
    reply: &HostReply,
) {
    if operation.identity != "console_set_exit_code" {
        return;
    }
    if let HostReply::Committed(HostValue::Integer(code)) = reply
        && let Ok(code) = u8::try_from(*code)
    {
        entry.engine.effects.requested_exit = code;
    }
}

pub(crate) fn echo_console(
    entry: &mut Entry<'_>,
    operation: &EffectOperation,
    reply: &HostReply,
    words: &[u64],
) -> Result<(), Trap> {
    let error_stream = operation.identity == "console_write_error";
    if !(operation.identity == "console_write" || error_stream)
        || !matches!(reply, HostReply::Committed(_))
    {
        return Ok(());
    }
    let (Some(EffectValueKind::Text), Some(word)) = (operation.parameters.first(), words.first())
    else {
        return Err(internal());
    };
    let handle = Handle(u32::try_from(*word).map_err(|_| internal())?);
    let text = pseudolearn_runtime::text_content(&entry.engine.heap, handle)?.to_owned();
    if error_stream && !entry.engine.effects.merged_errors {
        return std::io::stderr()
            .write_all(text.as_bytes())
            .map_err(|_| Trap::named("resourceLimit"));
    }
    entry
        .engine
        .streams
        .output
        .write_all(text.as_bytes())
        .map_err(|_| Trap::named("resourceLimit"))
}
