use see_validation::resources::grammar::check;
use serde_json::json;

#[test]
fn checks_references_and_reachability_without_rejecting_recursion() -> Result<(), String> {
    check(
        &json!({"inicial":"program","producciones":{"program":"@identifier, [ program ]"},"terminales":["identifier"]}),
    )?;
    for value in [
        json!({"inicial":"missing","producciones":{},"terminales":["identifier"]}),
        json!({"inicial":"program","producciones":{"program":"unknown"},"terminales":["identifier"]}),
        json!({"inicial":"program","producciones":{"program":"identifier","orphan":"identifier"},"terminales":["identifier"]}),
        json!({"inicial":"program","producciones":{"program":""},"terminales":["identifier"]}),
        json!({"inicial":"program","producciones":{"program":"[ identifier"},"terminales":["identifier"]}),
    ] {
        assert!(check(&value).is_err());
    }
    Ok(())
}
