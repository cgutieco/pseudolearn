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
    #[serde(rename = "RUTA-FORMAT")]
    RouteFormat,
    #[serde(rename = "RUTA-ANATOMY")]
    RouteAnatomy,
    #[serde(rename = "RUTA-TERM-OWNER")]
    RouteTermOwner,
    #[serde(rename = "RUTA-TERM-ORDER")]
    RouteTermOrder,
    #[serde(rename = "RUTA-RECALL-SOURCE")]
    RouteRecallSource,
    #[serde(rename = "RUTA-PREREQ")]
    RoutePrerequisite,
    #[serde(rename = "RUTA-SPEC-LINK")]
    RouteSpecLink,
    #[serde(rename = "RUTA-LINK-VALID")]
    RouteLinkValid,
    #[serde(rename = "RUTA-NO-SPEC-DUP")]
    RouteNoSpecDuplicate,
    #[serde(rename = "RUTA-EXAMPLE-VERIFIED")]
    RouteExampleVerified,
    #[serde(rename = "RUTA-EXERCISE-VERIFIED")]
    RouteExerciseVerified,
    #[serde(rename = "RUTA-EXERCISE-MIX")]
    RouteExerciseMix,
    #[serde(rename = "RUTA-STATEMENT-NO-RECIPE")]
    RouteStatementNoRecipe,
    #[serde(rename = "RUTA-HINTS")]
    RouteHints,
    #[serde(rename = "RUTA-SCAFFOLD")]
    RouteScaffold,
    #[serde(rename = "RUTA-PARITY")]
    RouteParity,
    #[serde(rename = "RUTA-BUNDLE-STALE")]
    RouteBundleStale,
    #[serde(rename = "REF-WEB-BUNDLE-STALE")]
    WebBundleStale,
    #[serde(rename = "RUTA-WEB-BUNDLE-STALE")]
    WebRouteBundleStale,
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
            Self::RouteFormat => "RUTA-FORMAT",
            Self::RouteAnatomy => "RUTA-ANATOMY",
            Self::RouteTermOwner => "RUTA-TERM-OWNER",
            Self::RouteTermOrder => "RUTA-TERM-ORDER",
            Self::RouteRecallSource => "RUTA-RECALL-SOURCE",
            Self::RoutePrerequisite => "RUTA-PREREQ",
            Self::RouteSpecLink => "RUTA-SPEC-LINK",
            Self::RouteLinkValid => "RUTA-LINK-VALID",
            Self::RouteNoSpecDuplicate => "RUTA-NO-SPEC-DUP",
            Self::RouteExampleVerified => "RUTA-EXAMPLE-VERIFIED",
            Self::RouteExerciseVerified => "RUTA-EXERCISE-VERIFIED",
            Self::RouteExerciseMix => "RUTA-EXERCISE-MIX",
            Self::RouteStatementNoRecipe => "RUTA-STATEMENT-NO-RECIPE",
            Self::RouteHints => "RUTA-HINTS",
            Self::RouteScaffold => "RUTA-SCAFFOLD",
            Self::RouteParity => "RUTA-PARITY",
            Self::RouteBundleStale => "RUTA-BUNDLE-STALE",
            Self::WebBundleStale => "REF-WEB-BUNDLE-STALE",
            Self::WebRouteBundleStale => "RUTA-WEB-BUNDLE-STALE",
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
