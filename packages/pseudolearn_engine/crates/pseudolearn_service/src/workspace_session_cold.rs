use super::WorkspaceSession;
use crate::workspace_analysis::{WorkspaceBuildRequest, build_workspace};

impl WorkspaceSession {
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
            && cold.service_analysis == self.result.service_analysis
            && cold.diagnostics == self.result.diagnostics
            && cold.project_errors == self.result.project_errors
            && cold.imports == self.result.imports
    }
}
