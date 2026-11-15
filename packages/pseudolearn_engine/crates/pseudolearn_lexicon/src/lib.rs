#![forbid(unsafe_code)]

mod hash;

pub mod keywords;
pub mod profile;
pub mod signatures;

#[cfg(test)]
mod profile_tests;

pub use keywords::{
    BuiltinKind, KeywordKind, detect_opener, find_builtin, find_keyword, is_compound_prefix,
    is_reserved,
};
pub use profile::{Profile, detect_opening_profile, fold_text};
pub use signatures::{BuiltinSignature, signature_for_builtin};
