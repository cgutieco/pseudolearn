use crate::{Profile, ProgramView};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RawToken {
    pub kind: String,
    pub keyword: Option<String>,
    pub start: usize,
    pub end: usize,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct EngineDiagnostic {
    pub code: String,
    pub severity: String,
    pub line: u64,
    pub column: u64,
    pub spanish: String,
    pub english: String,
}

impl EngineDiagnostic {
    pub fn message(&self, language: Profile) -> &str {
        match language {
            Profile::Spanish => &self.spanish,
            Profile::English => &self.english,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExecutionRequest {
    pub code: String,
    pub profile: Profile,
    pub inputs: Vec<String>,
    pub host: Option<String>,
    pub trace: bool,
    pub statement_limit: Option<u64>,
    pub depth_limit: Option<usize>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct TraceRecord {
    pub line: u64,
    pub class: String,
    pub detail: String,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ExecutionReport {
    pub output: String,
    pub termination: String,
    pub diagnostics: Vec<EngineDiagnostic>,
    pub trace: Vec<TraceRecord>,
}

pub trait CodeEngine {
    fn tokenize(&self, code: &str, profile: Profile) -> Vec<RawToken>;
    fn translate(&self, code: &str, target: Profile) -> Result<String, String>;
    fn execute(&self, request: &ExecutionRequest) -> ExecutionReport;
    fn intermediate(&self, code: &str, profile: Profile) -> Result<String, String>;
    fn program_view(&self, code: &str, profile: Profile) -> Result<ProgramView, String>;
    fn fingerprint(&self) -> String;
}
