use crate::edition_key::{edition_codes, edition_key};
use reference_model::Profile;

#[test]
fn the_profile_directory_is_never_a_bare_language_tag() {
    assert_eq!(
        edition_key(Profile::Spanish, Profile::English),
        "es/keywords-en"
    );
    assert_eq!(
        edition_key(Profile::English, Profile::Spanish),
        "en/keywords-es"
    );
}

#[test]
fn a_key_splits_back_into_its_language_and_profile() {
    let key = edition_key(Profile::English, Profile::English);
    assert_eq!(edition_codes(&key), Some(("en", "en")));
}

#[test]
fn a_key_without_the_profile_prefix_or_separator_is_rejected() {
    assert_eq!(edition_codes("es/es"), None);
    assert_eq!(edition_codes("es"), None);
    assert_eq!(edition_codes(""), None);
    assert_eq!(edition_codes("es/keywords-"), Some(("es", "")));
}
