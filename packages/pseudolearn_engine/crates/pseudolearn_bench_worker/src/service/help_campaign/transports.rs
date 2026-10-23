use pseudolearn_api::ApiSession;
use pseudolearn_api::service::LspServer;
use serde_json::{Value, json};

const DOCUMENT_URI: &str = "file:///campaign.pseudo";
const MARKDOWN_SPECIALS: &str = "\\`*_{}[]()#+-.!|<>~&:/@";

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct Range {
    pub start_line: u64,
    pub start_column: u64,
    pub end_line: u64,
    pub end_column: u64,
}

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub struct Answer {
    pub has_resolution: bool,
    pub has_symbol: bool,
    pub certainty: String,
    pub card_id: Option<String>,
    pub title: Option<String>,
    pub range: Option<Range>,
}

pub struct ApiTransport {
    session: ApiSession,
    resource: u64,
    language: String,
}

impl ApiTransport {
    pub fn open(
        program: &str,
        profile: &str,
        strictness: &str,
        language: &str,
    ) -> Result<Self, String> {
        let mut session = ApiSession::default();
        let opened = session.call(
            "open_edit_session",
            &json!({"program": program, "profile": profile, "strictness": strictness}),
        );
        let resource = opened
            .pointer("/value/resource")
            .and_then(Value::as_u64)
            .ok_or_else(|| format!("open_edit_session failed: {opened}"))?;
        Ok(Self {
            session,
            resource,
            language: language.to_owned(),
        })
    }

    pub fn query(&mut self, line: u32, column: u32) -> Result<Answer, String> {
        let response = self.session.call(
            "help_query",
            &json!({
                "resource": self.resource, "revision": "1",
                "position": {"line": line, "column": column, "unit": "unicode_scalar"},
                "language": self.language, "detail": "summary"
            }),
        );
        let value = response
            .get("value")
            .ok_or_else(|| format!("help_query failed: {response}"))?;
        Ok(answer_from_response(value))
    }
}

pub fn answer_from_response(value: &Value) -> Answer {
    let resolution = value.get("resolution").filter(|entry| !entry.is_null());
    let text = |pointer: &str| {
        value
            .pointer(pointer)
            .and_then(Value::as_str)
            .map(str::to_owned)
    };
    Answer {
        has_resolution: resolution.is_some(),
        has_symbol: value
            .pointer("/resolution/symbol")
            .is_some_and(|symbol| !symbol.is_null()),
        certainty: text("/resolution/certainty").unwrap_or_default(),
        card_id: text("/card/id"),
        title: text("/card/title"),
        range: resolution
            .and_then(|entry| entry.get("lexical_range"))
            .map(range_of),
    }
}

fn range_of(range: &Value) -> Range {
    let number = |pointer: &str| range.pointer(pointer).and_then(Value::as_u64).unwrap_or(0);
    Range {
        start_line: number("/start/line"),
        start_column: number("/start/column"),
        end_line: number("/end/line"),
        end_column: number("/end/column"),
    }
}

pub struct LspTransport {
    server: LspServer,
    lines: Vec<String>,
}

impl LspTransport {
    pub fn open(program: &str, locale: &str, strictness: &str) -> Self {
        let mut server = LspServer::new();
        server.handle_message(&json!({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"locale": locale, "initializationOptions": {"strictness": strictness}}
        }));
        server.handle_message(&json!({
            "jsonrpc": "2.0", "method": "textDocument/didOpen",
            "params": {"textDocument": {"uri": DOCUMENT_URI, "languageId": "pseudolearn", "version": 1, "text": program}}
        }));
        Self {
            server,
            lines: program.split('\n').map(str::to_owned).collect(),
        }
    }

    pub fn hover(&mut self, line: u32, scalar_column: u32) -> (Option<String>, Option<Range>) {
        let character = self.utf16_character(line, scalar_column);
        let reply = self
            .server
            .handle_message(&json!({
                "jsonrpc": "2.0", "id": 2, "method": "textDocument/hover",
                "params": {"textDocument": {"uri": DOCUMENT_URI},
                    "position": {"line": line.saturating_sub(1), "character": character}}
            }))
            .into_iter()
            .next()
            .unwrap_or(Value::Null);
        let text = reply
            .pointer("/result/contents/value")
            .and_then(Value::as_str)
            .map(str::to_owned);
        let range = reply.pointer("/result/range").map(|range| {
            let number =
                |pointer: &str| range.pointer(pointer).and_then(Value::as_u64).unwrap_or(0);
            Range {
                start_line: number("/start/line"),
                start_column: number("/start/character"),
                end_line: number("/end/line"),
                end_column: number("/end/character"),
            }
        });
        (text, range)
    }

    pub fn utf16_character(&self, line: u32, scalar_column: u32) -> u64 {
        let text = usize::try_from(line.saturating_sub(1))
            .ok()
            .and_then(|index| self.lines.get(index))
            .map_or("", String::as_str);
        let skipped = usize::try_from(scalar_column.saturating_sub(1)).unwrap_or(0);
        text.chars()
            .take(skipped)
            .map(|glyph| u64::try_from(glyph.len_utf16()).unwrap_or(0))
            .sum()
    }
}

pub fn escape_markdown(value: &str) -> String {
    let mut escaped = String::with_capacity(value.len());
    for glyph in value.chars() {
        if MARKDOWN_SPECIALS.contains(glyph) {
            escaped.push('\\');
        }
        escaped.push(glyph);
    }
    escaped
}
