use crate::authority::{HostGrants, LimitAuthority, resolve_limits, resolve_permissions};
use crate::logical_path::segments;
use crate::manifest_error::{Location, ManifestError, ManifestErrorCode};
use crate::manifest_model::{LimitName, Manifest, PermissionName};
use crate::manifest_parser::parse;
use crate::manifest_schema::validate;
use crate::project_model::PackageInput;
use std::collections::{BTreeMap, BTreeSet};

pub struct ManifestRequest<'input> {
    pub text: &'input str,
    pub location: &'input str,
    pub grants: &'input HostGrants,
    pub max_bytes: usize,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Configuration {
    pub root: String,
    pub manifest: Manifest,
    pub limits: BTreeMap<LimitName, LimitAuthority>,
    pub permissions: BTreeSet<PermissionName>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LocatedManifest {
    pub location: String,
    pub text: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LocatedError {
    pub location: String,
    pub error: ManifestError,
}

pub fn is_logical_path(path: &str) -> bool {
    segments(path).is_some()
}

impl Configuration {
    pub fn resolve(request: &ManifestRequest<'_>) -> Result<Self, Vec<ManifestError>> {
        let Some(root) = segments(request.location) else {
            return Err(vec![ManifestError::new(
                ManifestErrorCode::InvalidPath,
                "location",
                Location::START,
            )]);
        };
        let table = parse(request.text, request.max_bytes)?;
        let manifest = validate(&table, &root)?;
        let (limits, mut errors) = resolve_limits(&manifest.limits, request.grants);
        if !errors.is_empty() {
            ManifestError::sort(&mut errors);
            return Err(errors);
        }
        let permissions = resolve_permissions(&manifest.permissions, request.grants);
        Ok(Self {
            root: root.join("/"),
            manifest,
            limits,
            permissions,
        })
    }

    pub fn package_input(&self) -> PackageInput {
        PackageInput {
            name: self.manifest.name.value.clone(),
            root: self.root.clone(),
            kind: self.manifest.kind.value,
            entries: self.manifest.entries.value.clone(),
            dependencies: self
                .manifest
                .dependencies
                .iter()
                .map(|dependency| (dependency.alias.clone(), dependency.package.clone()))
                .collect(),
        }
    }
}

pub fn resolve_all(
    manifests: &[LocatedManifest],
    grants: &HostGrants,
    max_bytes: usize,
) -> Result<Vec<Configuration>, Vec<LocatedError>> {
    let mut configurations = Vec::new();
    let mut failures = Vec::new();
    for manifest in manifests {
        let request = ManifestRequest {
            text: &manifest.text,
            location: &manifest.location,
            grants,
            max_bytes,
        };
        match Configuration::resolve(&request) {
            Ok(configuration) => configurations.push(configuration),
            Err(errors) => failures.extend(errors.into_iter().map(|error| {
                LocatedError {
                    location: crate::logical_path::normalize(&manifest.location)
                        .unwrap_or_else(|| manifest.location.clone()),
                    error,
                }
            })),
        }
    }
    if failures.is_empty() {
        return Ok(configurations);
    }
    failures.sort_by(|left, right| {
        location_key(&left.location)
            .cmp(&location_key(&right.location))
            .then_with(|| left.error.position.cmp(&right.error.position))
            .then_with(|| left.error.code.cmp(&right.error.code))
            .then_with(|| left.error.field.cmp(&right.error.field))
    });
    Err(failures)
}

fn location_key(location: &str) -> String {
    crate::logical_path::key(location)
        .map(|segments| segments.join("/"))
        .unwrap_or_else(|| location.to_owned())
}
