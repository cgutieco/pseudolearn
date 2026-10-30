use crate::document_session::DocumentSession;
use crate::lsp_protocol::{success, text_document_uri};
use crate::lsp_session::LspServer;
use crate::positions::lsp_position_at;
use pseudolearn_semantic::{ServiceSymbolCategory, ServiceSymbolTarget};
use pseudolearn_source::Span;
use pseudolearn_syntax::TokenKind;
use serde_json::{Value, json};

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

#[derive(Default)]
struct SemanticTokenEncoder {
    values: Vec<u32>,
    previous_line: u32,
    previous_character: u32,
}

impl SemanticTokenEncoder {
    fn append(&mut self, text: &str, span: Span, token_type: u32) {
        let start = usize::try_from(span.start).unwrap_or(0);
        let ending = usize::try_from(span.ending).unwrap_or(start);
        let Some(token_text) = text.get(start..ending) else {
            return;
        };
        let (line, character) = lsp_position_at(text, start);
        let line_delta = line.saturating_sub(self.previous_line);
        let character_delta = if line_delta == 0 {
            character.saturating_sub(self.previous_character)
        } else {
            character
        };
        self.values.extend([
            line_delta,
            character_delta,
            u32::try_from(token_text.encode_utf16().count()).unwrap_or(u32::MAX),
            token_type,
            0,
        ]);
        self.previous_line = line;
        self.previous_character = character;
    }
}

fn encode_semantic_tokens(
    session: &DocumentSession,
    cancellation: Option<&crate::request_cancellation::RequestCancellation>,
) -> Vec<u32> {
    let mut encoder = SemanticTokenEncoder::default();
    for index in 0..session.tree.tokens.token_count() {
        if cancellation.is_some_and(crate::request_cancellation::RequestCancellation::is_cancelled)
        {
            return Vec::new();
        }
        let Some((span, token_type)) = encoded_token(session, index) else {
            continue;
        };
        encoder.append(session.text(), span, token_type);
    }
    encoder.values
}

fn encoded_token(session: &DocumentSession, index: usize) -> Option<(Span, u32)> {
    let span = session.tree.tokens.span(index)?;
    let kind = session.tree.tokens.kind(index)?;
    Some((span, semantic_token_type(session, span, kind)?))
}

fn semantic_token_type(session: &DocumentSession, span: Span, kind: TokenKind) -> Option<u32> {
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
        TokenKind::Identifier => return identifier_token_type(session, span),
        _ => return None,
    };
    Some(lexical)
}

fn identifier_token_type(session: &DocumentSession, span: Span) -> Option<u32> {
    let Some(occurrence) = session.index.at_token_span(span) else {
        return Some(5);
    };
    Some(match occurrence.target {
        ServiceSymbolTarget::Local(identifier) => session
            .analysis
            .symbols
            .iter()
            .find(|symbol| symbol.identifier == usize::try_from(identifier.0).unwrap_or(usize::MAX))
            .map_or(5, |symbol| match symbol.category {
                ServiceSymbolCategory::Parameter => 9,
                _ => 5,
            }),
        ServiceSymbolTarget::Function(_) => 6,
        ServiceSymbolTarget::Class(_) => 7,
        ServiceSymbolTarget::Field(_) => 8,
        ServiceSymbolTarget::Builtin(_) => 5,
    })
}
