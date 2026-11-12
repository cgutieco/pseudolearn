#[test]
fn bootstrap_is_reproducible_and_constant_interval_is_exact() -> Result<(), String> {
    assert_eq!(ceiling_statistics::confidence(&[2.0; 10])?, [2.0; 2]);
    assert_eq!(
        ceiling_statistics::confidence(&[1.0, 2.0, 3.0])?,
        ceiling_statistics::confidence(&[1.0, 2.0, 3.0])?
    );
    assert!(ceiling_statistics::mean(&[]).is_err());
    assert!(ceiling_statistics::mean(&[f64::NAN]).is_err());
    assert!(ceiling_statistics::ratio(&[1.0], &[0.0]).is_err());
    assert!(ceiling_statistics::ratio(&[1.0], &[]).is_err());
    assert_eq!(ceiling_statistics::geometric(&[2.0, 8.0])?, 4.0);
    assert!(ceiling_statistics::geometric(&[0.0]).is_err());
    Ok(())
}
