#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct DecimalError;

pub fn parse_integer(text: &str) -> Result<i64, DecimalError> {
    text.parse::<i64>().map_err(|_| DecimalError)
}

pub fn parse_real(text: &str) -> Result<f64, DecimalError> {
    let value = text.parse::<f64>().map_err(|_| DecimalError)?;
    if value.is_finite() {
        Ok(value)
    } else {
        Err(DecimalError)
    }
}
