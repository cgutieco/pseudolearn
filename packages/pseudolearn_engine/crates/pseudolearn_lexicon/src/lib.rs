#![forbid(unsafe_code)]

mod hash;

pub mod keywords;
pub mod profile;
pub mod signatures;

pub use keywords::{
    BuiltinKind, KeywordKind, detect_opener, find_builtin, find_keyword, is_compound_prefix,
};
pub use profile::{Profile, fold_text};
pub use signatures::{BuiltinSignature, signature_for_builtin};
