#[derive(Clone, Copy, Debug, Eq, PartialEq, Ord, PartialOrd)]
pub enum Scenario {
    BodyEdit,
    SignatureEdit,
    ManifestChange,
    ClosedFileChange,
    Rename,
    WorkspaceLoad,
    WorkspaceSymbol,
    StaleSource,
    EmptyProject,
    ShortNames,
    UnicodeSource,
}

pub const DIAGNOSTIC_THRESHOLD_MILLIS: f64 = 100.0;
pub const RENAME_THRESHOLD_MILLIS: f64 = 500.0;

impl Scenario {
    pub const SAMPLED: [Scenario; 7] = [
        Scenario::BodyEdit,
        Scenario::SignatureEdit,
        Scenario::ManifestChange,
        Scenario::ClosedFileChange,
        Scenario::Rename,
        Scenario::WorkspaceLoad,
        Scenario::WorkspaceSymbol,
    ];
    pub const CORRECTNESS: [Scenario; 4] = [
        Scenario::StaleSource,
        Scenario::EmptyProject,
        Scenario::ShortNames,
        Scenario::UnicodeSource,
    ];

    pub fn name(self) -> &'static str {
        match self {
            Scenario::BodyEdit => "body-edit",
            Scenario::SignatureEdit => "signature-edit",
            Scenario::ManifestChange => "manifest-change",
            Scenario::ClosedFileChange => "closed-file-change",
            Scenario::Rename => "rename",
            Scenario::WorkspaceLoad => "workspace-load",
            Scenario::WorkspaceSymbol => "workspace-symbol",
            Scenario::StaleSource => "stale-source",
            Scenario::EmptyProject => "empty-project",
            Scenario::ShortNames => "short-names",
            Scenario::UnicodeSource => "unicode-source",
        }
    }

    pub fn from_name(name: &str) -> Option<Scenario> {
        Self::SAMPLED
            .iter()
            .chain(Self::CORRECTNESS.iter())
            .find(|scenario| scenario.name() == name)
            .copied()
    }

    pub fn threshold_millis(self) -> Option<f64> {
        match self {
            Scenario::Rename => Some(RENAME_THRESHOLD_MILLIS),
            Scenario::BodyEdit
            | Scenario::SignatureEdit
            | Scenario::ManifestChange
            | Scenario::ClosedFileChange => Some(DIAGNOSTIC_THRESHOLD_MILLIS),
            Scenario::WorkspaceLoad | Scenario::WorkspaceSymbol => None,
            _ => None,
        }
    }
}
