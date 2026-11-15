use super::WorkspaceSession;
use crate::workspace_model::{WorkspaceError, WorkspaceOverlay};
use crate::workspace_snapshot::document_key;

pub(super) struct DocumentUpdate {
    pub path: String,
    pub version: u64,
    pub text: String,
    pub require_open: bool,
}

impl WorkspaceSession {
    pub(super) fn update_document(
        &mut self,
        request: DocumentUpdate,
    ) -> Result<(), WorkspaceError> {
        let key = document_key(&request.path)?;
        let previous = self.overlays.get(&key);
        if request.require_open && previous.is_none() {
            return Err(WorkspaceError::DocumentNotOpen);
        }
        self.check_version(&key, request.version)?;
        let file = self.index.files.get(&key);
        let (path, source_id, unchanged) = match (previous, file) {
            (Some(overlay), _) => (
                overlay.path.clone(),
                overlay.source_id,
                overlay.text == request.text,
            ),
            (None, Some(file)) => (file.path.clone(), file.source_id, file.text == request.text),
            (None, None) => return Err(WorkspaceError::DocumentNotFound),
        };
        let replacement = WorkspaceOverlay {
            path,
            source_id,
            version: request.version,
            text: request.text,
        };
        if unchanged {
            self.overlays.insert(key, replacement);
            return Ok(());
        }
        let revision_id = self.next_revision()?;
        let previous = self.overlays.insert(key.clone(), replacement);
        if let Err(error) = self.commit_current(revision_id) {
            self.restore_overlay(key, previous);
            return Err(error);
        }
        Ok(())
    }
}
