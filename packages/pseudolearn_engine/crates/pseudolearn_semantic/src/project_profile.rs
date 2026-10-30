use pseudolearn_lexicon::{Profile, detect_opening_profile};
use pseudolearn_project::{
    Configuration, FileInput, ProfileChoice, ProfileSources, ResolvedProfile, resolve_profile,
};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ResolvedUnitProfile {
    pub profile: Profile,
    pub mismatch: Option<String>,
}

pub fn resolve_project_profiles(
    files: &[FileInput],
    file_profiles: &BTreeMap<String, Profile>,
    configurations: &[Configuration],
    request_profile: Option<Profile>,
) -> BTreeMap<String, ResolvedUnitProfile> {
    files
        .iter()
        .map(|file| {
            let path = pseudolearn_project::logical_path_key(&file.path)
                .unwrap_or_else(|| file.path.clone());
            let resolved = resolve_profile(&profile_sources(
                &path,
                &file.text,
                file_profiles,
                configurations,
                request_profile,
            ));
            (path, resolved_unit_profile(&resolved))
        })
        .collect()
}

fn profile_sources(
    path: &str,
    text: &str,
    file_profiles: &BTreeMap<String, Profile>,
    configurations: &[Configuration],
    request_profile: Option<Profile>,
) -> ProfileSources {
    let configuration = owner(configurations, path);
    ProfileSources {
        argument: pseudolearn_project::logical_path_key(path)
            .and_then(|key| file_profiles.get(&key))
            .copied()
            .map(to_choice),
        exception: configuration.and_then(|found| found.manifest.profile_exception_for(path)),
        package: configuration.and_then(|found| found.manifest.declared_profile()),
        opening: detect_opening_profile(text).map(to_choice),
        request: request_profile.map(to_choice),
    }
}

fn owner<'config>(
    configurations: &'config [Configuration],
    path: &str,
) -> Option<&'config Configuration> {
    let path_key = pseudolearn_project::logical_path_key(path)?;
    configurations
        .iter()
        .filter(|configuration| {
            pseudolearn_project::logical_path_key(&configuration.root).is_some_and(|root| {
                path_key
                    .strip_prefix(&root)
                    .is_some_and(|rest| rest.starts_with('/'))
            })
        })
        .max_by_key(|configuration| {
            pseudolearn_project::logical_path_key(&configuration.root).map_or(0, |root| root.len())
        })
}

fn resolved_unit_profile(resolved: &ResolvedProfile) -> ResolvedUnitProfile {
    ResolvedUnitProfile {
        profile: to_profile(resolved.chosen.profile),
        mismatch: resolved.mismatch_lexeme(),
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
