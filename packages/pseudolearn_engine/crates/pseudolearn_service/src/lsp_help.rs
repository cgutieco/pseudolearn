use crate::help_catalog::HelpLocale;
use crate::help_content::help_content;
use crate::help_rendering::{HelpFormat, escape_markdown, render_help};
use crate::help_resolution::{HelpQueryOutcome, resolve_help_with_locale};
use crate::lsp_protocol::{
    CONTENT_MODIFIED, INVALID_PARAMS, failure, lsp_range, position_from_request, success,
    text_document_uri,
};
use crate::lsp_session::LspServer;
use serde_json::{Value, json};

pub const EXPLAIN_COMMAND: &str = "pseudolearn.explain";

impl LspServer {
    fn help_locale(&self) -> HelpLocale {
        HelpLocale::from_code(&self.locale).unwrap_or(HelpLocale::Spanish)
    }

    pub(crate) fn handle_hover(&self, message: &Value) -> Value {
        let result = self.explain(text_document_uri(message), message, HelpFormat::Markdown);
        success(message, result.unwrap_or(Value::Null))
    }

    pub(crate) fn handle_execute_command(&self, message: &Value) -> Value {
        let command = message.pointer("/params/command").and_then(Value::as_str);
        if command != Some(EXPLAIN_COMMAND) {
            return failure(message, INVALID_PARAMS, "unknown command");
        }
        let Some(arguments) = message.pointer("/params/arguments/0") else {
            return failure(message, INVALID_PARAMS, "missing command arguments");
        };
        let uri = arguments.get("uri").and_then(Value::as_str).unwrap_or("");
        let Some(version) = arguments.get("version").and_then(Value::as_i64) else {
            return failure(message, INVALID_PARAMS, "missing document version");
        };
        if self.versions.get(uri) != Some(&version) {
            return failure(message, CONTENT_MODIFIED, "document version is stale");
        }
        let format = match arguments.get("format").and_then(Value::as_str) {
            Some("plaintext") => HelpFormat::PlainText,
            _ => HelpFormat::Markdown,
        };
        let request = json!({ "params": { "position": arguments.get("position") } });
        let result = self.explain(uri, &request, format);
        success(message, result.unwrap_or(Value::Null))
    }

    fn explain(&self, uri: &str, request: &Value, format: HelpFormat) -> Option<Value> {
        let session = self.service.session(uri)?;
        let position = position_from_request(session.text(), request);
        let locale = self.help_locale();
        let outcome = resolve_help_with_locale(session, position, locale)?;
        let value = hover_text(&outcome, locale, format)?;
        let kind = match format {
            HelpFormat::Markdown => "markdown",
            HelpFormat::PlainText => "plaintext",
        };
        Some(json!({
            "contents": { "kind": kind, "value": value },
            "range": lsp_range(session.text(), outcome.resolution.lexical_range)
        }))
    }
}

fn hover_text(
    outcome: &HelpQueryOutcome,
    locale: HelpLocale,
    format: HelpFormat,
) -> Option<String> {
    let mut blocks = Vec::new();
    if let Some(hover) = &outcome.hover {
        blocks.push(headline(hover, format));
    }
    if let Some(content) =
        help_content(outcome, locale).map(|content| render_help(&content, locale, format))
    {
        blocks.push(content);
    } else if let Some(description) = outcome
        .hover
        .as_ref()
        .and_then(|hover| hover.description.as_ref())
    {
        blocks.push(description.clone());
    }
    (!blocks.is_empty()).then(|| blocks.join("\n\n"))
}

fn headline(hover: &crate::hover::HoverOutcome, format: HelpFormat) -> String {
    if let (Some(signature), HelpFormat::Markdown) = (&hover.signature, format) {
        return format!("```\n{signature}\n```");
    }
    let line = match &hover.signature {
        Some(signature) => signature.clone(),
        None if hover.type_name.is_empty() => hover.identifier.clone(),
        None => format!("{}: {}", hover.identifier, hover.type_name),
    };
    match format {
        HelpFormat::Markdown => escape_markdown(&line),
        HelpFormat::PlainText => line,
    }
}
