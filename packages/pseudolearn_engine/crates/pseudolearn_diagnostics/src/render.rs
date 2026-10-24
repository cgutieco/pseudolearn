use crate::arguments::{DiagnosticArgument, TypeName};
use crate::diagnostic::{Diagnostic, DiagnosticClass, DiagnosticSeverity};
use pseudolearn_source::SourceId;
use std::collections::BTreeMap;

pub fn render(diagnostic: &Diagnostic, locale: &str) -> String {
    let template = diagnostic.code.template(locale);
    let mut remaining = template;
    let mut rendered = String::new();
    while let Some(opening) = remaining.find('{') {
        rendered.push_str(remaining.get(..opening).unwrap_or(""));
        let suffix = remaining.get(opening.saturating_add(1)..).unwrap_or("");
        let Some(closing) = suffix.find('}') else {
            rendered.push_str(remaining);
            return rendered;
        };
        let name = suffix.get(..closing).unwrap_or("");
        if let Some(value) = diagnostic.arguments.get(name) {
            rendered.push_str(&value.text());
        }
        remaining = suffix.get(closing.saturating_add(1)..).unwrap_or("");
    }
    rendered.push_str(remaining);
    rendered
}

pub fn sort_diagnostics(diagnostics: &mut [Diagnostic]) {
    sort_diagnostics_with(diagnostics, &BTreeMap::new());
}

pub fn sort_diagnostics_with(
    diagnostics: &mut [Diagnostic],
    source_keys: &BTreeMap<SourceId, Vec<String>>,
) {
    diagnostics.sort_by_cached_key(|diagnostic| order_key(diagnostic, source_keys));
}

#[derive(Eq, Ord, PartialEq, PartialOrd)]
struct DiagnosticOrderKey {
    source: SourceOrderKey,
    class: DiagnosticClass,
    start: u32,
    ending: u32,
    code: &'static str,
    severity: DiagnosticSeverity,
    arguments: Vec<(String, u8, String)>,
    related: Vec<RelatedOrderKey>,
}

#[derive(Eq, Ord, PartialEq, PartialOrd)]
enum SourceOrderKey {
    Available(Vec<String>),
    Missing,
}

#[derive(Eq, Ord, PartialEq, PartialOrd)]
struct RelatedOrderKey {
    source: SourceOrderKey,
    start: u32,
    ending: u32,
}

fn order_key(
    diagnostic: &Diagnostic,
    source_keys: &BTreeMap<SourceId, Vec<String>>,
) -> DiagnosticOrderKey {
    DiagnosticOrderKey {
        source: source_key(diagnostic.span.source_id, source_keys),
        class: diagnostic.class,
        start: diagnostic.span.start,
        ending: diagnostic.span.ending,
        code: diagnostic.code.as_str(),
        severity: diagnostic.severity,
        arguments: diagnostic
            .arguments
            .iter()
            .map(|(name, argument)| argument_key(name, argument))
            .collect(),
        related: diagnostic
            .related
            .iter()
            .map(|span| RelatedOrderKey {
                source: source_key(span.source_id, source_keys),
                start: span.start,
                ending: span.ending,
            })
            .collect(),
    }
}

fn source_key(
    source_id: SourceId,
    source_keys: &BTreeMap<SourceId, Vec<String>>,
) -> SourceOrderKey {
    source_keys
        .get(&source_id)
        .cloned()
        .map_or(SourceOrderKey::Missing, SourceOrderKey::Available)
}

fn argument_key(name: &str, argument: &DiagnosticArgument) -> (String, u8, String) {
    let (kind, value) = match argument {
        DiagnosticArgument::Lexeme(value) => (0, value.clone()),
        DiagnosticArgument::Token(value) => (1, value.clone()),
        DiagnosticArgument::Type(value) => match &value.name {
            TypeName::Token(name) => (2, format!("0:{name}:{}", value.rank)),
            TypeName::Named(name) => (2, format!("1:{name}:{}", value.rank)),
        },
        DiagnosticArgument::Term(value) => (3, value.clone()),
        DiagnosticArgument::Number(value) => (4, value.to_string()),
    };
    (name.to_owned(), kind, value)
}
