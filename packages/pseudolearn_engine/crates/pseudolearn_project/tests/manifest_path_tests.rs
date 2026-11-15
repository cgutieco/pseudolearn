use pseudolearn_project::{
    Configuration, HostGrants, ManifestErrorCode, ManifestRequest, ProfileChoice,
};

fn resolve(
    text: &str,
    location: &str,
) -> Result<Configuration, Vec<pseudolearn_project::ManifestError>> {
    Configuration::resolve(&ManifestRequest {
        text,
        location,
        grants: &HostGrants::default(),
        max_bytes: 4096,
    })
}

#[test]
fn normalizes_manifest_routes_and_resolves_case_equivalent_references() -> Result<(), String> {
    let text = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"APP/CAFÉ\"]\n[profiles]\n\"app/café\" = \"en\"\n";
    let configuration = resolve(text, "App").map_err(|errors| format!("{errors:?}"))?;
    assert_eq!(configuration.root, "App");
    assert_eq!(configuration.manifest.entries.value, ["APP/CAFÉ"]);
    assert_eq!(
        configuration
            .manifest
            .profile_exception_for("app/CAFÉ/module")
            .map(|(profile, _)| profile),
        Some(ProfileChoice::English)
    );
    Ok(())
}

#[test]
fn rejects_invalid_components_and_routes_outside_the_package_root() -> Result<(), String> {
    for route in [
        "APP/../main",
        "APP\\\\main",
        "APP/CON",
        "APP/name.",
        "/outside",
    ] {
        let text = format!(
            "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"{route}\"]\n"
        );
        let errors = resolve(&text, "app")
            .err()
            .ok_or_else(|| format!("route {route} was accepted"))?;
        assert!(
            errors
                .iter()
                .any(|error| error.code == ManifestErrorCode::InvalidPath)
        );
    }
    Ok(())
}

#[test]
fn rejects_manifest_entry_and_profile_key_collisions() -> Result<(), String> {
    for (first, second) in [("app/main", "APP/MAIN"), ("app/café", "app/café")] {
        let entries = format!(
            "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"{first}\", \"{second}\"]\n"
        );
        let entry_errors = resolve(&entries, "app")
            .err()
            .ok_or_else(|| "entry collision was accepted".to_owned())?;
        assert_eq!(entry_errors.len(), 1);
        let entry_error = entry_errors.first().ok_or("entry error is missing")?;
        assert_eq!(entry_error.code, ManifestErrorCode::InvalidPath);
        assert_eq!(entry_error.field, "package.entries[1]");

        let profiles = format!(
            "schema = 1\n[package]\nname = \"app\"\nkind = \"library\"\n[profiles]\n\"{first}\" = \"es\"\n\"{second}\" = \"en\"\n"
        );
        let profile_errors = resolve(&profiles, "app")
            .err()
            .ok_or_else(|| "profile collision was accepted".to_owned())?;
        assert_eq!(profile_errors.len(), 2);
        assert!(
            profile_errors
                .iter()
                .all(|error| error.code == ManifestErrorCode::InvalidPath)
        );
    }
    Ok(())
}
