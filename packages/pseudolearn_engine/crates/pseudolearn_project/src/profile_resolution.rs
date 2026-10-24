use crate::manifest_error::Location;
use crate::manifest_model::{Manifest, ProfileChoice, Provenance};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ProfileOrigin {
    Argument,
    Exception(Location),
    Package(Location),
    Opening,
    Request,
    Default,
}

impl ProfileOrigin {
    pub fn label(self) -> String {
        match self {
            Self::Argument => "argument".to_owned(),
            Self::Exception(location) => {
                format!("manifest exception {}:{}", location.line, location.column)
            }
            Self::Package(location) => {
                format!("manifest package {}:{}", location.line, location.column)
            }
            Self::Opening => "opening".to_owned(),
            Self::Request => "request".to_owned(),
            Self::Default => "default".to_owned(),
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ProfileChosen {
    pub profile: ProfileChoice,
    pub origin: ProfileOrigin,
}

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub struct ProfileSources {
    pub argument: Option<ProfileChoice>,
    pub exception: Option<(ProfileChoice, Location)>,
    pub package: Option<(ProfileChoice, Location)>,
    pub opening: Option<ProfileChoice>,
    pub request: Option<ProfileChoice>,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct ResolvedProfile {
    pub chosen: ProfileChosen,
    pub contradicted: Option<ProfileChosen>,
}

impl ResolvedProfile {
    pub fn mismatch_lexeme(&self) -> Option<String> {
        let configured = self.contradicted?;
        Some(format!(
            "{} ({}) <> {} ({})",
            configured.profile.as_str(),
            configured.origin.label(),
            self.chosen.profile.as_str(),
            self.chosen.origin.label(),
        ))
    }
}

pub fn resolve_profile(sources: &ProfileSources) -> ResolvedProfile {
    let configured = configured(sources);
    let opening = sources.opening.map(|profile| ProfileChosen {
        profile,
        origin: ProfileOrigin::Opening,
    });
    match (configured, opening) {
        (Some(set), Some(seen)) if set.profile != seen.profile => ResolvedProfile {
            chosen: seen,
            contradicted: Some(set),
        },
        (Some(set), _) => ResolvedProfile {
            chosen: set,
            contradicted: None,
        },
        (None, Some(seen)) => ResolvedProfile {
            chosen: seen,
            contradicted: None,
        },
        (None, None) => ResolvedProfile {
            chosen: fallback(sources),
            contradicted: None,
        },
    }
}

fn configured(sources: &ProfileSources) -> Option<ProfileChosen> {
    if let Some(profile) = sources.argument {
        return Some(ProfileChosen {
            profile,
            origin: ProfileOrigin::Argument,
        });
    }
    if let Some((profile, location)) = sources.exception {
        return Some(ProfileChosen {
            profile,
            origin: ProfileOrigin::Exception(location),
        });
    }
    sources.package.map(|(profile, location)| ProfileChosen {
        profile,
        origin: ProfileOrigin::Package(location),
    })
}

fn fallback(sources: &ProfileSources) -> ProfileChosen {
    match sources.request {
        Some(profile) => ProfileChosen {
            profile,
            origin: ProfileOrigin::Request,
        },
        None => ProfileChosen {
            profile: ProfileChoice::Spanish,
            origin: ProfileOrigin::Default,
        },
    }
}

impl Manifest {
    pub fn declared_profile(&self) -> Option<(ProfileChoice, Location)> {
        match self.profile.provenance {
            Provenance::Manifest(location) => Some((self.profile.value, location)),
            _ => None,
        }
    }

    pub fn profile_exception_for(&self, path: &str) -> Option<(ProfileChoice, Location)> {
        self.profiles
            .iter()
            .filter(|exception| covers(&exception.path, path))
            .max_by_key(|exception| exception.path.len())
            .map(|exception| (exception.profile, exception.position))
    }
}

fn covers(exception_path: &str, path: &str) -> bool {
    path == exception_path
        || path
            .strip_prefix(exception_path)
            .is_some_and(|rest| rest.starts_with('/'))
}
