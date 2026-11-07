use crate::ExecutionReport;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ProgramPromise {
    pub output: Option<String>,
    pub diagnostics: Option<Vec<String>>,
    pub termination: Option<String>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct ProgramSource {
    pub id: String,
    pub title: String,
    pub execute: bool,
    pub code: String,
    pub inputs: Vec<String>,
    pub host: Option<String>,
    pub promise: ProgramPromise,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ExampleCheck {
    pub location: String,
    pub promise: ProgramPromise,
    pub source_report: ExecutionReport,
    pub target_report: ExecutionReport,
}
