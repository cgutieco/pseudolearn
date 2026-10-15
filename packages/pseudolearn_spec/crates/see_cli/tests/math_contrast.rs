mod support;

#[test]
fn generates_one_argument_file_per_function() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    let directory = fixture.root.join("math");
    let text = directory.to_string_lossy().into_owned();
    let output = fixture.execute(&[
        "math-arguments",
        "--output",
        &text,
        "--count",
        "3",
        "--seed",
        "9",
    ])?;
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    for name in ["exp", "ln", "sin", "cos", "atan", "pow"] {
        let content = std::fs::read_to_string(directory.join(format!("{name}.arguments")))
            .map_err(|error| error.to_string())?;
        assert_eq!(content.lines().count(), 3);
    }
    assert!(directory.join("manifest.json").exists());
    Ok(())
}

#[test]
fn rejects_missing_directories_counts_and_results() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    let directory = fixture.root.join("math");
    let text = directory.to_string_lossy().into_owned();
    assert!(!fixture.execute(&["math-arguments"])?.status.success());
    assert!(
        !fixture
            .execute(&["math-arguments", "--output", &text, "--count", "many"])?
            .status
            .success()
    );
    assert!(
        fixture
            .execute(&["math-arguments", "--output", &text, "--count", "2"])?
            .status
            .success()
    );
    assert!(
        !fixture
            .execute(&["math-check", "--input", &text])?
            .status
            .success()
    );
    assert!(!fixture.execute(&["math-check"])?.status.success());
    Ok(())
}
