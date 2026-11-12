use num_bigint::BigInt;
use num_rational::BigRational;
use see_oracles::rounding::{midpoint, round_binary64};

#[test]
fn midpoint_rounds_to_even_significand() -> Result<(), String> {
    let first = 1.0_f64;
    let second = f64::from_bits(first.to_bits().checked_add(1).ok_or("bits")?);
    let third = f64::from_bits(first.to_bits().checked_add(2).ok_or("bits")?);
    assert_eq!(round_binary64(&midpoint(first, second)?)?, first);
    assert_eq!(round_binary64(&midpoint(second, third)?)?, third);
    assert_eq!(round_binary64(&midpoint(-second, -third)?)?, -third);
    Ok(())
}

#[test]
fn subnormal_ties_preserve_sign_and_even_choice() -> Result<(), String> {
    let first = f64::from_bits(1);
    let second = f64::from_bits(2);
    assert_eq!(round_binary64(&midpoint(0.0, first)?)?.to_bits(), 0);
    assert_eq!(
        round_binary64(&midpoint(-first, -0.0)?)?.to_bits(),
        1_u64 << 63
    );
    assert_eq!(round_binary64(&midpoint(first, second)?)?.to_bits(), 2);
    assert!(midpoint(f64::INFINITY, first).is_err());
    Ok(())
}

#[test]
fn overflow_rounds_at_the_exact_halfway_threshold() -> Result<(), String> {
    let maximum = BigRational::from_integer(std::ops::Shl::shl(BigInt::from(1), 1024_usize));
    let half_ulp = BigRational::from_integer(std::ops::Shl::shl(BigInt::from(1), 970_usize));
    let threshold = num_traits::CheckedSub::checked_sub(&maximum, &half_ulp).ok_or("subtract")?;
    assert_eq!(round_binary64(&threshold)?, f64::INFINITY);
    let below = num_traits::CheckedSub::checked_sub(
        &threshold,
        &BigRational::from_integer(BigInt::from(1)),
    )
    .ok_or("subtract")?;
    assert_eq!(round_binary64(&below)?, f64::MAX);
    Ok(())
}

#[test]
fn every_finite_sample_roundtrips_without_host_arithmetic() -> Result<(), String> {
    let mut bits = 42_u64;
    for _ in 0..10_000 {
        bits = bits
            .wrapping_mul(6364136223846793005)
            .wrapping_add(1442695040888963407);
        let value = f64::from_bits(bits);
        if value.is_finite() {
            let exact = midpoint(value, value)?;
            assert_eq!(round_binary64(&exact)?.to_bits(), value.to_bits());
        }
    }
    Ok(())
}
