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
    let last = match arguments.get(2) {
        Some(HostValue::Integer(last)) => Some(*last),
        _ => None,
    };
    let length = text.chars().count();
    let position = pseudolearn_library::substring_fault_position(
        u64::try_from(length).unwrap_or(u64::MAX),
        *start,
        last,
    );
    trap.argument("length", length)
        .argument("position", position)
}
