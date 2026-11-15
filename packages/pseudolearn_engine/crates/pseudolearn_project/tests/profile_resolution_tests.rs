use pseudolearn_project::{
    Configuration, HostGrants, Location, ManifestRequest, ProfileChoice, ProfileOrigin,
    ProfileSources, resolve_profile,
};

const SPANISH: ProfileChoice = ProfileChoice::Spanish;
const ENGLISH: ProfileChoice = ProfileChoice::English;

fn located(line: usize) -> Location {
    Location { line, column: 1 }
}

#[test]
fn argument_beats_exception_and_package() {
    let resolved = resolve_profile(&ProfileSources {
        argument: Some(ENGLISH),
        exception: Some((SPANISH, located(3))),
        package: Some((SPANISH, located(2))),
        ..ProfileSources::default()
    });
    assert_eq!(resolved.chosen.profile, ENGLISH);
    assert_eq!(resolved.chosen.origin, ProfileOrigin::Argument);
    assert!(resolved.contradicted.is_none());
}

#[test]
fn exception_beats_package_and_package_beats_request() {
    let sources = ProfileSources {
        exception: Some((ENGLISH, located(5))),
        package: Some((SPANISH, located(2))),
        request: Some(SPANISH),
        ..ProfileSources::default()
    };
    assert_eq!(
        resolve_profile(&sources).chosen.origin,
        ProfileOrigin::Exception(located(5))
    );
    let package_only = ProfileSources {
        exception: None,
        ..sources
    };
    assert_eq!(
        resolve_profile(&package_only).chosen.origin,
        ProfileOrigin::Package(located(2))
    );
}

#[test]
fn opening_decides_when_nothing_is_configured() {
    let resolved = resolve_profile(&ProfileSources {
        opening: Some(ENGLISH),
        request: Some(SPANISH),
        ..ProfileSources::default()
    });
    assert_eq!(resolved.chosen.profile, ENGLISH);
    assert_eq!(resolved.chosen.origin, ProfileOrigin::Opening);
}

#[test]
fn configured_profile_contradicting_the_opening_reports_both_origins() {
    let resolved = resolve_profile(&ProfileSources {
        exception: Some((ENGLISH, located(4))),
        opening: Some(SPANISH),
        ..ProfileSources::default()
    });
    assert_eq!(resolved.chosen.profile, SPANISH);
    assert_eq!(
        resolved.mismatch_lexeme().as_deref(),
        Some("en (manifest exception 4:1) <> es (opening)")
    );
}

#[test]
fn matching_opening_is_not_a_conflict() {
    let resolved = resolve_profile(&ProfileSources {
        argument: Some(SPANISH),
        opening: Some(SPANISH),
        ..ProfileSources::default()
    });
    assert!(resolved.mismatch_lexeme().is_none());
}

#[test]
fn nothing_known_defaults_to_spanish() {
    let resolved = resolve_profile(&ProfileSources::default());
    assert_eq!(resolved.chosen.profile, SPANISH);
    assert_eq!(resolved.chosen.origin, ProfileOrigin::Default);
}

#[test]
fn request_is_only_a_fallback() {
    let resolved = resolve_profile(&ProfileSources {
        request: Some(ENGLISH),
        ..ProfileSources::default()
    });
    assert_eq!(resolved.chosen.origin, ProfileOrigin::Request);
}

fn configuration(text: &str) -> Result<Configuration, String> {
    let grants = HostGrants::default();
    Configuration::resolve(&ManifestRequest {
        text,
        location: "app",
        grants: &grants,
        max_bytes: 4096,
    })
    .map_err(|errors| format!("{errors:?}"))
}

#[test]
fn nearest_directory_exception_wins_over_a_wider_one() -> Result<(), String> {
    let manifest = configuration(
        "schema = 1\n[package]\nname = \"app\"\nkind = \"library\"\n[profiles]\n\"app/legacy\" = \"en\"\n\"app/legacy/old\" = \"es\"\n",
    )?
    .manifest;
    let pick = |path: &str| {
        manifest
            .profile_exception_for(path)
            .map(|(profile, _)| profile)
    };
    assert_eq!(pick("app/legacy/a"), Some(ENGLISH));
    assert_eq!(pick("app/legacy/old/b"), Some(SPANISH));
    assert_eq!(pick("app/legacy"), Some(ENGLISH));
    assert_eq!(pick("app/legacyx"), None);
    assert_eq!(pick("app/other"), None);
    Ok(())
}

#[test]
fn declared_profile_is_absent_when_the_manifest_defaults() -> Result<(), String> {
    let plain = configuration("schema = 1\n[package]\nname = \"app\"\nkind = \"library\"\n")?;
    assert!(plain.manifest.declared_profile().is_none());
    let declared = configuration(
        "schema = 1\n[package]\nname = \"app\"\nkind = \"library\"\nprofile = \"en\"\n",
    )?;
    assert_eq!(
        declared
            .manifest
            .declared_profile()
            .map(|(profile, _)| profile),
        Some(ENGLISH)
    );
    Ok(())
}
