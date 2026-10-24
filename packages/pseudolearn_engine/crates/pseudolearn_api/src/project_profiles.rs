use crate::project_resource::ProjectRequest;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    Configuration, ProfileChoice, ProfileSources, ResolvedProfile, resolve_profile,
};
use std::collections::BTreeMap;

pub(crate) struct UnitProfile {
    pub profile: Profile,
    pub mismatch: Option<String>,
}

pub(crate) fn resolve_units(request: &ProjectRequest) -> BTreeMap<String, UnitProfile> {
    request
        .input
        .files
        .iter()
        .map(|file| {
            let resolved = resolve_profile(&sources(request, &file.path, &file.text));
            (file.path.clone(), unit_profile(&resolved))
        })
        .collect()
}

fn unit_profile(resolved: &ResolvedProfile) -> UnitProfile {
    UnitProfile {
        profile: to_profile(resolved.chosen.profile),
        mismatch: resolved.mismatch_lexeme(),
    }
}

fn sources(request: &ProjectRequest, path: &str, text: &str) -> ProfileSources {
    let configuration = owner(&request.configurations, path);
    ProfileSources {
        argument: request.file_profiles.get(path).copied().map(to_choice),
        exception: configuration.and_then(|found| found.manifest.profile_exception_for(path)),
        package: configuration.and_then(|found| found.manifest.declared_profile()),
        opening: crate::analyze::detect_vocabulary_profile(text).and_then(choice_named),
        request: request.requested_profile.map(to_choice),
    }
}

fn owner<'configurations>(
    configurations: &'configurations [Configuration],
    path: &str,
) -> Option<&'configurations Configuration> {
    configurations
        .iter()
        .filter(|configuration| {
            path.strip_prefix(configuration.root.as_str())
                .is_some_and(|rest| rest.starts_with('/'))
        })
        .max_by_key(|configuration| configuration.root.len())
}

fn choice_named(name: &str) -> Option<ProfileChoice> {
    match name {
        "es" => Some(ProfileChoice::Spanish),
        "en" => Some(ProfileChoice::English),
        _ => None,
    }
}

fn to_choice(profile: Profile) -> ProfileChoice {
    match profile {
        Profile::Spanish => ProfileChoice::Spanish,
        Profile::English => ProfileChoice::English,
    }
}

fn to_profile(choice: ProfileChoice) -> Profile {
    match choice {
        ProfileChoice::Spanish => Profile::Spanish,
        ProfileChoice::English => Profile::English,
    }
}
