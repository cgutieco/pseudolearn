mod support;

#[test]
fn checks_deep_inheritance_without_host_recursion() -> Result<(), String> {
    let mut source = String::from("class Level0\nendClass\n");
    for level in 1_u32..1500 {
        source.push_str(&format!(
            "class Level{level} inheritsFrom Level{}\nendClass\n",
            level.saturating_sub(1)
        ));
    }
    source.push_str("algorithm Entry\nendAlgorithm\n");
    let (module, diagnostics) = support::analyze(&source, true);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    assert_eq!(module.ok_or("Missing HIR")?.classes.len(), 1500);
    Ok(())
}

#[test]
fn reports_a_self_cycle_once() {
    let (module, diagnostics) = support::analyze(
        "class Recursive inheritsFrom Recursive\nendClass\nalgorithm Entry\nendAlgorithm\n",
        true,
    );
    assert!(module.is_none());
    assert_eq!(
        diagnostics
            .iter()
            .filter(|diagnostic| diagnostic.code.as_str() == "circularInheritance")
            .count(),
        1
    );
}
