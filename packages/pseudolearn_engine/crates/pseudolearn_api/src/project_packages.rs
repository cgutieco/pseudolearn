use crate::ApiError;
use crate::manifest_wire::MANIFEST_BYTE_BUDGET;
use crate::project_resource::usage;
use pseudolearn_project::{
    Configuration, HostGrants, LocatedError, LocatedManifest, PackageInput, resolve_all,
};

pub(crate) struct PackageSource {
    pub packages: Vec<PackageInput>,
    pub configurations: Vec<Configuration>,
    pub manifest_errors: Vec<LocatedError>,
    pub manifests_used: bool,
}

pub(crate) fn choose(
    packages: Option<Vec<PackageInput>>,
    manifests: Option<Vec<LocatedManifest>>,
    grants: &HostGrants,
) -> Result<PackageSource, ApiError> {
    match (packages, manifests) {
        (Some(packages), None) => Ok(PackageSource {
            packages,
            configurations: Vec::new(),
            manifest_errors: Vec::new(),
            manifests_used: false,
        }),
        (None, Some(manifests)) => Ok(from_manifests(&manifests, grants)),
        _ => Err(usage("exactly one of packages and manifests is required")),
    }
}

fn from_manifests(manifests: &[LocatedManifest], grants: &HostGrants) -> PackageSource {
    match resolve_all(manifests, grants, MANIFEST_BYTE_BUDGET) {
        Ok(configurations) => PackageSource {
            packages: configurations
                .iter()
                .map(Configuration::package_input)
                .collect(),
            configurations,
            manifest_errors: Vec::new(),
            manifests_used: true,
        },
        Err(manifest_errors) => PackageSource {
            packages: Vec::new(),
            configurations: Vec::new(),
            manifest_errors,
            manifests_used: true,
        },
    }
}
