mod support;
use serde_json::json;

#[test]
fn retired_subject_rejects_launch_and_renders_without_evidence() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    let manifest = json!({"sujeto":"see", "estado":"retirado", "paquete":"historical",
        "activadas":[], "fases_cerradas":[], "vinculos":[]});
    std::fs::write(fixture.root.join("conformance.yaml"), manifest.to_string())
        .map_err(|error| error.to_string())?;
    let rejected = fixture.execute(&["conform", "--subject", "see"])?;
    assert!(!rejected.status.success());
    assert!(String::from_utf8_lossy(&rejected.stderr).contains("SEE-SUBJECT-RETIRED"));
    let rendered = fixture.execute(&["matrix", "--subject", "see"])?;
    assert!(
        rendered.status.success(),
        "{}",
        String::from_utf8_lossy(&rendered.stderr)
    );
    assert!(String::from_utf8_lossy(&rendered.stdout).contains("no aplicable"));
    Ok(())
}
