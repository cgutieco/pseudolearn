use crate::lock_error::LockError;
use crate::lock_model::{Lock, LockKind, LockPackage};
use crate::manifest_checker::{Checker, join};
use crate::manifest_error::{ManifestError, ManifestErrorCode};
use crate::manifest_parser::parse;
use crate::manifest_value::{Entry, Scalar, Table};
use std::collections::BTreeMap;

impl Lock {
    pub fn parse(text: &str, max_bytes: usize) -> Result<Self, Vec<LockError>> {
        let table = parse(text, max_bytes).map_err(finish)?;
        let mut checker = Checker {
            errors: Vec::new(),
            root: Vec::new(),
        };
        checker.reject_unknown(&table, &["schema", "packages"], "");
        schema(&mut checker, &table);
        let packages = packages(&mut checker, &table);
        if !checker.errors.is_empty() {
            return Err(finish(checker.errors));
        }
        Self::from_packages(packages)
    }
}

fn finish(errors: Vec<ManifestError>) -> Vec<LockError> {
    let mut converted: Vec<LockError> = errors.into_iter().map(LockError::from_manifest).collect();
    LockError::sort(&mut converted);
    converted
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
        Scalar::Integer(_) => checker.report(
            ManifestErrorCode::UnsupportedSchema,
            "schema",
            found.position,
        ),
        Scalar::Text(_) => {
            checker.report(ManifestErrorCode::InvalidValue, "schema", found.position)
        }
    }
}

fn packages(checker: &mut Checker, root: &Table) -> Vec<LockPackage> {
    let Some(entry) = root.entries.get("packages") else {
        return Vec::new();
    };
    let Some(table) = checker.table(entry, "packages") else {
        return Vec::new();
    };
    let mut found = Vec::new();
    for (name, element) in &table.entries {
        let field = join("packages", name);
        if let Some(package) = package(checker, name, element, &field) {
            found.push(package);
        }
    }
    found
}

fn package(checker: &mut Checker, name: &str, entry: &Entry, field: &str) -> Option<LockPackage> {
    let table = checker.table(entry, field)?;
    let allowed = ["origin", "kind", "dependencies", "digest", "files"];
    checker.reject_unknown(table, &allowed, field);
    let origin = text_field(checker, table, "origin", field)?;
    let kind_text = text_field(checker, table, "kind", field)?;
    let Some(kind) = LockKind::from_name(&kind_text) else {
        checker.report(
            ManifestErrorCode::InvalidValue,
            &join(field, "kind"),
            table.position,
        );
        return None;
    };
    let dependencies = dependencies(checker, table, field)?;
    let digest = optional_text(checker, table, "digest", field);
    let files = files(checker, table, field);
    Some(LockPackage {
        name: name.to_owned(),
        origin,
        kind,
        dependencies,
        digest,
        files,
        position: table.position,
    })
}

fn text_field(checker: &mut Checker, table: &Table, name: &str, prefix: &str) -> Option<String> {
    let entry = checker.require(table, name, prefix)?;
    checker
        .text(entry, &join(prefix, name))
        .map(|text| text.value)
}

fn optional_text(checker: &mut Checker, table: &Table, name: &str, prefix: &str) -> Option<String> {
    let entry = table.entries.get(name)?;
    checker
        .text(entry, &join(prefix, name))
        .map(|text| text.value)
}

fn dependencies(checker: &mut Checker, table: &Table, prefix: &str) -> Option<Vec<String>> {
    let entry = checker.require(table, "dependencies", prefix)?;
    let field = join(prefix, "dependencies");
    let items = checker.list(entry, &field)?;
    let texts = checker.text_items(items, &field);
    Some(texts.into_iter().map(|(_, text)| text.value).collect())
}

fn files(checker: &mut Checker, table: &Table, prefix: &str) -> BTreeMap<String, String> {
    let mut found = BTreeMap::new();
    let Some(entry) = table.entries.get("files") else {
        return found;
    };
    let field = join(prefix, "files");
    let Some(listing) = checker.table(entry, &field) else {
        return found;
    };
    for (path, element) in &listing.entries {
        if let Some(digest) = checker.text(element, &join(&field, path)) {
            found.insert(path.clone(), digest.value);
        }
    }
    found
}
