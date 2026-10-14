#[test]
fn independent_integer_oracle_checks_both_bounds() {
    assert_eq!(see_oracles::integer_sum(3, -1), Ok(2));
    assert_eq!(
        see_oracles::integer_sum(i64::MAX, 1),
        Err("integerOverflow".to_owned())
    );
    assert_eq!(
        see_oracles::integer_sum(i64::MIN, -1),
        Err("integerOverflow".to_owned())
    );
    assert_eq!(see_oracles::integer_sum(i64::MIN, i64::MAX), Ok(-1));
}

#[test]
fn counted_loop_oracle_handles_zero_empty_and_negative_steps() {
    assert_eq!(see_oracles::iterations(1, 3, 1), Ok(3));
    assert_eq!(see_oracles::iterations(10, 0, 1), Ok(0));
    assert_eq!(see_oracles::iterations(10, 0, -4), Ok(3));
    assert_eq!(see_oracles::iterations(3, 3, -4), Ok(1));
    assert!(see_oracles::iterations(1, 3, 0).is_err());
    assert!(see_oracles::iterations(i64::MIN, i64::MAX, 1).is_err());
}
