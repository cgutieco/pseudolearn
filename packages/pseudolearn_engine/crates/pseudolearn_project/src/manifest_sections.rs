use crate::logical_path::key;
use crate::manifest_checker::{Checker, join};
use crate::manifest_error::{Location, ManifestErrorCode};
use crate::manifest_model::{
    Field, LimitName, LimitRequest, ManifestDependency, PermissionName, ProfileChoice,
    ProfileException, Provenance,
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
    let route_index = ProfileRouteIndex {
        key_counts: profile_key_counts(table),
    };
    for (path, element) in &table.entries {
        if let Some(exception) = route_index.exception(checker, path, element) {
            exceptions.push(exception);
        }
    }
    exceptions.sort_by(|left, right| {
        key(&left.path)
            .cmp(&key(&right.path))
            .then_with(|| left.path.cmp(&right.path))
    });
    exceptions
}

fn profile_key_counts(table: &Table) -> BTreeMap<String, usize> {
    let mut counts = BTreeMap::new();
    for path in table.entries.keys() {
        if let Some(path_key) = key(path) {
            counts
                .entry(path_key.join("/"))
                .and_modify(|count: &mut usize| *count = (*count).saturating_add(1))
                .or_insert(1);
        }
    }
    counts
}

struct ProfileRouteIndex {
    key_counts: BTreeMap<String, usize>,
}

impl ProfileRouteIndex {
    fn exception(
        &self,
        checker: &mut Checker,
        path: &str,
        element: &Entry,
    ) -> Option<ProfileException> {
        let field = join("profiles", path);
        let located_path = Located {
            position: element.key_at,
            value: path.to_owned(),
        };
        let normalized = checker.normalized_path_under_root(&located_path, &field);
        let text = checker.text(element, &field);
        let normalized = normalized?;
        let text = text?;
        let Some(profile) = ProfileChoice::from_name(&text.value) else {
            checker.report(ManifestErrorCode::InvalidValue, &field, text.position);
            return None;
        };
        let canonical_key = key(&normalized)?.join("/");
        if self.key_counts.get(&canonical_key).copied().unwrap_or(0) > 1 {
            checker.report(
                ManifestErrorCode::InvalidPath,
                &field,
                located_path.position,
            );
            return None;
        }
        Some(ProfileException {
            path: normalized,
            profile,
            position: text.position,
        })
    }
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

pub(crate) fn requests(
    checker: &mut Checker,
    root: &Table,
) -> (BTreeMap<LimitName, LimitRequest>, Vec<Field<PermissionName>>) {
    let Some(entry) = root.entries.get("requests") else {
        return (BTreeMap::new(), Vec::new());
    };
    let Some(table) = checker.table(entry, "requests") else {
        return (BTreeMap::new(), Vec::new());
    };
    checker.reject_unknown(table, &["limits", "permissions"], "requests");
    let permissions_list = permissions(checker, table);
    let Some(limits) = table.entries.get("limits") else {
        return (BTreeMap::new(), permissions_list);
    };
    (limit_requests(checker, limits), permissions_list)
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

fn permissions(checker: &mut Checker, table: &Table) -> Vec<Field<PermissionName>> {
    let mut resolved = Vec::new();
    let Some(entry) = table.entries.get("permissions") else {
        return resolved;
    };
    let Some(items) = checker.list(entry, "requests.permissions") else {
        return resolved;
    };
    for (position, text) in checker.text_items(items, "requests.permissions") {
        let field = format!("requests.permissions[{position}]");
        if let Some(name) = PermissionName::parse(&text.value) {
            resolved.push(Field {
                value: name,
                provenance: Provenance::Manifest(text.position),
            });
        } else {
            checker.report(ManifestErrorCode::UnknownPermission, &field, text.position);
        }
    }
    resolved
}
