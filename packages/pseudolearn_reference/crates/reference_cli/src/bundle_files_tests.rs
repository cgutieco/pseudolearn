use crate::bundle_files::{compare, write};
use reference_export::Bundle;
use reference_model::RuleId;
use std::collections::BTreeMap;

fn scratch(name: &str) -> std::path::PathBuf {
    std::env::temp_dir().join(format!("reference-cli-{name}-{}", std::process::id()))
}

fn bundles(text: &str) -> BTreeMap<String, Bundle> {
    BTreeMap::from([(
        "es/keywords-es".to_owned(),
        Bundle {
            files: BTreeMap::from([("toc.json".to_owned(), text.to_owned())]),
        },
    )])
}

#[test]
fn a_written_bundle_is_not_stale() {
    let directory = scratch("fresh");
    assert!(write(&directory, &bundles("[]\n")).is_ok());
    assert_eq!(
        compare(&directory, &bundles("[]\n"), RuleId::BundleStale).map(|found| found.len()),
        Ok(0)
    );
    assert!(std::fs::remove_dir_all(&directory).is_ok());
}

#[test]
fn an_edited_missing_or_extra_file_is_stale() {
    let directory = scratch("stale");
    assert!(write(&directory, &bundles("[]\n")).is_ok());
    let edited = compare(&directory, &bundles("[1]\n"), RuleId::BundleStale).unwrap_or_default();
    assert_eq!(
        edited.first().map(|violation| violation.rule),
        Some(RuleId::BundleStale)
    );
    assert!(std::fs::write(directory.join("es/keywords-es/extra.json"), "{}").is_ok());
    assert_eq!(
        compare(&directory, &bundles("[]\n"), RuleId::BundleStale).map(|found| found.len()),
        Ok(1)
    );
    assert_eq!(
        compare(
            &scratch("absent"),
            &bundles("[]\n"),
            RuleId::RouteBundleStale
        )
        .map(|found| found.len()),
        Ok(1)
    );
    assert!(std::fs::remove_dir_all(&directory).is_ok());
}
