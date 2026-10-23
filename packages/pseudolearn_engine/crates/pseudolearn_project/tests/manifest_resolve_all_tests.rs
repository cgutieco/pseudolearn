use pseudolearn_project::{
    HostGrants, LocatedManifest, ManifestErrorCode, PackageKind, resolve_all,
};

fn located(location: &str, text: &str) -> LocatedManifest {
    LocatedManifest {
        location: location.to_owned(),
        text: text.to_owned(),
    }
}

const APP: &str = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n";
const GEO: &str = "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n";

#[test]
fn manifests_become_package_inputs_rooted_at_their_location() -> Result<(), String> {
    let manifests = [located("app", APP), located("geo", GEO)];
    let configurations = resolve_all(&manifests, &HostGrants::default(), 4096)
        .map_err(|errors| format!("{errors:?}"))?;
    let inputs: Vec<_> = configurations
        .iter()
        .map(|configuration| configuration.package_input())
        .collect();
    let app = inputs.first().ok_or("no app")?;
    assert_eq!(app.name, "app");
    assert_eq!(app.root, "app");
    assert_eq!(app.kind, PackageKind::Application);
    assert_eq!(app.entries, ["app/main"]);
    assert_eq!(app.dependencies.get("geo").map(String::as_str), Some("geo"));
    Ok(())
}

#[test]
fn errors_name_the_manifest_that_caused_them() {
    let broken = "schema = 1\n[package]\nname = \"geo\"\n";
    let manifests = [located("app", APP), located("geo", broken)];
    let failures = resolve_all(&manifests, &HostGrants::default(), 4096)
        .err()
        .unwrap_or_default();
    assert_eq!(failures.len(), 1);
    let failure = failures.first();
    assert_eq!(failure.map(|entry| entry.location.as_str()), Some("geo"));
    assert_eq!(
        failure.map(|entry| entry.error.code),
        Some(ManifestErrorCode::MissingField)
    );
}

#[test]
fn no_manifests_resolve_to_no_configurations() -> Result<(), String> {
    let configurations =
        resolve_all(&[], &HostGrants::default(), 4096).map_err(|errors| format!("{errors:?}"))?;
    assert!(configurations.is_empty());
    Ok(())
}

#[test]
fn failures_are_ordered_by_location() {
    let broken = "schema 1\n";
    let manifests = [located("zeta", broken), located("alfa", broken)];
    let failures = resolve_all(&manifests, &HostGrants::default(), 4096)
        .err()
        .unwrap_or_default();
    let order: Vec<_> = failures
        .iter()
        .map(|failure| failure.location.as_str())
        .collect();
    assert_eq!(order, ["alfa", "zeta"]);
}
