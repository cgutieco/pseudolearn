use crate::manifest_checker::{Checker, join};
use crate::manifest_error::{Location, ManifestErrorCode};
use crate::manifest_model::{
    LimitName, LimitRequest, ManifestDependency, ProfileChoice, ProfileException,
};
use crate::manifest_value::{Entry, Located, Node, Scalar, Table};
use std::collections::BTreeMap;

pub(crate) fn value_location(entry: &Entry) -> Location {
    match &entry.node {
        Node::Value(located) => located.position,
        Node::Table(table) => table.position,
    }
}

pub(crate) fn profiles(checker: &mut Checker, root: &Table) -> Vec<ProfileException> {
    let Some(entry) = root.entries.get("profiles") else {
        return Vec::new();
    };
    let Some(table) = checker.table(entry, "profiles") else {
        return Vec::new();
    };
    let mut exceptions = Vec::new();
    for (path, element) in &table.entries {
        let field = join("profiles", path);
        let key = Located {
            position: element.key_at,
            value: path.clone(),
        };
        let valid = checker.path_under_root(&key, &field);
        let Some(text) = checker.text(element, &field) else {
            continue;
        };
        match ProfileChoice::from_name(&text.value) {
            Some(profile) if valid => exceptions.push(ProfileException {
                path: path.clone(),
                profile,
                position: text.position,
            }),
            Some(_) => {}
            None => checker.report(ManifestErrorCode::InvalidValue, &field, text.position),
        }
    }
    exceptions
}

pub(crate) fn dependencies(checker: &mut Checker, root: &Table) -> Vec<ManifestDependency> {
    let Some(entry) = root.entries.get("dependencies") else {
        return Vec::new();
    };
    let Some(table) = checker.table(entry, "dependencies") else {
        return Vec::new();
    };
    let mut found = Vec::new();
    for (alias, element) in &table.entries {
        let field = join("dependencies", alias);
        if alias.is_empty() {
            checker.report(ManifestErrorCode::InvalidValue, &field, element.key_at);
            continue;
        }
        found.extend(dependency(checker, alias, element, &field));
    }
    found
}

fn dependency(
    checker: &mut Checker,
    alias: &str,
    element: &Entry,
    field: &str,
) -> Option<ManifestDependency> {
    let inline = checker.table(element, field)?;
    checker.reject_unknown(inline, &["package"], field);
    let entry = checker.require(inline, "package", field)?;
    let name = checker.text(entry, &join(field, "package"))?;
    if name.value.is_empty() {
        checker.report(
            ManifestErrorCode::InvalidValue,
            &join(field, "package"),
            name.position,
        );
        return None;
    }
    Some(ManifestDependency {
        alias: alias.to_owned(),
        package: name.value,
        position: value_location(element),
    })
}

pub(crate) fn requests(checker: &mut Checker, root: &Table) -> BTreeMap<LimitName, LimitRequest> {
    let Some(entry) = root.entries.get("requests") else {
        return BTreeMap::new();
    };
    let Some(table) = checker.table(entry, "requests") else {
        return BTreeMap::new();
    };
    checker.reject_unknown(table, &["limits", "permissions"], "requests");
    permissions(checker, table);
    let Some(limits) = table.entries.get("limits") else {
        return BTreeMap::new();
    };
    limit_requests(checker, limits)
}

fn limit_requests(checker: &mut Checker, entry: &Entry) -> BTreeMap<LimitName, LimitRequest> {
    let mut requests = BTreeMap::new();
    let Some(table) = checker.table(entry, "requests.limits") else {
        return requests;
    };
    let names: Vec<&str> = LimitName::ALL.iter().map(|name| name.as_str()).collect();
    checker.reject_unknown(table, &names, "requests.limits");
    for name in LimitName::ALL {
        let Some(element) = table.entries.get(name.as_str()) else {
            continue;
        };
        let field = join("requests.limits", name.as_str());
        if let Some(request) = positive(checker, element, &field) {
            requests.insert(name, request);
        }
    }
    requests
}

fn positive(checker: &mut Checker, element: &Entry, field: &str) -> Option<LimitRequest> {
    let found = checker.scalar(element, field)?;
    match found.value {
        Scalar::Integer(value) if *value > 0 => Some(LimitRequest {
            requested: *value,
            position: found.position,
        }),
        _ => {
            checker.report(ManifestErrorCode::InvalidValue, field, found.position);
            None
        }
    }
}

fn permissions(checker: &mut Checker, table: &Table) {
    let Some(entry) = table.entries.get("permissions") else {
        return;
    };
    let Some(items) = checker.list(entry, "requests.permissions") else {
        return;
    };
    for (position, text) in checker.text_items(items, "requests.permissions") {
        let field = format!("requests.permissions[{position}]");
        checker.report(ManifestErrorCode::UnknownPermission, &field, text.position);
    }
}
