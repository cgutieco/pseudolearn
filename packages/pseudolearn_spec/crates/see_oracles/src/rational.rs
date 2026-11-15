use num_bigint::BigInt;
use num_rational::BigRational;
use num_traits::{CheckedAdd, CheckedDiv, CheckedMul, CheckedSub, One, Zero};

pub(crate) type Rational = BigRational;

pub(crate) fn integer(value: i64) -> Rational {
    Rational::from_integer(BigInt::from(value))
}

pub(crate) fn add(left: &Rational, right: &Rational) -> Result<Rational, String> {
    left.checked_add(right).ok_or_else(arithmetic_error)
}

pub(crate) fn subtract(left: &Rational, right: &Rational) -> Result<Rational, String> {
    left.checked_sub(right).ok_or_else(arithmetic_error)
}

pub(crate) fn multiply(left: &Rational, right: &Rational) -> Result<Rational, String> {
    left.checked_mul(right).ok_or_else(arithmetic_error)
}

pub(crate) fn divide(left: &Rational, right: &Rational) -> Result<Rational, String> {
    left.checked_div(right).ok_or_else(arithmetic_error)
}

pub(crate) fn power_two(exponent: i64) -> Result<Rational, String> {
    let magnitude = usize::try_from(exponent.unsigned_abs()).map_err(|_| arithmetic_error())?;
    let shifted = std::ops::Shl::shl(BigInt::one(), magnitude);
    Ok(if exponent < 0 {
        Rational::new(BigInt::one(), shifted)
    } else {
        Rational::from_integer(shifted)
    })
}

pub(crate) fn exact(value: f64) -> Result<Rational, String> {
    if !value.is_finite() {
        return Err("ORACLE-NON-FINITE-ARGUMENT".to_owned());
    }
    let bits = value.to_bits();
    let exponent = i64::try_from((bits >> 52) & 0x7ff).map_err(|_| arithmetic_error())?;
    let fraction = bits & 0x000f_ffff_ffff_ffff;
    let mantissa = if exponent == 0 {
        fraction
    } else {
        fraction | (1 << 52)
    };
    let signed = Rational::from_integer(BigInt::from(mantissa));
    let scale = power_two(
        exponent
            .max(1)
            .checked_sub(1075)
            .ok_or_else(arithmetic_error)?,
    )?;
    let result = multiply(&signed, &scale)?;
    if bits >> 63 == 0 {
        Ok(result)
    } else {
        subtract(&Rational::zero(), &result)
    }
}

pub(crate) fn arithmetic_error() -> String {
    "ORACLE-ARITHMETIC".to_owned()
}

pub(crate) fn epsilon(precision: i64) -> Result<Rational, String> {
    power_two(precision.checked_neg().ok_or_else(arithmetic_error)?)
}
