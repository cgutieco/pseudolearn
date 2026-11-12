use crate::lsp_session::LspServer;
use pseudolearn_semantic::{ServiceReference, ServiceSymbolTarget};
use pseudolearn_source::SourceId;

impl LspServer {
    pub(crate) fn imported_type_ranges(&self, uri: &str, document_text: &str) -> Vec<(u32, u32)> {
        let Some(path) = self.path_for_uri(uri) else {
            return Vec::new();
        };
        let Some(workspace) = self.workspace_session.as_ref() else {
            return Vec::new();
        };
        let Some((source_id, text)) = workspace.file_by_path(&path) else {
            return Vec::new();
        };
        let Some(analysis) = workspace.result().service_analysis.as_ref() else {
            return Vec::new();
        };
        if text != document_text {
            return Vec::new();
        }
        let source_id = SourceId::new(source_id);
        analysis
            .occurrences
            .iter()
            .filter(|reference| names_imported_type(reference, source_id))
            .map(|reference| (reference.span.start, reference.span.ending))
            .collect()
    }
}

fn names_imported_type(reference: &ServiceReference, source_id: SourceId) -> bool {
    reference.span.source_id == source_id
        && !reference.is_declaration
        && matches!(
            reference.target,
            ServiceSymbolTarget::Record(_)
                | ServiceSymbolTarget::Enum(_)
                | ServiceSymbolTarget::Interface(_)
                | ServiceSymbolTarget::Constant(_)
                | ServiceSymbolTarget::Template(_)
        )
}
