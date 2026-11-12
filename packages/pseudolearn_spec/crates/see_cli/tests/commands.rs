mod support;

#[test]
fn validates_graphs_impacts_and_rejects_unknown_requests() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    for arguments in [
        vec!["validate"],
        vec!["graph"],
        vec!["graph", "--dot"],
        vec!["graph", "--focus", "SEE.TEST.SAMPLE"],
        vec!["impact", "SEE.TEST.SAMPLE"],
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
fn creates_stable_baseline_templates_without_fabricating_review() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    assert!(
        fixture
            .execute(&["new", "LANG.TEST.NEW", "--domain", "lang"])?
            .status
            .success()
    );
    let template =
        std::fs::read_to_string(fixture.root.join("specifications/lang/lang.test.new.md"))
            .map_err(|error| error.to_string())?;
    let specification = see_format::parsing::parse("template", &template)?;
    assert_eq!(specification.metadata.estado, "estable");
    assert_eq!(specification.metadata.version, "1.0.0");
    assert_eq!(specification.metadata.sujetos, vec!["engine", "aot"]);
    assert!(specification.metadata.revisado_por.is_empty());
    assert!(!template.contains("cambio"));
    let validation = fixture.execute(&["validate"])?;
    assert!(!validation.status.success());
    assert!(String::from_utf8_lossy(&validation.stderr).contains("independent review required"));
    rejects_invalid_template_requests(&fixture)?;
    Ok(())
}

fn rejects_invalid_template_requests(fixture: &support::Fixture) -> Result<(), String> {
    for arguments in [
        vec!["new", "LANG.TEST.NEW", "--domain", "lang"],
        vec!["new", "LANG.TEST.WRONG", "--domain", "see"],
        vec!["new", "invalid", "--domain", "lang"],
        vec!["new", "LANG.TEST.UNKNOWN", "--domain", "unknown"],
    ] {
        assert!(!fixture.execute(&arguments)?.status.success());
    }
    Ok(())
}

#[test]
fn lock_rejects_unversioned_edits_and_export_checks_local_outputs() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    assert!(!fixture.execute(&["lock", "--check"])?.status.success());
    assert!(fixture.execute(&["lock"])?.status.success());
    assert!(fixture.execute(&["lock", "--check"])?.status.success());
    assert!(fixture.execute(&["export"])?.status.success());
    assert!(fixture.execute(&["export", "--check"])?.status.success());
    std::fs::write(fixture.root.join("specifications/export.json"), "{}")
        .map_err(|error| error.to_string())?;
    assert!(fixture.execute(&["export", "--check"])?.status.success());
    assert_ne!(
        std::fs::read_to_string(fixture.root.join("specifications/export.json"))
            .map_err(|error| error.to_string())?,
        "{}"
    );
    let path = fixture.root.join("specifications/see/sample.md");
    let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
    std::fs::write(
        path,
        text.replace("El caso escribe uno.", "El caso escribe dos."),
    )
    .map_err(|error| error.to_string())?;
    assert!(!fixture.execute(&["validate"])?.status.success());
    assert!(!fixture.execute(&["lock"])?.status.success());
    assert!(!fixture.execute(&["lock", "--check"])?.status.success());
    Ok(())
}

#[test]
fn agent_sheet_fails_without_settings_or_resources() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    let missing = fixture.execute(&["agent-sheet", "--check"])?;
    assert!(!missing.status.success());
    std::fs::create_dir_all(fixture.root.join("agents")).map_err(|error| error.to_string())?;
    std::fs::write(
        fixture.root.join("agents/agent-sheet.json"),
        r#"{"outputs":{"es":["out/es.md"]},"labels":{"es":{}},"principles":{},"differences":[],"examples":[]}"#,
    )
    .map_err(|error| error.to_string())?;
    let unrendered = fixture.execute(&["agent-sheet"])?;
    assert!(!unrendered.status.success());
    assert!(!fixture.root.join("out/es.md").exists());
    Ok(())
}
