use crate::context::AotRuntimeContext;
use crate::guard::run_entry;
use crate::trap::Trap;
use pseudolearn_library::{
    arc_cosine, arc_sine, arc_tangent2, arctangent, ceiling_real, cosine, exponential, floor_real,
    logarithm2, logarithm10, natural_logarithm, real_power, round_real, sine, tangent,
    truncate_real,
};
use pseudolearn_runtime::int_power;

pub const MATH_SINE: u32 = 0;
pub const MATH_COSINE: u32 = 1;
pub const MATH_ARCTANGENT: u32 = 2;
pub const MATH_LOGARITHM: u32 = 3;
pub const MATH_EXPONENTIAL: u32 = 4;
pub const MATH_TRUNCATE: u32 = 5;
pub const MATH_ROUND: u32 = 6;
pub const MATH_TANGENT: u32 = 7;
pub const MATH_ARC_SINE: u32 = 8;
pub const MATH_ARC_COSINE: u32 = 9;
pub const MATH_LOGARITHM2: u32 = 10;
pub const MATH_LOGARITHM10: u32 = 11;
pub const MATH_FLOOR: u32 = 12;
pub const MATH_CEILING: u32 = 13;
pub const MATH_ARC_TANGENT2: u32 = 0;
pub const MATH_REAL_MINIMUM: u32 = 1;
pub const MATH_REAL_MAXIMUM: u32 = 2;

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
pub extern "C" fn rt_aot_math_binary(
    context: *mut AotRuntimeContext,
    site: u32,
    operation: u32,
    operands: *const u64,
) -> u32 {
    let pair = crate::guard::borrow_slice(operands, 2).map(<[u64]>::to_vec);
    run_entry(context, site, |_| match pair.as_deref() {
        Some([left, right]) => binary(operation, *left, *right),
        _ => Err(Trap::named("internalFault")),
    })
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

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_integer_power(
    context: *mut AotRuntimeContext,
    site: u32,
    base: i64,
    exponent: i64,
) -> u32 {
    run_entry(context, site, |_| {
        let value = int_power(base, exponent).map_err(|error| {
            let trap = Trap::from(error);
            if exponent < 0 {
                trap.argument("exponent", exponent)
            } else {
                trap
            }
        })?;
        Ok(u64::from_ne_bytes(value.to_ne_bytes()))
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
        MATH_TANGENT => real(tangent(value)),
        MATH_ARC_SINE => real(arc_sine(value)),
        MATH_ARC_COSINE => real(arc_cosine(value)),
        MATH_LOGARITHM2 => real(logarithm2(value)),
        MATH_LOGARITHM10 => real(logarithm10(value)),
        MATH_FLOOR => integer(floor_real(value)),
        MATH_CEILING => integer(ceiling_real(value)),
        _ => Err(Trap::named("internalFault")),
    }
}

fn binary(operation: u32, left: u64, right: u64) -> Result<u64, Trap> {
    let first = f64::from_bits(left);
    let second = f64::from_bits(right);
    match operation {
        MATH_ARC_TANGENT2 => Ok(arc_tangent2(first, second)?.to_bits()),
        MATH_REAL_MINIMUM if first == 0.0 && second == 0.0 => Ok(left | right),
        MATH_REAL_MAXIMUM if first == 0.0 && second == 0.0 => Ok(left & right),
        MATH_REAL_MINIMUM => Ok(first.min(second).to_bits()),
        MATH_REAL_MAXIMUM => Ok(first.max(second).to_bits()),
        _ => Err(Trap::named("internalFault")),
    }
}
