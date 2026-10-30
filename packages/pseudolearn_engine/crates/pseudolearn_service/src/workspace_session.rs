use crate::workspace_analysis::{WorkspaceBuildRequest, build_workspace};
use crate::workspace_model::{
    WorkspaceError, WorkspaceIndex, WorkspaceOverlay, WorkspaceResult, WorkspaceSnapshot,
};
use pseudolearn_project::{FileInput, logical_path_key};
use std::collections::BTreeMap;

pub struct WorkspaceSession {
    snapshot: WorkspaceSnapshot,
    revision_id: u64,
    overlays: BTreeMap<String, WorkspaceOverlay>,
    index: WorkspaceIndex,
    result: WorkspaceResult,
}

impl WorkspaceSession {
    pub fn new(snapshot: WorkspaceSnapshot) -> Result<Self, WorkspaceError> {
        let revision_id = snapshot.project.revision_id;
        let overlays = BTreeMap::new();
        let (result, index) = build_workspace(WorkspaceBuildRequest {
            snapshot: &snapshot,
            overlays: &overlays,
            revision_id,
            previous: None,
        })?;
        Ok(Self {
            snapshot,
            revision_id,
            overlays,
            index,
            result,
        })
    }

    pub fn result(&self) -> &WorkspaceResult {
        &self.result
    }

    pub fn revision_id(&self) -> u64 {
        self.revision_id
    }

    pub fn matches_cold_analysis(&self) -> bool {
        let Ok((cold, _)) = build_workspace(WorkspaceBuildRequest {
            snapshot: &self.snapshot,
            overlays: &self.overlays,
            revision_id: self.revision_id,
            previous: None,
        }) else {
            return false;
        };
        cold.hir == self.result.hir
            && cold.diagnostics == self.result.diagnostics
            && cold.project_errors == self.result.project_errors
            && cold.imports == self.result.imports
    }

    pub fn is_open(&self, path: &str) -> bool {
        document_key(path).is_ok_and(|key| self.overlays.contains_key(&key))
    }

    pub fn open_document(
        &mut self,
        path: &str,
        version: u64,
        text: String,
    ) -> Result<(), WorkspaceError> {
        let key = document_key(path)?;
        self.check_version(&key, version)?;
        let file = self
            .find_file(&key)
            .ok_or(WorkspaceError::DocumentNotFound)?;
        let mut overlays = self.overlays.clone();
        overlays.insert(
            key,
            WorkspaceOverlay {
                path: file.path,
                source_id: file.source_id,
                version,
                text,
            },
        );
        self.commit_candidate(self.snapshot.clone(), overlays, self.next_revision()?)
    }

    pub fn change_document(
        &mut self,
        path: &str,
        version: u64,
        text: String,
    ) -> Result<(), WorkspaceError> {
        let key = document_key(path)?;
        let previous = self
            .overlays
            .get(&key)
            .ok_or(WorkspaceError::DocumentNotOpen)?;
        if version <= previous.version {
            return Err(WorkspaceError::DocumentVersionDidNotAdvance);
        }
        let mut overlays = self.overlays.clone();
        let overlay = overlays
            .get_mut(&key)
            .ok_or(WorkspaceError::DocumentNotOpen)?;
        overlay.version = version;
        overlay.text = text;
        self.commit_candidate(self.snapshot.clone(), overlays, self.next_revision()?)
    }

    pub fn close_document(&mut self, path: &str) -> Result<(), WorkspaceError> {
        let key = document_key(path)?;
        if !self.overlays.contains_key(&key) {
            return Err(WorkspaceError::DocumentNotOpen);
        }
        let mut overlays = self.overlays.clone();
        overlays.remove(&key);
        self.commit_candidate(self.snapshot.clone(), overlays, self.next_revision()?)
    }

    pub fn update_snapshot(&mut self, snapshot: WorkspaceSnapshot) -> Result<(), WorkspaceError> {
        self.check_snapshot_identity(&snapshot)?;
        if snapshot.project.revision_id <= self.snapshot.project.revision_id {
            return Err(WorkspaceError::SnapshotRevisionDidNotAdvance);
        }
        self.commit_snapshot(snapshot)
    }

    pub fn resynchronize(&mut self, snapshot: WorkspaceSnapshot) -> Result<(), WorkspaceError> {
        self.check_snapshot_identity(&snapshot)?;
        if snapshot.project.revision_id < self.snapshot.project.revision_id {
            return Err(WorkspaceError::SnapshotRevisionDidNotAdvance);
        }
        self.commit_snapshot(snapshot)
    }

    fn commit_snapshot(&mut self, snapshot: WorkspaceSnapshot) -> Result<(), WorkspaceError> {
        let overlays = rebase_overlays(&self.overlays, &snapshot)?;
        let revision_id = self.next_revision()?.max(snapshot.project.revision_id);
        self.commit_candidate(snapshot, overlays, revision_id)
    }

    fn check_snapshot_identity(&self, snapshot: &WorkspaceSnapshot) -> Result<(), WorkspaceError> {
        if snapshot.project.project_id != self.snapshot.project.project_id {
            return Err(WorkspaceError::ProjectIdentityChanged);
        }
        Ok(())
    }

    fn check_version(&self, key: &str, version: u64) -> Result<(), WorkspaceError> {
        if self
            .overlays
            .get(key)
            .is_some_and(|previous| version <= previous.version)
        {
            return Err(WorkspaceError::DocumentVersionDidNotAdvance);
        }
        Ok(())
    }

    fn find_file(&self, key: &str) -> Option<FileInput> {
        self.snapshot
            .project
            .files
            .iter()
            .find(|file| logical_path_key(&file.path).as_deref() == Some(key))
            .cloned()
            .or_else(|| {
                self.overlays.get(key).map(|overlay| FileInput {
                    path: overlay.path.clone(),
                    source_id: overlay.source_id,
                    text: overlay.text.clone(),
                })
            })
    }

    fn next_revision(&self) -> Result<u64, WorkspaceError> {
        self.revision_id
            .checked_add(1)
            .ok_or(WorkspaceError::RevisionExhausted)
    }

    fn commit_candidate(
        &mut self,
        snapshot: WorkspaceSnapshot,
        overlays: BTreeMap<String, WorkspaceOverlay>,
        revision_id: u64,
    ) -> Result<(), WorkspaceError> {
        let (result, index) = build_workspace(WorkspaceBuildRequest {
            snapshot: &snapshot,
            overlays: &overlays,
            revision_id,
            previous: Some(&self.index),
        })?;
        self.snapshot = snapshot;
        self.overlays = overlays;
        self.revision_id = revision_id;
        self.index = index;
        self.result = result;
        Ok(())
    }
}

fn document_key(path: &str) -> Result<String, WorkspaceError> {
    logical_path_key(path).ok_or(WorkspaceError::InvalidDocumentPath)
}

fn rebase_overlays(
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
