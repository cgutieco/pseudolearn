use super::{Arguments, number};
use crate::Fault;
use crate::dispatch::CompactOp;
use crate::machine::Machine;

impl Machine<'_> {
    pub(super) fn power_arguments(
        &self,
        fault: Fault,
        operation: CompactOp,
        arguments: &mut Arguments,
    ) {
        if fault != "negativeIntegerExponent" {
            return;
        }
        let exponent = match operation {
            CompactOp::IntPowRegisterRegister { right, .. }
            | CompactOp::IntPowImmediateRegister { right, .. } => self.scalar(right).ok(),
            CompactOp::IntPowRegisterImmediate { right, .. }
            | CompactOp::IntPowImmediateImmediate { right, .. } => Some(right),
            _ => None,
        };
        if let Some(exponent) = exponent {
            number(arguments, "exponent", crate::evaluate::integer_of(exponent));
        }
    }
}
