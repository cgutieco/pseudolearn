mod support;

use pseudolearn_diagnostics::DiagnosticCode;
use support::analyze;

const POINT: &str = "record Point\ndefine x, z as integer;\nendRecord\n";

#[test]
fn a_record_class_field_expands_into_one_physical_field_per_leaf() {
    let program = format!(
        "{POINT}class K\ndefine p as Point;\nendClass\nalgorithm P\ndefine k as K <- new K();\nwrite k.p.x;\nendAlgorithm\n"
    );
    let (module, diagnostics) = analyze(&program);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let entry = module
        .as_ref()
        .and_then(|module| module.class_record_fields.first());
    assert_eq!(
        entry.map(|entry| entry.field.name.clone()),
        Some("p".to_owned())
    );
    assert_eq!(entry.map(|entry| entry.leaves.len()), Some(2));
    let names: Vec<_> = module
        .as_ref()
        .and_then(|module| module.classes.first())
        .map(|class| {
            class
                .fields
                .iter()
                .map(|field| field.name.clone())
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(names, vec!["p.x".to_owned(), "p.z".to_owned()]);
}

#[test]
fn an_array_of_records_expands_into_one_array_local_per_leaf() {
    let program = format!(
        "{POINT}algorithm P\ndimension a[2] as Point;\na[0] <- Point(1, 2);\nwrite a[0].x;\nendAlgorithm\n"
    );
    let (module, diagnostics) = analyze(&program);
    assert!(diagnostics.is_empty(), "{diagnostics:?}");
    let names: Vec<_> = module
        .as_ref()
        .map(|module| {
            module
                .record_locals
                .values()
                .flatten()
                .filter_map(|leaf| module.locals.get(usize::try_from(leaf.0).ok()?))
                .map(|local| local.name.clone())
                .collect()
        })
        .unwrap_or_default();
    assert_eq!(names, vec!["a.x".to_owned(), "a.z".to_owned()]);
}

#[test]
fn a_duplicate_record_field_name_is_reported_once() {
    let program = format!(
        "{POINT}class K\ndefine p as Point;\ndefine p as Point;\nendClass\nalgorithm P\nendAlgorithm\n"
    );
    let (_, diagnostics) = analyze(&program);
    let duplicates = diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.code == DiagnosticCode::DuplicateMember)
        .count();
    assert_eq!(duplicates, 1);
}
