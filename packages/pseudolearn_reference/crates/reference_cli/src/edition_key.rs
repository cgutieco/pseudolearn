use reference_model::Profile;

const PROFILE_PREFIX: &str = "keywords-";

pub fn edition_key(language: Profile, profile: Profile) -> String {
    format!("{}/{PROFILE_PREFIX}{}", language.code(), profile.code())
}

pub fn edition_codes(key: &str) -> Option<(&str, &str)> {
    let (language, profile_directory) = key.split_once('/')?;
    let profile = profile_directory.strip_prefix(PROFILE_PREFIX)?;
    Some((language, profile))
}
