use crate::mathematics::Function;
use crate::rational::{self, Rational, integer};
use num_traits::Signed;

pub(crate) fn rounded(function: Function, argument: &Rational) -> Result<Option<f64>, String> {
    if !matches!(function, Function::Tangent | Function::ArcSine)
        || argument.abs() > rational::divide(&integer(1), &integer(4))?
    {
        return Ok(None);
    }
    let square = rational::multiply(argument, argument)?;
    let cube = rational::multiply(&argument.abs(), &square)?;
    let radius = rational::multiply(&integer(2), &cube)?;
    let lower = crate::rounding::round_binary64(&rational::subtract(argument, &radius)?)?;
    let upper = crate::rounding::round_binary64(&rational::add(argument, &radius)?)?;
    Ok((lower.to_bits() == upper.to_bits()).then_some(lower))
}
