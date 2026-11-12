use super::super::Natural;

fn sample(seed: u64, limbs: u64) -> Natural {
    let mut state = seed;
    let mut value = Natural::zero();
    for _ in 0..limbs {
        state = state
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        value = value.shift_left(64).add(&Natural::from_u64(state));
    }
    value
}

#[test]
fn long_division_reconstructs_the_dividend() {
    for seed in 1..40 {
        let dividend = sample(seed, 6);
        let divisor = sample(seed.wrapping_mul(31), 1 + seed % 4).add(&Natural::from_u64(1));
        let result = dividend.divide(&divisor);
        assert!(result.is_some());
        if let Some((quotient, remainder)) = result {
            assert!(remainder < divisor);
            assert_eq!(quotient.multiply(&divisor).add(&remainder), dividend);
        }
    }
}

#[test]
fn division_by_zero_is_rejected() {
    assert_eq!(Natural::from_u64(5).divide(&Natural::zero()), None);
}

#[test]
fn smaller_dividend_has_zero_quotient() {
    let small = Natural::from_u64(3);
    let large = Natural::power_of_two(200);
    assert_eq!(small.divide(&large), Some((Natural::zero(), small)));
}

#[test]
fn square_root_is_the_floor_root() {
    for seed in 1..20 {
        let value = sample(seed, 3);
        let root = value.square_root();
        assert!(root.multiply(&root) <= value);
        let next = root.add(&Natural::from_u64(1));
        assert!(next.multiply(&next) > value);
    }
    assert!(Natural::zero().square_root().is_zero());
    assert_eq!(Natural::from_u64(16).square_root(), Natural::from_u64(4));
}
