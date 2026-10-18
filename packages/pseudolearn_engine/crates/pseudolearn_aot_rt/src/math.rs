use crate::context::AotRuntimeContext;
use crate::guard::run_entry;
use crate::trap::Trap;
use pseudolearn_library::{
    arctangent, cosine, exponential, natural_logarithm, real_power, round_real, sine, truncate_real,
};

pub const MATH_SINE: u32 = 0;
pub const MATH_COSINE: u32 = 1;
pub const MATH_ARCTANGENT: u32 = 2;
pub const MATH_LOGARITHM: u32 = 3;
pub const MATH_EXPONENTIAL: u32 = 4;
pub const MATH_TRUNCATE: u32 = 5;
pub const MATH_ROUND: u32 = 6;

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_math_unary(
    context: *mut AotRuntimeContext,
    site: u32,
    operation: u32,
    operand: u64,
) -> u32 {
    run_entry(context, site, |_| unary(operation, operand))
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_real_power(
    context: *mut AotRuntimeContext,
    site: u32,
    base: u64,
    exponent: u64,
) -> u32 {
    run_entry(context, site, |_| {
        let value = real_power(f64::from_bits(base), f64::from_bits(exponent))?;
        Ok(value.to_bits())
    })
}

fn unary(operation: u32, operand: u64) -> Result<u64, Trap> {
    let value = f64::from_bits(operand);
    let real = |result: Result<f64, _>| result.map(f64::to_bits).map_err(Trap::from);
    let integer = |result: Result<i64, _>| {
        result
            .map(|number| u64::from_ne_bytes(number.to_ne_bytes()))
            .map_err(Trap::from)
    };
    match operation {
        MATH_SINE => real(sine(value)),
        MATH_COSINE => real(cosine(value)),
        MATH_ARCTANGENT => real(arctangent(value)),
        MATH_LOGARITHM => real(natural_logarithm(value)),
        MATH_EXPONENTIAL => real(exponential(value)),
        MATH_TRUNCATE => integer(truncate_real(value)),
        MATH_ROUND => integer(round_real(value)),
        _ => Err(Trap::named("internalFault")),
    }
}
