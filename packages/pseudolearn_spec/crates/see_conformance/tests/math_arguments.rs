use see_conformance::math_arguments::{MATH_FUNCTIONS, MathFunction, arguments};

#[test]
fn generation_is_deterministic_for_a_seed() {
    for function in MATH_FUNCTIONS {
        let first = arguments(function, 500, 7);
        let second = arguments(function, 500, 7);
        let first_bits: Vec<Vec<u64>> = first
            .iter()
            .map(|row| row.iter().map(|value| value.to_bits()).collect())
            .collect();
        let second_bits: Vec<Vec<u64>> = second
            .iter()
            .map(|row| row.iter().map(|value| value.to_bits()).collect())
            .collect();
        assert_eq!(first_bits, second_bits, "{}", function.name());
    }
}

#[test]
fn different_seeds_produce_different_arguments() {
    let first = arguments(MathFunction::Sine, 50, 1);
    let second = arguments(MathFunction::Sine, 50, 2);
    assert_ne!(
        first
            .iter()
            .map(|row| row.iter().map(|value| value.to_bits()).collect::<Vec<_>>())
            .collect::<Vec<_>>(),
        second
            .iter()
            .map(|row| row.iter().map(|value| value.to_bits()).collect::<Vec<_>>())
            .collect::<Vec<_>>()
    );
}

#[test]
fn every_argument_is_finite_and_has_the_function_arity() {
    for function in MATH_FUNCTIONS {
        for row in arguments(function, 2000, 11) {
            assert_eq!(row.len(), function.arity());
            assert!(row.iter().all(|value| value.is_finite()));
        }
    }
}

#[test]
fn logarithm_arguments_are_never_negative() {
    assert!(
        arguments(MathFunction::Logarithm, 2000, 3)
            .iter()
            .flatten()
            .all(|value| value.is_sign_positive())
    );
}

#[test]
fn zero_count_produces_no_arguments() {
    assert!(arguments(MathFunction::Power, 0, 1).is_empty());
}
