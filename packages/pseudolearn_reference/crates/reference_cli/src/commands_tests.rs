use crate::commands::run;

#[test]
fn rejects_missing_or_unknown_commands() {
    assert!(run(&[]).is_err());
    assert!(
        run(&[
            "publicar".to_owned(),
            "--root".to_owned(),
            "/nonexistent".to_owned()
        ])
        .is_err()
    );
}

#[test]
fn rejects_options_without_values() {
    assert!(run(&["check".to_owned(), "--root".to_owned()]).is_err());
    assert!(run(&["check".to_owned(), "--otra".to_owned(), "x".to_owned()]).is_err());
}
