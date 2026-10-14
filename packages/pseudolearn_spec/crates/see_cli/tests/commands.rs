mod support;

#[test]
fn validates_graphs_impacts_and_rejects_unknown_requests() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    for arguments in [
        vec!["validate"],
        vec!["graph"],
        vec!["graph", "--dot"],
        vec!["graph", "--focus", "LANG.TEST.SAMPLE"],
        vec!["impact", "LANG.TEST.SAMPLE"],
    ] {
        let output = fixture.execute(&arguments)?;
        assert!(
            output.status.success(),
            "{}",
            String::from_utf8_lossy(&output.stderr)
        );
    }
    for arguments in [
        vec!["unknown"],
        vec!["impact", "UNKNOWN"],
        vec!["graph", "--focus"],
        vec!["validate", "--unknown"],
        vec!["matrix"],
        vec!["feature", "../escape"],
    ] {
        assert!(!fixture.execute(&arguments)?.status.success());
    }
    Ok(())
}

#[test]
fn creates_valid_domain_drafts_and_never_overwrites_identity() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    assert!(
        fixture
            .execute(&["new", "LANG.TEST.NEW", "--domain", "lang"])?
            .status
            .success()
    );
    assert!(fixture.execute(&["validate"])?.status.success());
    assert!(
        !fixture
            .execute(&["new", "LANG.TEST.NEW", "--domain", "lang"])?
            .status
            .success()
    );
    assert!(
        !fixture
            .execute(&["new", "LANG.TEST.WRONG", "--domain", "see"])?
            .status
            .success()
    );
    assert!(
        !fixture
            .execute(&["new", "invalid", "--domain", "lang"])?
            .status
            .success()
    );
    assert!(
        !fixture
            .execute(&["new", "LANG.TEST.UNKNOWN", "--domain", "unknown"])?
            .status
            .success()
    );
    Ok(())
}

#[test]
fn lock_and_export_checks_detect_stale_artifacts() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    assert!(!fixture.execute(&["lock", "--check"])?.status.success());
    assert!(fixture.execute(&["lock"])?.status.success());
    assert!(fixture.execute(&["lock", "--check"])?.status.success());
    assert!(fixture.execute(&["export"])?.status.success());
    assert!(fixture.execute(&["export", "--check"])?.status.success());
    std::fs::write(fixture.root.join("specifications/export.json"), "{}")
        .map_err(|error| error.to_string())?;
    assert!(!fixture.execute(&["export", "--check"])?.status.success());
    let path = fixture.root.join("specifications/lang/sample.md");
    let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
    std::fs::write(
        path,
        text.replace("El caso escribe uno.", "El caso escribe dos."),
    )
    .map_err(|error| error.to_string())?;
    assert!(!fixture.execute(&["validate"])?.status.success());
    assert!(!fixture.execute(&["lock"])?.status.success());
    Ok(())
}
