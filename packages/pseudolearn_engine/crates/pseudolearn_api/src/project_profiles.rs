use crate::project_resource::ProjectRequest;
use pseudolearn_semantic::{ResolvedUnitProfile, resolve_project_profiles};
use std::collections::BTreeMap;

pub(crate) struct UnitProfile {
    pub profile: pseudolearn_lexicon::Profile,
    pub mismatch: Option<String>,
}

pub(crate) fn resolve_units(request: &ProjectRequest) -> BTreeMap<String, UnitProfile> {
    resolve_project_profiles(
        &request.input.files,
        &request.file_profiles,
        &request.configurations,
        request.requested_profile,
    )
    .into_iter()
    .map(|(path, profile)| (path, unit_profile(profile)))
    .collect()
}

fn unit_profile(profile: ResolvedUnitProfile) -> UnitProfile {
    UnitProfile {
        profile: profile.profile,
        mismatch: profile.mismatch,
    }
}
