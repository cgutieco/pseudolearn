use crate::trap::Trap;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_runtime::HostValue;

pub(crate) const BYTES_AT: &str = "bytes_at";

pub(crate) fn with_bytes_index(
    trap: Trap,
    (operation, size): (&str, Option<usize>),
    arguments: &[HostValue],
) -> Trap {
    if trap.code != Some(DiagnosticCode::ArrayIndexOutOfRange) || operation != BYTES_AT {
        return trap;
    }
    let (Some(HostValue::Integer(index)), Some(size)) = (arguments.first(), size) else {
        return trap;
    };
    trap.argument("index", index).argument("size", size)
}
