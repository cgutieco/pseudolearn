use crate::rational::{self, Rational};
use num_bigint::BigInt;
use num_traits::{Pow, Signed, ToPrimitive};

const EXACT_BIT_BUDGET: u64 = 1 << 17;

pub(crate) fn dyadic_power(base: &Rational, exponent: &Rational) -> Result<Option<f64>, String> {
    let Some(depth) = root_depth(exponent) else {
        return Ok(None);
    };
    let Some(root) = exact_root(base, depth) else {
        return Ok(None);
    };
    let numerator = exponent.numer();
    let bits = root.numer().bits().saturating_add(root.denom().bits());
    let Some(magnitude) = numerator.abs().to_u64() else {
        return Ok(None);
    };
    if bits.saturating_mul(magnitude) > EXACT_BIT_BUDGET {
        return Ok(None);
    }
    let count = u32::try_from(magnitude).map_err(|_| rational::arithmetic_error())?;
    let raised = Pow::pow(&root, count);
    let value = if numerator.is_negative() {
        rational::divide(&rational::integer(1), &raised)?
    } else {
        raised
    };
    crate::rounding::round_binary64(&value).map(Some)
}

fn root_depth(exponent: &Rational) -> Option<u32> {
    let denominator = exponent.denom();
    let zeros = denominator.trailing_zeros()?;
    let power = rational::power_two(i64::try_from(zeros).ok()?).ok()?;
    (power == Rational::from_integer(denominator.clone())).then(|| u32::try_from(zeros).ok())?
}

fn exact_root(base: &Rational, depth: u32) -> Option<Rational> {
    let mut numerator = base.numer().clone();
    let mut denominator = base.denom().clone();
    for _ in 0..depth {
        numerator = exact_square_root(&numerator)?;
        denominator = exact_square_root(&denominator)?;
    }
    Some(Rational::new(numerator, denominator))
}

fn exact_square_root(value: &BigInt) -> Option<BigInt> {
    let root = value.sqrt();
    (root.checked_mul(&root)? == *value).then_some(root)
}
