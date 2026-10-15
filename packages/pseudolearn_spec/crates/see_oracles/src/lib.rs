#![forbid(unsafe_code)]

pub mod cells;
mod dyadic;
pub mod integer_expression;
pub mod interval;
pub mod mathematics;
mod rational;
pub mod rounding;
mod series;
mod transcendentals;

pub fn integer_sum(left: i64, right: i64) -> Result<i64, String> {
    let mathematical = i128::from(left)
        .checked_add(i128::from(right))
        .ok_or("Oracle overflow")?;
    i64::try_from(mathematical).map_err(|_| "integerOverflow".to_owned())
}

pub fn iterations(initial: i64, final_value: i64, step: i64) -> Result<u64, String> {
    if step == 0 {
        return Err("forStepZero".to_owned());
    }
    let distance = i128::from(final_value)
        .checked_sub(i128::from(initial))
        .ok_or("Oracle overflow")?;
    if (distance < 0 && step > 0) || (distance > 0 && step < 0) {
        return Ok(0);
    }
    let count = distance
        .checked_div(i128::from(step))
        .and_then(|count| count.checked_add(1))
        .ok_or("Oracle overflow")?;
    u64::try_from(count).map_err(|_| "Oracle count out of range".to_owned())
}
