use serde::Serialize;

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd, Serialize)]
pub enum RuleId {
    #[serde(rename = "REF-FORMAT")]
    Format,
    #[serde(rename = "REF-EXAMPLE-VERIFIED")]
    ExampleVerified,
    #[serde(rename = "REF-ANCHOR-VALID")]
    AnchorValid,
    #[serde(rename = "REF-ANCHOR-STALE")]
    AnchorStale,
    #[serde(rename = "REF-COVERAGE")]
    Coverage,
    #[serde(rename = "REF-ANATOMY")]
    Anatomy,
    #[serde(rename = "REF-PARITY")]
    Parity,
    #[serde(rename = "REF-INLINE-CODE")]
    InlineCode,
    #[serde(rename = "REF-FIGURE-CONTRACT")]
    FigureContract,
    #[serde(rename = "REF-NO-INTERNAL-IDS")]
    NoInternalIds,
    #[serde(rename = "REF-FIGURE-NARROW")]
    FigureNarrow,
    #[serde(rename = "REF-BUNDLE-STALE")]
    BundleStale,
    #[serde(rename = "REF-LINK-VALID")]
    LinkValid,
}

impl RuleId {
    pub fn code(self) -> &'static str {
        match self {
            Self::Format => "REF-FORMAT",
            Self::ExampleVerified => "REF-EXAMPLE-VERIFIED",
            Self::AnchorValid => "REF-ANCHOR-VALID",
            Self::AnchorStale => "REF-ANCHOR-STALE",
            Self::Coverage => "REF-COVERAGE",
            Self::Anatomy => "REF-ANATOMY",
            Self::Parity => "REF-PARITY",
            Self::InlineCode => "REF-INLINE-CODE",
            Self::FigureContract => "REF-FIGURE-CONTRACT",
            Self::NoInternalIds => "REF-NO-INTERNAL-IDS",
            Self::FigureNarrow => "REF-FIGURE-NARROW",
            Self::BundleStale => "REF-BUNDLE-STALE",
            Self::LinkValid => "REF-LINK-VALID",
        }
    }
}

#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct Violation {
    pub rule: RuleId,
    pub location: String,
    pub detail: String,
}

impl Violation {
    pub fn new(rule: RuleId, location: impl Into<String>, detail: impl Into<String>) -> Self {
        Self {
            rule,
            location: location.into(),
            detail: detail.into(),
        }
    }
}

impl std::fmt::Display for Violation {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            formatter,
            "{}: {} {}",
            self.location,
            self.rule.code(),
            self.detail
        )
    }
}
