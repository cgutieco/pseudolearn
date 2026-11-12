use crate::commands;

#[test]
fn regenerates_the_export_before_anything_else() {
    let all = commands();
    assert_eq!(
        all.first().map(|(directory, _)| *directory),
        Some("../pseudolearn_spec")
    );
}

#[test]
fn ends_with_the_reference_check() {
    let all = commands();
    assert_eq!(
        all.last().map(|(_, arguments)| arguments.last().copied()),
        Some(Some("check"))
    );
    assert!(all.iter().any(|(_, arguments)| arguments.contains(&"deny")));
    assert!(
        all.iter()
            .any(|(_, arguments)| arguments.contains(&"toolchain"))
    );
}
