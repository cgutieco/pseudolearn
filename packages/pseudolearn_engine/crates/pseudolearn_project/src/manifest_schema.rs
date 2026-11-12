use crate::manifest_checker::Checker;
use crate::manifest_error::{ManifestError, ManifestErrorCode};
use crate::manifest_model::{Field, Manifest, ProfileChoice, Provenance};
use crate::manifest_sections;
use crate::manifest_value::{Scalar, Table};
use crate::project_model::PackageKind;
use std::collections::BTreeSet;

struct PackageFields {
    name: Field<String>,
    kind: Field<PackageKind>,
    profile: Field<ProfileChoice>,
    entries: Field<Vec<String>>,
}

pub(crate) fn validate(root: &Table, location: &[String]) -> Result<Manifest, Vec<ManifestError>> {
    let mut checker = Checker {
        errors: Vec::new(),
        root: location.to_vec(),
    };
    let top = ["schema", "package", "profiles", "dependencies", "requests"];
    checker.reject_unknown(root, &top, "");
    schema(&mut checker, root);
    let package = package(&mut checker, root);
    let profiles = manifest_sections::profiles(&mut checker, root);
    let dependencies = manifest_sections::dependencies(&mut checker, root);
    let limits = manifest_sections::requests(&mut checker, root);
    let Some(package) = package.filter(|_| checker.errors.is_empty()) else {
        ManifestError::sort(&mut checker.errors);
        return Err(checker.errors);
    };
    Ok(Manifest {
        name: package.name,
        kind: package.kind,
        profile: package.profile,
        entries: package.entries,
        profiles,
        dependencies,
        limits,
    })
}

fn schema(checker: &mut Checker, root: &Table) {
    let Some(entry) = checker.require(root, "schema", "") else {
        return;
    };
    let Some(found) = checker.scalar(entry, "schema") else {
        return;
    };
    match found.value {
        Scalar::Integer(1) => {}
        Scalar::Integer(_) => {
            checker.report(
                ManifestErrorCode::UnsupportedSchema,
                "schema",
                found.position,
            );
        }
        Scalar::Text(_) => {
            checker.report(ManifestErrorCode::InvalidValue, "schema", found.position)
        }
    }
}

fn package(checker: &mut Checker, root: &Table) -> Option<PackageFields> {
    let entry = checker.require(root, "package", "")?;
    let table = checker.table(entry, "package")?;
    checker.reject_unknown(table, &["name", "kind", "profile", "entries"], "package");
    let name = name(checker, table);
    let kind = kind(checker, table);
    let profile = profile(checker, table);
    let entries = entries(checker, table);
    Some(PackageFields {
        name: name?,
        kind: kind?,
        profile: profile?,
        entries: entries?,
    })
}

fn name(checker: &mut Checker, table: &Table) -> Option<Field<String>> {
    let entry = checker.require(table, "name", "package")?;
    let text = checker.text(entry, "package.name")?;
    if text.value.is_empty() {
        checker.report(
            ManifestErrorCode::InvalidValue,
            "package.name",
            text.position,
        );
        return None;
    }
    Some(Field {
        value: text.value,
        provenance: Provenance::Manifest(text.position),
    })
}

fn kind(checker: &mut Checker, table: &Table) -> Option<Field<PackageKind>> {
    let entry = checker.require(table, "kind", "package")?;
    let text = checker.text(entry, "package.kind")?;
    let kind = match text.value.as_str() {
        "application" => PackageKind::Application,
        "library" => PackageKind::Library,
        _ => {
            checker.report(
                ManifestErrorCode::InvalidValue,
                "package.kind",
                text.position,
            );
            return None;
        }
    };
    Some(Field {
        value: kind,
        provenance: Provenance::Manifest(text.position),
    })
}

fn profile(checker: &mut Checker, table: &Table) -> Option<Field<ProfileChoice>> {
    let Some(entry) = table.entries.get("profile") else {
        return Some(Field {
            value: ProfileChoice::Spanish,
            provenance: Provenance::Default,
        });
    };
    let text = checker.text(entry, "package.profile")?;
    let Some(choice) = ProfileChoice::from_name(&text.value) else {
        checker.report(
            ManifestErrorCode::InvalidValue,
            "package.profile",
            text.position,
        );
        return None;
    };
    Some(Field {
        value: choice,
        provenance: Provenance::Manifest(text.position),
    })
}

fn entries(checker: &mut Checker, table: &Table) -> Option<Field<Vec<String>>> {
    let Some(entry) = table.entries.get("entries") else {
        return Some(Field {
            value: Vec::new(),
            provenance: Provenance::Default,
        });
    };
    let items = checker.list(entry, "package.entries")?;
    let position = crate::manifest_sections::value_location(entry);
    let mut paths = Vec::new();
    let mut path_keys = BTreeSet::new();
    for (position, text) in checker.text_items(items, "package.entries") {
        let field = format!("package.entries[{position}]");
        let Some(normalized) = checker.normalized_path_under_root(&text, &field) else {
            continue;
        };
        let Some(key) = crate::logical_path::key(&normalized) else {
            checker.report(ManifestErrorCode::InvalidPath, &field, text.position);
            continue;
        };
        if path_keys.insert(key) {
            paths.push(normalized);
        } else {
            checker.report(ManifestErrorCode::InvalidPath, &field, text.position);
        }
    }
    Some(Field {
        value: paths,
        provenance: Provenance::Manifest(position),
    })
}
