const FRACTION_MASK: u64 = (1_u64 << 52) - 1;
const SIGN_MASK: u64 = 1_u64 << 63;

pub(crate) fn integer_to_real(value: i64) -> f64 {
    let magnitude = value.unsigned_abs();
    if magnitude == 0 {
        return 0.0;
    }
    let highest_bit = 63_u32.saturating_sub(magnitude.leading_zeros());
    let exponent = 1023_u64 + u64::from(highest_bit);
    let significand = rounded_significand(magnitude, highest_bit);
    let (adjusted_exponent, fraction) = if significand == (1_u64 << 53) {
        (exponent.saturating_add(1), 0)
    } else {
        (exponent, significand & FRACTION_MASK)
    };
    let sign = if value.is_negative() { SIGN_MASK } else { 0 };
    f64::from_bits(sign | (adjusted_exponent << 52) | fraction)
}

fn rounded_significand(magnitude: u64, highest_bit: u32) -> u64 {
    if highest_bit <= 52 {
        let shift = 52_u32.saturating_sub(highest_bit);
        return magnitude.checked_shl(shift).unwrap_or(0);
    }
    let shift = highest_bit.saturating_sub(52);
    let truncated = magnitude >> shift;
    let discarded_mask = 1_u64.checked_shl(shift).unwrap_or(0).saturating_sub(1);
    let discarded = magnitude & discarded_mask;
    let halfway = 1_u64.checked_shl(shift.saturating_sub(1)).unwrap_or(0);
    if discarded > halfway || (discarded == halfway && truncated & 1 == 1) {
        truncated.saturating_add(1)
    } else {
        truncated
    }
}
