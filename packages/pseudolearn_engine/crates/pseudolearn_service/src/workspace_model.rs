use crate::unit_partition::UnitFingerprint;
use pseudolearn_diagnostics::Diagnostic;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    Configuration, ImportEdge, MalformedProject, ModuleId, PackageInput, ProjectError, ProjectInput,
};
use pseudolearn_semantic::{HirModule, ResolvedUnitProfile, ServiceAnalysis};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct WorkspaceOptions {
    pub requested_profile: Option<Profile>,
    pub file_profiles: BTreeMap<String, Profile>,
    pub strict: bool,
    pub entry: Option<String>,
    pub configurations: Vec<Configuration>,
    pub dependency_inputs: BTreeMap<String, String>,
}

impl Default for WorkspaceOptions {
    fn default() -> Self {
        Self {
            requested_profile: None,
            file_profiles: BTreeMap::new(),
            strict: true,
            entry: None,
            configurations: Vec::new(),
            dependency_inputs: BTreeMap::new(),
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct WorkspaceSnapshot {
    pub project: ProjectInput,
    pub options: WorkspaceOptions,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct WorkspaceInvalidation {
    pub changed_modules: Vec<String>,
    pub signature_changed_modules: Vec<String>,
    pub invalidated_modules: Vec<String>,
}

pub struct WorkspaceResult {
    pub project_id: u64,
    pub revision_id: u64,
    pub hir: Option<HirModule>,
    pub service_analysis: Option<ServiceAnalysis>,
    pub diagnostics: Vec<Diagnostic>,
    pub project_errors: Vec<ProjectError>,
    pub imports: Vec<ImportEdge>,
    pub invalidation: WorkspaceInvalidation,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum WorkspaceError {
    MalformedProject(MalformedProject),
    ProjectIdentityChanged,
    SnapshotRevisionDidNotAdvance,
    InvalidDocumentPath,
    DocumentNotFound,
    DocumentNotOpen,
    DocumentVersionDidNotAdvance,
    RevisionExhausted,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct WorkspaceFileState {
    pub path: String,
    pub source_id: u32,
    pub text: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct WorkspaceOverlay {
    pub path: String,
    pub source_id: u32,
    pub version: u64,
    pub text: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub(crate) struct WorkspaceIndex {
    pub packages: Vec<PackageInput>,
    pub options: WorkspaceOptions,
    pub files: BTreeMap<String, WorkspaceFileState>,
    pub profiles: BTreeMap<String, ResolvedUnitProfile>,
    pub units: BTreeMap<String, Vec<UnitFingerprint>>,
    pub imports: Vec<ImportEdge>,
    pub modules: BTreeMap<ModuleId, String>,
}
