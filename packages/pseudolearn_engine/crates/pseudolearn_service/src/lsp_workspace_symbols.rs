use crate::lsp_project_selection::{identifier_range, lsp_range, to_index};
use crate::lsp_protocol::failure;
use crate::lsp_session::LspServer;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_semantic::{ServiceSymbol, ServiceSymbolCategory, ServiceSymbolTarget};
use serde_json::{Value, json};

impl LspServer {
    pub(crate) fn project_workspace_symbols(&self, message: &Value) -> Value {
        if self.request_cancelled() {
            return failure(message, -32800, "request cancelled");
        }
        let query = message
            .pointer("/params/query")
            .and_then(Value::as_str)
            .unwrap_or("");
        let symbols = self
            .workspace_session
            .as_ref()
            .and_then(|workspace| workspace.result().service_analysis.as_ref())
            .map(|analysis| {
                analysis
                    .symbols
                    .iter()
                    .filter_map(|symbol| self.workspace_symbol(symbol, query))
                    .collect::<Vec<_>>()
            })
            .unwrap_or_default();
        json!({"jsonrpc":"2.0","id":message.get("id"),"result":symbols})
    }

    fn workspace_symbol(&self, symbol: &ServiceSymbol, query: &str) -> Option<Value> {
        if self.request_cancelled() || !global_symbol_matches(symbol, query) {
            return None;
        }
        let target = symbol_target(symbol)?;
        if !self.target_is_public(target) {
            return None;
        }
        let workspace = self.workspace_session.as_ref()?;
        let analysis = workspace.result().service_analysis.as_ref()?;
        let definition = analysis.definition_span(target)?;
        let (path, text) = workspace.file_by_source_id(definition.source_id.value())?;
        let display_name = symbol.name.rsplit('.').next()?;
        let (start, ending) = identifier_range(
            text,
            (to_index(definition.start), to_index(definition.ending)),
            display_name,
            false,
        )?;
        let target_uri = self.uri_for_path(path)?;
        Some(json!({
            "name":display_name,
            "kind":symbol_kind(symbol.category),
            "location":{"uri":target_uri,"range":lsp_range(text,start,ending)}
        }))
    }

    fn target_is_public(&self, target: ServiceSymbolTarget) -> bool {
        let Some(workspace) = self.workspace_session.as_ref() else {
            return false;
        };
        let Some(analysis) = workspace.result().service_analysis.as_ref() else {
            return false;
        };
        match target {
            ServiceSymbolTarget::Function(function) => {
                analysis.module.units.exported.contains(&function)
                    || analysis
                        .module
                        .functions
                        .get(to_index(function.0))
                        .is_some_and(|entry| !entry.private)
            }
            ServiceSymbolTarget::Class(class) => class_is_public(workspace, analysis, class),
            _ => false,
        }
    }
}

fn global_symbol_matches(symbol: &ServiceSymbol, query: &str) -> bool {
    matches!(
        symbol.category,
        ServiceSymbolCategory::Function | ServiceSymbolCategory::Class
    ) && symbol.name.contains(query)
}

fn symbol_target(symbol: &ServiceSymbol) -> Option<ServiceSymbolTarget> {
    match symbol.category {
        ServiceSymbolCategory::Function => Some(ServiceSymbolTarget::Function(
            pseudolearn_semantic::FunctionId(u32::try_from(symbol.identifier).unwrap_or(u32::MAX)),
        )),
        ServiceSymbolCategory::Class => Some(ServiceSymbolTarget::Class(
            pseudolearn_semantic::ClassId(u32::try_from(symbol.identifier).unwrap_or(u32::MAX)),
        )),
        _ => None,
    }
}

fn class_is_public(
    workspace: &crate::workspace_session::WorkspaceSession,
    analysis: &pseudolearn_semantic::ServiceAnalysis,
    class: pseudolearn_semantic::ClassId,
) -> bool {
    let Some(entry) = analysis.module.classes.get(to_index(class.0)) else {
        return false;
    };
    let Some((_, text)) = workspace.file_by_source_id(entry.span.source_id.value()) else {
        return false;
    };
    let profile = analysis
        .module
        .source_profiles
        .get(&entry.span.source_id)
        .copied()
        .unwrap_or_default();
    let visibility = KeywordKind::PublicVisibility.lexeme(profile).unwrap_or("");
    let start = usize::try_from(entry.span.start).unwrap_or(0);
    !visibility.is_empty()
        && text
            .get(start..)
            .unwrap_or("")
            .trim_start()
            .starts_with(visibility)
}

fn symbol_kind(category: ServiceSymbolCategory) -> u32 {
    match category {
        ServiceSymbolCategory::Class => 5,
        ServiceSymbolCategory::Method => 6,
        ServiceSymbolCategory::Field => 8,
        ServiceSymbolCategory::Function | ServiceSymbolCategory::Procedure => 12,
        ServiceSymbolCategory::Variable | ServiceSymbolCategory::Parameter => 13,
    }
}
