mod support;
use std::process::Command;

#[test]
fn compares_git_revision_without_changing_checkout() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    initialize(&fixture)?;
    let path = fixture.root.join("specifications/lang/sample.md");
    let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
    std::fs::write(
        path,
        text.replace("El caso escribe uno.", "El caso escribe dos."),
    )
    .map_err(|error| error.to_string())?;
    let output = fixture.execute(&["diff", "HEAD"])?;
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    assert!(String::from_utf8_lossy(&output.stdout).contains("requiere_revision"));
    assert!(
        !fixture
            .execute(&["diff", "nonexistent-revision"])?
            .status
            .success()
    );
    assert!(!fixture.execute(&["diff", "-malicious"])?.status.success());
    Ok(())
}

fn initialize(fixture: &support::Fixture) -> Result<(), String> {
    for arguments in [
        vec!["init", "-q"],
        vec!["add", "."],
        vec![
            "-c",
            "user.name=Fixture",
            "-c",
            "user.email=fixture@example.invalid",
            "-c",
            "commit.gpgsign=false",
            "commit",
            "-qm",
            "initial fixture",
        ],
    ] {
        let output = Command::new("git")
            .current_dir(&fixture.root)
            .args(arguments)
            .output()
            .map_err(|error| error.to_string())?;
        assert!(
            output.status.success(),
            "{}",
            String::from_utf8_lossy(&output.stderr)
        );
    }
    Ok(())
}

#[test]
fn reads_member_corpus_from_repository_root_paths() -> Result<(), String> {
    let fixture = support::Fixture::create()?;
    let member = fixture.root.join("packages/spec");
    std::fs::create_dir_all(member.join("specifications/lang"))
        .map_err(|error| error.to_string())?;
    let path = member.join("specifications/lang/sample.md");
    let text = std::fs::read_to_string(fixture.root.join("specifications/lang/sample.md"))
        .map_err(|error| error.to_string())?;
    std::fs::write(&path, &text).map_err(|error| error.to_string())?;
    initialize(&fixture)?;
    std::fs::write(
        path,
        text.replace("El caso escribe uno.", "El caso escribe dos."),
    )
    .map_err(|error| error.to_string())?;
    let output = Command::new(env!("CARGO_BIN_EXE_see"))
        .args(["diff", "HEAD", "--root"])
        .arg(member)
        .output()
        .map_err(|error| error.to_string())?;
    assert!(
        output.status.success(),
        "{}",
        String::from_utf8_lossy(&output.stderr)
    );
    assert!(String::from_utf8_lossy(&output.stdout).contains("requiere_revision"));
    Ok(())
}
