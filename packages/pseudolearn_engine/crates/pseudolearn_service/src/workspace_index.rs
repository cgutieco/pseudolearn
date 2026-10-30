use crate::workspace_analysis::WorkspaceBuildRequest;
use crate::workspace_invalidation::compare_workspace;
use crate::workspace_model::{WorkspaceFileState, WorkspaceIndex, WorkspaceResult};
use pseudolearn_project::ProjectInput;
use pseudolearn_semantic::ResolvedUnitProfile;
use std::collections::BTreeMap;

pub(super) fn project_failure(
    request: &WorkspaceBuildRequest<'_>,
    project: &ProjectInput,
    profiles: BTreeMap<String, ResolvedUnitProfile>,
    errors: Vec<pseudolearn_project::ProjectError>,
) -> (WorkspaceResult, WorkspaceIndex) {
    let index = base_index(project, &request.snapshot.options, profiles);
    let invalidation = compare_workspace(request.previous, &index);
    let result = WorkspaceResult {
        project_id: project.project_id,
        revision_id: project.revision_id,
        hir: None,
        service_analysis: None,
        diagnostics: Vec::new(),
        project_errors: errors,
        imports: Vec::new(),
        invalidation,
    };
    (result, index)
}

pub(super) fn entry_failure(
    request: &WorkspaceBuildRequest<'_>,
    project: &ProjectInput,
    profiles: BTreeMap<String, ResolvedUnitProfile>,
    error: pseudolearn_project::ProjectError,
) -> (WorkspaceResult, WorkspaceIndex) {
    project_failure(request, project, profiles, vec![error])
}

pub(super) fn base_index(
    project: &ProjectInput,
    options: &crate::workspace_model::WorkspaceOptions,
    profiles: BTreeMap<String, ResolvedUnitProfile>,
) -> WorkspaceIndex {
    let files = project
        .files
        .iter()
        .map(|file| {
            (
                portable_key(&file.path),
                WorkspaceFileState {
                    path: file.path.clone(),
                    source_id: file.source_id,
                    text: file.text.clone(),
                },
            )
        })
        .collect();
    WorkspaceIndex {
        packages: project.packages.clone(),
        options: options.clone(),
        files,
        profiles,
        units: BTreeMap::new(),
        imports: Vec::new(),
        modules: BTreeMap::new(),
    }
}

pub(super) fn portable_key(path: &str) -> String {
    pseudolearn_project::logical_path_key(path).unwrap_or_else(|| path.to_owned())
}
