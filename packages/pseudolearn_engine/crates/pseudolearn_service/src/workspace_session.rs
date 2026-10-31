use crate::workspace_analysis::{WorkspaceBuildRequest, build_workspace};
use crate::workspace_model::{
    WorkspaceError, WorkspaceIndex, WorkspaceOverlay, WorkspaceResult, WorkspaceSnapshot,
};
use crate::workspace_snapshot::{
    document_key, empty_invalidation, rebase_overlays, same_snapshot_content,
};
use pseudolearn_lexicon::Profile;
use pseudolearn_project::logical_path_key;
use std::collections::BTreeMap;

#[path = "workspace_session_cold.rs"]
mod cold;
#[path = "workspace_document.rs"]
mod document;

use document::DocumentUpdate;

pub struct WorkspaceSession {
    snapshot: WorkspaceSnapshot,
    revision_id: u64,
    overlays: BTreeMap<String, WorkspaceOverlay>,
    index: WorkspaceIndex,
    result: WorkspaceResult,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum SnapshotUpdateMode {
    Advance,
    Resynchronize,
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

    pub(crate) fn files(&self) -> impl Iterator<Item = (&str, u32, &str)> {
        self.index
            .files
            .values()
            .map(|file| (file.path.as_str(), file.source_id, file.text.as_str()))
    }

    pub(crate) fn file_by_source_id(&self, source_id: u32) -> Option<(&str, &str)> {
        let path = self.index.source_paths.get(&source_id)?;
        self.index
            .files
            .get(path)
            .map(|file| (file.path.as_str(), file.text.as_str()))
    }

    pub(crate) fn file_by_path(&self, path: &str) -> Option<(u32, &str)> {
        let key = document_key(path).ok()?;
        self.index
            .files
            .get(&key)
            .map(|file| (file.source_id, file.text.as_str()))
    }

    pub(crate) fn profile_for_path(&self, path: &str) -> Option<Profile> {
        let key = document_key(path).ok()?;
        self.index.profiles.get(&key).map(|profile| profile.profile)
    }

    pub(crate) fn strict(&self) -> bool {
        self.index.options.strict
    }

    pub(crate) fn update_configuration(
        &mut self,
        profile: Profile,
        strict: bool,
    ) -> Result<(), WorkspaceError> {
        if self.index.options.requested_profile == Some(profile)
            && self.index.options.strict == strict
        {
            return Ok(());
        }
        let mut snapshot = self.snapshot.clone();
        snapshot.options.requested_profile = Some(profile);
        snapshot.options.strict = strict;
        self.commit_candidate(snapshot, self.overlays.clone(), self.next_revision()?)
    }

    pub fn open_document(
        &mut self,
        path: &str,
        version: u64,
        text: String,
    ) -> Result<(), WorkspaceError> {
        self.update_document(DocumentUpdate {
            path: path.to_owned(),
            version,
            text,
            require_open: false,
        })
    }

    pub fn change_document(
        &mut self,
        path: &str,
        version: u64,
        text: String,
    ) -> Result<(), WorkspaceError> {
        self.update_document(DocumentUpdate {
            path: path.to_owned(),
            version,
            text,
            require_open: true,
        })
    }

    pub fn close_document(&mut self, path: &str) -> Result<(), WorkspaceError> {
        let key = document_key(path)?;
        if !self.overlays.contains_key(&key) {
            return Err(WorkspaceError::DocumentNotOpen);
        }
        let same_as_snapshot = self
            .overlays
            .get(&key)
            .zip(
                self.snapshot
                    .project
                    .files
                    .iter()
                    .find(|file| logical_path_key(&file.path).as_deref() == Some(key.as_str())),
            )
            .is_some_and(|(current, file)| current.text == file.text);
        if same_as_snapshot {
            self.overlays.remove(&key);
            return Ok(());
        }
        let revision_id = self.next_revision()?;
        let previous = self
            .overlays
            .remove(&key)
            .ok_or(WorkspaceError::DocumentNotOpen)?;
        if let Err(error) = self.commit_current(revision_id) {
            self.overlays.insert(key, previous);
            return Err(error);
        }
        Ok(())
    }

    pub fn update_snapshot(
        &mut self,
        snapshot: WorkspaceSnapshot,
        mode: SnapshotUpdateMode,
    ) -> Result<(), WorkspaceError> {
        self.check_snapshot_identity(&snapshot)?;
        let revision_did_not_advance = match mode {
            SnapshotUpdateMode::Advance => {
                snapshot.project.revision_id <= self.snapshot.project.revision_id
            }
            SnapshotUpdateMode::Resynchronize => {
                snapshot.project.revision_id < self.snapshot.project.revision_id
            }
        };
        if revision_did_not_advance {
            return Err(WorkspaceError::SnapshotRevisionDidNotAdvance);
        }
        self.commit_snapshot(snapshot)
    }

    fn commit_snapshot(&mut self, snapshot: WorkspaceSnapshot) -> Result<(), WorkspaceError> {
        let overlays = rebase_overlays(&self.overlays, &snapshot)?;
        let revision_id = self.next_revision()?.max(snapshot.project.revision_id);
        if same_snapshot_content(&self.snapshot, &snapshot) && overlays == self.overlays {
            self.snapshot = snapshot;
            self.overlays = overlays;
            self.revision_id = revision_id;
            self.result.revision_id = revision_id;
            self.result.invalidation = empty_invalidation();
            return Ok(());
        }
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

    fn commit_current(&mut self, revision_id: u64) -> Result<(), WorkspaceError> {
        let (result, index) = build_workspace(WorkspaceBuildRequest {
            snapshot: &self.snapshot,
            overlays: &self.overlays,
            revision_id,
            previous: Some(&self.index),
        })?;
        self.revision_id = revision_id;
        self.index = index;
        self.result = result;
        Ok(())
    }

    fn restore_overlay(&mut self, key: String, previous: Option<WorkspaceOverlay>) {
        match previous {
            Some(overlay) => {
                self.overlays.insert(key, overlay);
            }
            None => {
                self.overlays.remove(&key);
            }
        }
    }
}
