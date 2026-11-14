use crate::web_bundles::{web_editions, web_route_editions};
use reference_export::Bundle;
use std::collections::BTreeMap;

fn edition_files() -> Bundle {
    Bundle {
        files: BTreeMap::from([
            ("toc.json".to_owned(), "[]\n".to_owned()),
            ("sections/lectura.json".to_owned(), "{}\n".to_owned()),
            ("lessons/inicio.json".to_owned(), "{}\n".to_owned()),
            ("exercises/inicio.uno.json".to_owned(), "{}\n".to_owned()),
            ("terms.json".to_owned(), "{}\n".to_owned()),
            ("search.json".to_owned(), "[]\n".to_owned()),
            ("links.json".to_owned(), "{}\n".to_owned()),
            ("manifest.json".to_owned(), "{}\n".to_owned()),
        ]),
    }
}

fn four_editions() -> BTreeMap<String, Bundle> {
    [
        "es/keywords-es",
        "es/keywords-en",
        "en/keywords-es",
        "en/keywords-en",
    ]
    .into_iter()
    .map(|edition| (edition.to_owned(), edition_files()))
    .collect()
}

#[test]
fn keeps_only_the_profile_of_each_language() {
    let editions = web_editions(&four_editions());
    assert_eq!(
        editions.keys().map(String::as_str).collect::<Vec<_>>(),
        vec!["en", "es"]
    );
}

#[test]
fn publishes_only_the_table_of_contents_and_sections() {
    let editions = web_editions(&four_editions());
    let files: Vec<&str> = editions
        .get("es")
        .map(|bundle| bundle.files.keys().map(String::as_str).collect())
        .unwrap_or_default();
    assert_eq!(files, vec!["sections/lectura.json", "toc.json"]);
}

#[test]
fn ignores_empty_and_malformed_edition_keys() {
    assert!(web_editions(&BTreeMap::new()).is_empty());
    let malformed = BTreeMap::from([("es".to_owned(), edition_files())]);
    assert!(web_editions(&malformed).is_empty());
}

#[test]
fn an_edited_web_edition_is_reported_as_web_stale() {
    let directory = std::env::temp_dir().join(format!("reference-web-{}", std::process::id()));
    let editions = web_editions(&four_editions());
    assert!(crate::bundle_files::write(&directory, &editions).is_ok());
    assert!(std::fs::write(directory.join("es/toc.json"), "[\"edited\"]\n").is_ok());
    let violations = crate::bundle_files::compare(
        &directory,
        &editions,
        reference_model::RuleId::WebBundleStale,
    )
    .unwrap_or_default();
    assert_eq!(
        violations
            .iter()
            .map(|violation| (violation.rule.code(), violation.location.as_str()))
            .collect::<Vec<_>>(),
        vec![("REF-WEB-BUNDLE-STALE", "es/toc.json")]
    );
    assert!(std::fs::remove_dir_all(&directory).is_ok());
}

#[test]
fn publishes_the_route_table_of_contents_lessons_and_exercises() {
    let editions = web_route_editions(&four_editions());
    let files: Vec<&str> = editions
        .get("en")
        .map(|bundle| bundle.files.keys().map(String::as_str).collect())
        .unwrap_or_default();
    assert_eq!(
        files,
        vec![
            "exercises/inicio.uno.json",
            "lessons/inicio.json",
            "toc.json"
        ]
    );
}

#[test]
fn the_route_edition_keeps_only_the_profile_of_each_language() {
    let editions = web_route_editions(&four_editions());
    assert_eq!(
        editions.keys().map(String::as_str).collect::<Vec<_>>(),
        vec!["en", "es"]
    );
    assert!(web_route_editions(&BTreeMap::new()).is_empty());
}

#[test]
fn an_edited_web_route_edition_is_reported_as_route_web_stale() {
    let directory =
        std::env::temp_dir().join(format!("reference-web-route-{}", std::process::id()));
    let editions = web_route_editions(&four_editions());
    assert!(crate::bundle_files::write(&directory, &editions).is_ok());
    assert!(std::fs::remove_file(directory.join("en/lessons/inicio.json")).is_ok());
    let violations = crate::bundle_files::compare(
        &directory,
        &editions,
        reference_model::RuleId::WebRouteBundleStale,
    )
    .unwrap_or_default();
    assert_eq!(
        violations
            .iter()
            .map(|violation| violation.rule.code())
            .collect::<Vec<_>>(),
        vec!["RUTA-WEB-BUNDLE-STALE"]
    );
    assert!(std::fs::remove_dir_all(&directory).is_ok());
}
