use crate::machine::{Arithmetic, Outcome, RealOperation, Trap, apply, finite};

pub trait ImmediateArithmetic {}

impl<Implementation: ImmediateArithmetic> Arithmetic for Implementation {
    #[inline(always)]
    fn add(&mut self, left: i64, right: i64) -> Outcome<i64> {
        left.checked_add(right).ok_or(Trap::IntegerOverflow)
    }

    #[inline(always)]
    fn subtract(&mut self, left: i64, right: i64) -> Outcome<i64> {
        left.checked_sub(right).ok_or(Trap::IntegerOverflow)
    }

    #[inline(always)]
    fn multiply(&mut self, left: i64, right: i64) -> Outcome<i64> {
        left.checked_mul(right).ok_or(Trap::IntegerOverflow)
    }

    #[inline(always)]
    fn quotient(&mut self, left: i64, right: i64) -> Outcome<i64> {
        if right == 0 {
            return Err(Trap::DivisionByZero);
        }
        left.checked_div(right).ok_or(Trap::IntegerOverflow)
    }

    #[inline(always)]
    fn remainder(&mut self, left: i64, right: i64) -> Outcome<i64> {
        if right == 0 {
            return Err(Trap::DivisionByZero);
        }
        Ok(left.checked_rem(right).unwrap_or(0))
    }

    #[inline(always)]
    fn real(&mut self, operation: RealOperation, left: f64, right: f64) -> Outcome<f64> {
        if operation == RealOperation::Divide && right == 0.0 {
            return Err(Trap::DivisionByZero);
        }
        finite(apply(operation, left, right))
    }

    #[inline(always)]
    fn root(&mut self, value: f64) -> Outcome<f64> {
        finite(value.sqrt())
    }

    #[inline(always)]
    fn settle(&mut self) -> Outcome<()> {
        Ok(())
    }
}
