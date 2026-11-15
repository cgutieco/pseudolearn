use super::fixture::Fixture;
use pseudolearn_check_model::Architecture;
use std::path::Path;

fn debug_rules(package: &str, layer: &str) -> Result<Architecture, String> {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../..")
        .join(package);
    let mut rules = pseudolearn_check_source::loading::read_architecture(&root)?;
    let mut selected = rules
        .layers
        .iter()
        .find(|candidate| candidate.name == layer)
        .cloned()
        .ok_or("Missing architecture owner")?;
    selected.name = "subject".to_owned();
    selected.path = "subject".to_owned();
    rules.layers = vec![selected];
    Ok(rules)
}

fn dependency_fixture(target: &str) -> Result<Fixture, Box<dyn std::error::Error>> {
    let fixture = Fixture::create()?;
    let dependency = fixture.root.join("dependency");
    std::fs::create_dir_all(dependency.join("src"))?;
    std::fs::write(
        dependency.join("Cargo.toml"),
        format!(
            "[package]\nname = \"{target}\"\nversion = \"0.1.0\"\nedition = \"2024\"\npublish = false\n"
        ),
    )?;
    std::fs::write(dependency.join("src/lib.rs"), "pub fn execute() {}\n")?;
    std::fs::write(
        fixture.root.join("Cargo.toml"),
        "[workspace]\nmembers = [\"subject\"]\nexclude = [\"dependency\"]\nresolver = \"3\"\n",
    )?;
    let manifest = fixture.root.join("subject/Cargo.toml");
    let original = std::fs::read_to_string(&manifest)?;
    std::fs::write(
        manifest,
        format!("{original}\n[dependencies]\n{target} = {{ path = \"../dependency\" }}\n"),
    )?;
    Ok(fixture)
}

#[test]
fn rejects_direct_debug_access_from_service_and_cli() -> Result<(), Box<dyn std::error::Error>> {
    for (package, layer, target) in [
        (
            "packages/pseudolearn_engine",
            "pseudolearn_service",
            "pseudolearn_vm",
        ),
        (
            "packages/pseudolearn_engine",
            "pseudolearn_service",
            "pseudolearn_api",
        ),
        ("apps/pseudolearn_cli", "pseudolearn_cli", "pseudolearn_vm"),
        (
            "apps/pseudolearn_cli",
            "pseudolearn_cli",
            "pseudolearn_timeline",
        ),
    ] {
        let fixture = dependency_fixture(target)?;
        let rules = debug_rules(package, layer)?;
        let violations = pseudolearn_checks::layers::check(&fixture.root, &rules)?;
        assert!(
            violations
                .iter()
                .any(|violation| violation.rule == "LAYER-DIRECTION"
                    && violation.message.contains(target))
        );
    }
    Ok(())
}

#[test]
fn accepts_the_cli_public_api_boundary() -> Result<(), Box<dyn std::error::Error>> {
    let fixture = dependency_fixture("pseudolearn_api")?;
    let rules = debug_rules("apps/pseudolearn_cli", "pseudolearn_cli")?;
    assert!(pseudolearn_checks::layers::check(&fixture.root, &rules)?.is_empty());
    Ok(())
}
