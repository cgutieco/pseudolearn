use crate::lsp_protocol::lsp_range_from_offsets;
use crate::lsp_session::LspServer;
use crate::workspace_session::WorkspaceSession;
use pseudolearn_diagnostics::{DiagnosticSeverity, render::render};
use pseudolearn_source::{SourceId, SourceText};
use serde_json::{Value, json};

struct ProjectDiagnosticContext<'context> {
    locale: &'context str,
    related_support: bool,
    workspace: &'context WorkspaceSession,
    uris: &'context std::collections::BTreeMap<String, String>,
}

struct WorkspaceDiagnosticDocument<'document> {
    uri: &'document str,
    source_id: u32,
    text: &'document str,
    version: Option<&'document i64>,
}

impl LspServer {
    pub(crate) fn diagnostics_notification(&self, uri: &str) -> Option<Value> {
        let session = self.service.session(uri)?;
        let diagnostics = session
            .diagnostics()
            .iter()
            .map(|diagnostic| single_document_diagnostic(diagnostic, session.text(), &self.locale))
            .collect();
        Some(publish(uri, diagnostics))
    }

    pub(crate) fn workspace_diagnostics_notifications(&self) -> Vec<Value> {
        let Some(workspace) = self.workspace_session.as_ref() else {
            return Vec::new();
        };
        let context = ProjectDiagnosticContext {
            locale: &self.locale,
            related_support: self.client_related_information,
            workspace,
            uris: &self.workspace_uris,
        };
        workspace
            .files()
            .filter_map(|(path, source_id, text)| {
                let uri = self.workspace_uris.get(path)?;
                Some(workspace_diagnostic_notification(
                    WorkspaceDiagnosticDocument {
                        uri,
                        source_id,
                        text,
                        version: self.versions.get(uri),
                    },
                    &context,
                ))
            })
            .collect()
    }
}

fn workspace_diagnostic_notification(
    document: WorkspaceDiagnosticDocument<'_>,
    context: &ProjectDiagnosticContext<'_>,
) -> Value {
    let source = pseudolearn_source::source_text_with_source_id(
        SourceId::new(document.source_id),
        document.text.to_owned(),
    );
    let diagnostics = context
        .workspace
        .result()
        .diagnostics
        .iter()
        .filter(|diagnostic| diagnostic.span.source_id == SourceId::new(document.source_id))
        .map(|diagnostic| project_diagnostic(diagnostic, &source, context))
        .collect::<Vec<_>>();
    let mut notification_parameters = json!({"uri":document.uri,"diagnostics":diagnostics});
    if let Some(version) = document.version
        && let Some(fields) = notification_parameters.as_object_mut()
    {
        let _ = fields.insert("version".to_owned(), json!(version));
    }
    json!({
        "jsonrpc":"2.0",
        "method":"textDocument/publishDiagnostics",
        "params":notification_parameters
    })
}

fn single_document_diagnostic(
    diagnostic: &pseudolearn_diagnostics::Diagnostic,
    text: &str,
    locale: &str,
) -> Value {
    let start = usize::try_from(diagnostic.span.start).unwrap_or(0);
    let ending = usize::try_from(diagnostic.span.ending).unwrap_or(start);
    json!({
        "range":lsp_range_from_offsets(text,start,ending),
        "severity":severity_code(diagnostic.severity),
        "code":diagnostic.code.as_str(),
        "message":render(diagnostic,locale),
        "source":"pseudolearn"
    })
}

pub(crate) fn publish(uri: &str, diagnostics: Vec<Value>) -> Value {
    json!({
        "jsonrpc": "2.0",
        "method": "textDocument/publishDiagnostics",
        "params": { "uri": uri, "diagnostics": diagnostics }
    })
}

fn severity_code(severity: DiagnosticSeverity) -> u32 {
    match severity {
        DiagnosticSeverity::Error => 1,
        DiagnosticSeverity::Warning => 2,
        DiagnosticSeverity::Information => 3,
    }
}

fn project_diagnostic(
    diagnostic: &pseudolearn_diagnostics::Diagnostic,
    source: &SourceText,
    context: &ProjectDiagnosticContext<'_>,
) -> Value {
    let start = usize::try_from(diagnostic.span.start).unwrap_or(0);
    let ending = usize::try_from(diagnostic.span.ending).unwrap_or(start);
    let mut value = json!({
        "range": lsp_range_from_offsets(source.as_str(), start, ending),
        "severity": severity_code(diagnostic.severity),
        "code": diagnostic.code.as_str(),
        "message": render(diagnostic, context.locale),
        "source": "pseudolearn"
    });
    if context.related_support
        && !diagnostic.related.is_empty()
        && let Some(fields) = value.as_object_mut()
    {
        let _ = fields.insert(
            "relatedInformation".to_owned(),
            json!(related_diagnostic_locations(diagnostic, context)),
        );
    }
    value
}

fn related_diagnostic_locations(
    diagnostic: &pseudolearn_diagnostics::Diagnostic,
    context: &ProjectDiagnosticContext<'_>,
) -> Vec<Value> {
    diagnostic
        .related
        .iter()
        .filter_map(|span| {
            let (path, text) = context.workspace.file_by_source_id(span.source_id.value())?;
            let uri = context.uris.get(path)?;
            let start = usize::try_from(span.start).unwrap_or(0);
            let ending = usize::try_from(span.ending).unwrap_or(start);
            Some(json!({
                "location":{"uri":uri,"range":lsp_range_from_offsets(text,start,ending)},
                "message":if context.locale == "en" { "Related location" } else { "Lugar relacionado" }
            }))
        })
        .collect()
}
