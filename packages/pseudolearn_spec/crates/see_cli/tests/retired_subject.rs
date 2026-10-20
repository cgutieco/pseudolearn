mod support;
use serde_json::json;

#[test]
fn retired_subject_rejects_launch_and_renders_without_evidence() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    let directory = fixture.root.join("subjects/reference");
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    let manifest = json!({"sujeto":"reference", "estado":"retirado", "paquete":"historical",
        "activadas":[], "fases_cerradas":[], "vinculos":[]});
    std::fs::write(directory.join("conformance.yaml"), manifest.to_string())
        .map_err(|error| error.to_string())?;
    let rejected = fixture.execute(&["conform", "--subject", "reference"])?;
    assert!(!rejected.status.success());
    assert!(String::from_utf8_lossy(&rejected.stderr).contains("SEE-SUBJECT-RETIRED"));
    let rendered = fixture.execute(&["matrix", "--subject", "reference"])?;
    assert!(
        rendered.status.success(),
        "{}",
        String::from_utf8_lossy(&rendered.stderr)
    );
    assert!(String::from_utf8_lossy(&rendered.stdout).contains("no aplicable"));
    Ok(())
}
