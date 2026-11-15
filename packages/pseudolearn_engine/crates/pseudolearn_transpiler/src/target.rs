use pseudolearn_lexicon::Profile;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TargetLanguage {
    Rust,
    Python,
}

impl TargetLanguage {
    pub fn from_identity(identity: &str) -> Option<Self> {
        match identity {
            "rust" => Some(Self::Rust),
            "python" => Some(Self::Python),
            _ => None,
        }
    }

    pub fn identity(self) -> &'static str {
        match self {
            Self::Rust => "rust",
            Self::Python => "python",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct TranspileRequest {
    pub target: TargetLanguage,
    pub profile: Profile,
    pub seed: Option<i64>,
    pub truth: &'static str,
    pub falsity: &'static str,
}
