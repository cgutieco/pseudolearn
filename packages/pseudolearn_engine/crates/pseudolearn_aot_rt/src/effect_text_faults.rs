use crate::trap::Trap;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_runtime::HostValue;

pub(crate) fn with_text_position(trap: Trap, arguments: &[HostValue]) -> Trap {
    if trap.code != Some(DiagnosticCode::StringPositionOutOfRange) {
        return trap;
    }
    let (Some(HostValue::Text(text)), Some(HostValue::Integer(start))) =
        (arguments.first(), arguments.get(1))
    else {
        return trap;
    };
    let ending = match arguments.get(2) {
        Some(HostValue::Integer(count)) => start.checked_add(*count),
        _ => None,
    };
    trap.argument("length", text.chars().count())
        .argument("position", ending.unwrap_or(*start))
}
