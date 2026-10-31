use crate::lsp_protocol::lsp_range_from_offsets;
use crate::lsp_session::LspServer;
use crate::positions::offset_from_lsp;
use pseudolearn_semantic::ServiceSymbolTarget;
use pseudolearn_source::{IdentifierNormalizer, SourceId};
use serde_json::Value;

pub(super) struct SelectedSymbol {
    pub(super) source_id: SourceId,
    pub(super) target: ServiceSymbolTarget,
    pub(super) name: String,
    pub(super) range: (usize, usize),
}

impl LspServer {
    pub(super) fn selected_project_symbol(
        &self,
        uri: &str,
        message: &Value,
    ) -> Option<SelectedSymbol> {
        let path = self.path_for_uri(uri)?;
        let workspace = self.workspace_session.as_ref()?;
        let (source_id, text) = workspace.file_by_path(&path)?;
        let (offset, name) = selected_identifier(text, message)?;
        let source_id = SourceId::new(source_id);
        let analysis = workspace.result().service_analysis.as_ref()?;
        let reference = analysis.reference_at_source_offset(source_id, offset)?;
        let target_name = target_name(analysis, reference.target)?;
        let target_identifier = target_name.rsplit('.').next()?;
        if IdentifierNormalizer::normalize(&name)
            != IdentifierNormalizer::normalize(target_identifier)
        {
            return None;
        }
        let range = identifier_range(
            text,
            (
                to_index(reference.span.start),
                to_index(reference.span.ending),
            ),
            &name,
            !reference.is_declaration,
        )?;
        Some(SelectedSymbol {
            source_id,
            target: reference.target,
            name,
            range,
        })
    }
}

fn selected_identifier(text: &str, message: &Value) -> Option<(usize, String)> {
    let line = u32::try_from(message.pointer("/params/position/line")?.as_u64()?).ok()?;
    let character = u32::try_from(message.pointer("/params/position/character")?.as_u64()?).ok()?;
    let offset = offset_from_lsp(text, line, character);
    Some((offset, identifier_at(text, offset)?.to_owned()))
}

fn target_name(
    analysis: &pseudolearn_semantic::ServiceAnalysis,
    target: ServiceSymbolTarget,
) -> Option<String> {
    match target {
        ServiceSymbolTarget::Local(local) => analysis
            .module
            .locals
            .get(to_index(local.0))
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Function(function) => analysis
            .module
            .functions
            .get(to_index(function.0))
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Class(class) => analysis
            .module
            .classes
            .get(to_index(class.0))
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Field(field) => analysis
            .module
            .classes
            .iter()
            .flat_map(|candidate| &candidate.fields)
            .find(|candidate| candidate.id == field)
            .map(|candidate| candidate.name.clone()),
        ServiceSymbolTarget::Builtin(_) => None,
    }
}

pub(super) fn to_index(value: u32) -> usize {
    usize::try_from(value).unwrap_or(usize::MAX)
}

pub(super) fn to_u32(value: usize) -> u32 {
    u32::try_from(value).unwrap_or(u32::MAX)
}

fn identifier_at(text: &str, offset: usize) -> Option<&str> {
    let bounded = offset.min(text.len());
    let mut start = bounded;
    while start > 0 {
        let previous = text.get(..start)?.char_indices().next_back()?;
        if !identifier_continue(previous.1) {
            break;
        }
        start = previous.0;
    }
    let mut ending = bounded;
    for (relative, glyph) in text.get(bounded..)?.char_indices() {
        if !identifier_continue(glyph) {
            break;
        }
        ending = bounded
            .saturating_add(relative)
            .saturating_add(glyph.len_utf8());
    }
    text.get(start..ending).filter(|value| !value.is_empty())
}

pub(super) fn identifier_range(
    text: &str,
    span: (usize, usize),
    name: &str,
    last: bool,
) -> Option<(usize, usize)> {
    let (start, ending) = span;
    let source = text.get(start..ending)?;
    let mut matches = source.char_indices().filter_map(|(offset, glyph)| {
        if !identifier_start(glyph) {
            return None;
        }
        let token_start = start.saturating_add(offset);
        let suffix = text.get(token_start..)?;
        let token = suffix
            .char_indices()
            .take_while(|(_, candidate)| identifier_continue(*candidate))
            .map(|(index, candidate)| index.saturating_add(candidate.len_utf8()))
            .last()?;
        let token_ending = token_start.saturating_add(token);
        let candidate = text.get(token_start..token_ending)?;
        (IdentifierNormalizer::normalize(candidate) == IdentifierNormalizer::normalize(name))
            .then_some((token_start, token_ending))
    });
    if last {
        matches.next_back()
    } else {
        matches.next()
    }
}

fn identifier_start(glyph: char) -> bool {
    glyph == '_' || glyph.is_alphabetic()
}

fn identifier_continue(glyph: char) -> bool {
    IdentifierNormalizer::is_continuation(glyph)
}

pub(super) fn lsp_range(text: &str, start: usize, ending: usize) -> Value {
    lsp_range_from_offsets(text, start, ending)
}
