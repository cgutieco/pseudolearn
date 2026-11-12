use crate::workspace_model::{
    WorkspaceError, WorkspaceInvalidation, WorkspaceOverlay, WorkspaceSnapshot,
};
use pseudolearn_project::{FileInput, logical_path_key};
use std::collections::BTreeMap;

pub(crate) fn same_snapshot_content(left: &WorkspaceSnapshot, right: &WorkspaceSnapshot) -> bool {
    left.project.project_id == right.project.project_id
        && left.project.packages == right.project.packages
        && left.project.files == right.project.files
        && left.options == right.options
}

pub(crate) fn empty_invalidation() -> WorkspaceInvalidation {
    WorkspaceInvalidation {
        changed_modules: Vec::new(),
        signature_changed_modules: Vec::new(),
        invalidated_modules: Vec::new(),
    }
}

pub(crate) fn document_key(path: &str) -> Result<String, WorkspaceError> {
    logical_path_key(path).ok_or(WorkspaceError::InvalidDocumentPath)
}

pub(crate) fn rebase_overlays(
    overlays: &BTreeMap<String, WorkspaceOverlay>,
    snapshot: &WorkspaceSnapshot,
) -> Result<BTreeMap<String, WorkspaceOverlay>, WorkspaceError> {
    let files: BTreeMap<String, &FileInput> = snapshot
        .project
        .files
        .iter()
        .map(|file| {
            logical_path_key(&file.path)
                .map(|key| (key, file))
                .ok_or(WorkspaceError::InvalidDocumentPath)
        })
        .collect::<Result<_, _>>()?;
    Ok(overlays
        .iter()
        .map(|(key, overlay)| {
            let mut rebased = overlay.clone();
            if let Some(file) = files.get(key) {
                rebased.path.clone_from(&file.path);
                rebased.source_id = file.source_id;
            }
            (key.clone(), rebased)
        })
        .collect())
}
