#[test]
fn detects_shift_without_discarding_samples() -> Result<(), String> {
    let mut samples = vec![1.0; 15];
    samples.extend([2.0; 15]);
    assert!(ceiling_statistics::change_points::detect(&samples)?.contains(&15));
    assert!(ceiling_statistics::change_points::detect(&[1.0; 30])?.is_empty());
    assert!(ceiling_statistics::change_points::detect(&[]).is_err());
    Ok(())
}
