use crate::document_session::DocumentSession;
use crate::lsp_protocol::{success, text_document_uri};
use crate::lsp_session::LspServer;
use crate::positions::lsp_position_at_with_index;
use pseudolearn_semantic::template_model::TemplateKind;
use pseudolearn_semantic::{ServiceSymbolCategory, ServiceSymbolTarget};
use pseudolearn_source::{LineIndex, Span};
use pseudolearn_syntax::TokenKind;
use serde_json::{Value, json};
use std::collections::BTreeSet;

impl LspServer {
    pub(crate) fn handle_semantic_tokens(&self, message: &Value) -> Value {
        let encoded_tokens = self
            .service
            .session(text_document_uri(message))
            .map(|session| encode_semantic_tokens(session, self.active_cancellation.as_ref()))
            .unwrap_or_default();
        success(message, json!({"data":encoded_tokens}))
    }
}

struct SemanticTokenEncoder {
    index: LineIndex,
    values: Vec<u32>,
    previous_line: u32,
    previous_character: u32,
}

impl SemanticTokenEncoder {
    fn new(text: &str) -> Self {
        Self {
            index: LineIndex::build(text),
            values: Vec::new(),
            previous_line: 0,
            previous_character: 0,
        }
    }

    fn append(&mut self, text: &str, span: Span, token_type: u32) {
        let start = usize::try_from(span.start).unwrap_or(0);
        let ending = usize::try_from(span.ending).unwrap_or(start);
        let Some(token_text) = text.get(start..ending) else {
            return;
        };
        for (offset, segment) in line_segments(token_text) {
            self.push(text, (start.saturating_add(offset), segment), token_type);
        }
    }

    fn push(&mut self, text: &str, (start, segment): (usize, &str), token_type: u32) {
        let (line, character) = lsp_position_at_with_index(text, start, &self.index);
        let line_delta = line.saturating_sub(self.previous_line);
        let character_delta = if line_delta == 0 {
            character.saturating_sub(self.previous_character)
        } else {
            character
        };
        self.values.extend([
            line_delta,
            character_delta,
            u32::try_from(segment.encode_utf16().count()).unwrap_or(u32::MAX),
            token_type,
            0,
        ]);
        self.previous_line = line;
        self.previous_character = character;
    }
}

fn line_segments(token_text: &str) -> Vec<(usize, &str)> {
    let mut segments = Vec::new();
    let mut segment_start = 0;
    let mut characters = token_text.char_indices().peekable();
    while let Some((offset, character)) = characters.next() {
        if character != '\n' && character != '\r' {
            continue;
        }
        segments.push((segment_start, token_text.get(segment_start..offset)));
        let crlf = character == '\r' && characters.next_if(|(_, next)| *next == '\n').is_some();
        segment_start = offset.saturating_add(if crlf { 2 } else { 1 });
    }
    segments.push((segment_start, token_text.get(segment_start..)));
    segments
        .into_iter()
        .filter_map(|(offset, segment)| {
            segment
                .filter(|segment| !segment.is_empty())
                .map(|segment| (offset, segment))
        })
        .collect()
}

fn encode_semantic_tokens(
    session: &DocumentSession,
    cancellation: Option<&crate::request_cancellation::RequestCancellation>,
) -> Vec<u32> {
    let mut encoder = SemanticTokenEncoder::new(session.text());
    let parameters = parameter_identifiers(session);
    let contextual = crate::contextual_tokens::collect(
        &session.tree,
        &session.source,
        &session.analysis,
        session.profile,
    );
    for index in 0..session.tree.tokens.token_count() {
        if cancellation.is_some_and(crate::request_cancellation::RequestCancellation::is_cancelled)
        {
            return Vec::new();
        }
        let Some((span, token_type)) = encoded_token(session, &parameters, index) else {
            continue;
        };
        let token_type = if contextual.contains_key(&index) {
            0
        } else {
            token_type
        };
        encoder.append(session.text(), span, token_type);
    }
    encoder.values
}

fn parameter_identifiers(session: &DocumentSession) -> BTreeSet<usize> {
    session
        .analysis
        .symbols
        .iter()
        .filter(|symbol| symbol.category == ServiceSymbolCategory::Parameter)
        .map(|symbol| symbol.identifier)
        .collect()
}

fn encoded_token(
    session: &DocumentSession,
    parameters: &BTreeSet<usize>,
    index: usize,
) -> Option<(Span, u32)> {
    let span = session.tree.tokens.span(index)?;
    let kind = session.tree.tokens.kind(index)?;
    Some((span, semantic_token_type(session, parameters, span, kind)?))
}

fn semantic_token_type(
    session: &DocumentSession,
    parameters: &BTreeSet<usize>,
    span: Span,
    kind: TokenKind,
) -> Option<u32> {
    let lexical = match kind {
        TokenKind::Whitespace | TokenKind::Newline | TokenKind::EndOfFile => return None,
        TokenKind::Comment => 4,
        TokenKind::IntegerLiteral | TokenKind::RealLiteral => 2,
        TokenKind::StringLiteral | TokenKind::CharacterLiteral | TokenKind::BooleanLiteral(_) => 3,
        TokenKind::Keyword(_) => 0,
        TokenKind::Plus
        | TokenKind::Minus
        | TokenKind::Star
        | TokenKind::Slash
        | TokenKind::Power
        | TokenKind::Modulo
        | TokenKind::IntegerDivision
        | TokenKind::Equal
        | TokenKind::NotEqual
        | TokenKind::Less
        | TokenKind::LessEqual
        | TokenKind::Greater
        | TokenKind::GreaterEqual
        | TokenKind::LogicalAnd
        | TokenKind::LogicalOr
        | TokenKind::LogicalNot
        | TokenKind::Assignment => 1,
        TokenKind::Identifier => return identifier_token_type(session, parameters, span),
        _ => return None,
    };
    Some(lexical)
}

fn identifier_token_type(
    session: &DocumentSession,
    parameters: &BTreeSet<usize>,
    span: Span,
) -> Option<u32> {
    let Some(occurrence) = session.index.at_token_span(span) else {
        return Some(5);
    };
    Some(match occurrence.target {
        ServiceSymbolTarget::Local(identifier) => {
            if parameters.contains(&usize::try_from(identifier.0).unwrap_or(usize::MAX)) {
                9
            } else {
                5
            }
        }
        ServiceSymbolTarget::Function(_) => 6,
        ServiceSymbolTarget::Class(_) => 7,
        ServiceSymbolTarget::Field(_) => 8,
        ServiceSymbolTarget::Record(_)
        | ServiceSymbolTarget::Enum(_)
        | ServiceSymbolTarget::Interface(_) => 10,
        ServiceSymbolTarget::Constant(_) | ServiceSymbolTarget::Builtin(_) => 5,
        ServiceSymbolTarget::Template(identifier) => template_token_type(session, identifier),
        ServiceSymbolTarget::TypeParameter(_, _) => 11,
    })
}

fn template_token_type(
    session: &DocumentSession,
    identifier: pseudolearn_semantic::template_model::TemplateId,
) -> u32 {
    let kind = usize::try_from(identifier.0)
        .ok()
        .and_then(|slot| session.analysis.module.templates.get(slot))
        .map(|template| template.kind);
    match kind {
        Some(TemplateKind::Subprogram) => 6,
        Some(TemplateKind::Class) => 7,
        _ => 10,
    }
}
