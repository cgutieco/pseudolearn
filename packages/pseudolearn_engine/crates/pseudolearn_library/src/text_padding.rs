#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryError;

pub const MAXIMUM_PADDING_WIDTH: usize = 1 << 24;

pub fn pad_left(
    text: &str,
    width: i64,
    fill: &str,
    maximum_points: u64,
) -> Result<String, MemoryError> {
    let plan = plan_padding(text, width, fill, maximum_points)?;
    Ok(build(text, &plan, true))
}

pub fn pad_right(
    text: &str,
    width: i64,
    fill: &str,
    maximum_points: u64,
) -> Result<String, MemoryError> {
    let plan = plan_padding(text, width, fill, maximum_points)?;
    Ok(build(text, &plan, false))
}

struct PaddingPlan {
    fill: char,
    missing: usize,
}

fn build(text: &str, plan: &PaddingPlan, before: bool) -> String {
    let mut result = String::with_capacity(
        text.len()
            .saturating_add(plan.missing.saturating_mul(plan.fill.len_utf8())),
    );
    if !before {
        result.push_str(text);
    }
    result.extend(std::iter::repeat_n(plan.fill, plan.missing));
    if before {
        result.push_str(text);
    }
    result
}

fn plan_padding(
    text: &str,
    width: i64,
    fill: &str,
    maximum_points: u64,
) -> Result<PaddingPlan, MemoryError> {
    let mut points = fill.chars();
    let (Some(fill), None) = (points.next(), points.next()) else {
        return Err(MemoryError::InvalidPaddingText);
    };
    let width = usize::try_from(width).map_err(|_| MemoryError::PaddingWidthOutOfRange)?;
    if width > MAXIMUM_PADDING_WIDTH {
        return Err(MemoryError::CellLimit);
    }
    let length = text.chars().count();
    let result_points = u64::try_from(width.max(length)).map_err(|_| MemoryError::Resource)?;
    if result_points > maximum_points {
        return Err(MemoryError::CellLimit);
    }
    Ok(PaddingPlan {
        fill,
        missing: width.saturating_sub(length),
    })
}
