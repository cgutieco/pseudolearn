use crate::manifest_error::Location;
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum LockKind {
    Local,
    Locked,
}

impl LockKind {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Local => "local",
            Self::Locked => "locked",
        }
    }

    pub(crate) fn from_name(name: &str) -> Option<Self> {
        match name {
            "local" => Some(Self::Local),
            "locked" => Some(Self::Locked),
            _ => None,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LockPackage {
    pub name: String,
    pub origin: String,
    pub kind: LockKind,
    pub dependencies: Vec<String>,
    pub digest: Option<String>,
    pub files: BTreeMap<String, String>,
    pub position: Location,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Lock {
    pub packages: BTreeMap<String, LockPackage>,
}

pub const DIGEST_PREFIX: &str = "sha256:";
const DIGEST_HEX_LENGTH: usize = 64;

pub fn is_digest(text: &str) -> bool {
    text.strip_prefix(DIGEST_PREFIX).is_some_and(|hex| {
        hex.len() == DIGEST_HEX_LENGTH
            && hex
                .bytes()
                .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
    })
}
