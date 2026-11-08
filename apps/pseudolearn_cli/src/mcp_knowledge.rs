use crate::mcp_program_tools::{invalid, locale_of, text};
use serde_json::{Value, json};

const SPANISH_SHEET: &str = include_str!("../generated/language-sheet.es.md");
const ENGLISH_SHEET: &str = include_str!("../generated/language-sheet.en.md");
const RESOURCE_PREFIX: &str = "pseudolearn://language-sheet/";
const RESULT_LIMIT: usize = 5;
const EXCERPT_CHARACTERS: usize = 400;

pub(crate) struct SheetSection<'sheet> {
    pub(crate) title: &'sheet str,
    pub(crate) body: &'sheet str,
}

pub(crate) fn sheet(locale: &str) -> &'static str {
    if locale == "en" {
        ENGLISH_SHEET
    } else {
        SPANISH_SHEET
    }
}

pub(crate) fn resource_list() -> Value {
    let resources: Vec<Value> = ["es", "en"]
        .iter()
        .map(|locale| {
            json!({
                "uri": format!("{RESOURCE_PREFIX}{locale}"),
                "name": format!("language-sheet-{locale}"),
                "mimeType": "text/markdown"
            })
        })
        .collect();
    json!({ "resources": resources })
}

pub(crate) fn read_resource(parameters: &Value) -> Option<Value> {
    let uri = parameters.get("uri").and_then(Value::as_str)?;
    let locale = uri
        .strip_prefix(RESOURCE_PREFIX)
        .filter(|locale| ["es", "en"].contains(locale))?;
    Some(json!({"contents": [{"uri": uri, "mimeType": "text/markdown", "text": sheet(locale)}]}))
}

pub(crate) fn sections(markdown: &str) -> Vec<SheetSection<'_>> {
    let mut found = Vec::new();
    let mut remaining = markdown;
    while let Some(start) = remaining.find("\n## ").or_else(|| remaining.find("\n### ")) {
        let heading = remaining
            .get(start..)
            .unwrap_or_default()
            .trim_start_matches('\n');
        let title_end = heading.find('\n').unwrap_or(heading.len());
        let title = heading
            .get(..title_end)
            .unwrap_or_default()
            .trim_start_matches('#')
            .trim();
        let rest = heading.get(title_end..).unwrap_or_default();
        let body_end = rest
            .find("\n## ")
            .into_iter()
            .chain(rest.find("\n### "))
            .min()
            .unwrap_or(rest.len());
        found.push(SheetSection {
            title,
            body: rest.get(..body_end).unwrap_or_default().trim(),
        });
        remaining = rest.get(body_end..).unwrap_or_default();
    }
    found
}

pub(crate) fn search_reference(arguments: &Value) -> (Value, bool) {
    let Some(query) = text(arguments, "query") else {
        return invalid();
    };
    let words: Vec<String> = query
        .split_whitespace()
        .map(str::to_lowercase)
        .filter(|word| word.chars().count() > 1)
        .collect();
    let mut scored: Vec<(usize, SheetSection<'_>)> = sections(sheet(locale_of(arguments)))
        .into_iter()
        .map(|section| (score(&section, &words), section))
        .filter(|(points, _)| *points > 0)
        .collect();
    scored.sort_by_key(|(points, _)| std::cmp::Reverse(*points));
    let results: Vec<Value> = scored
        .into_iter()
        .take(RESULT_LIMIT)
        .map(|(_, section)| json!({"title": section.title, "excerpt": excerpt(section.body)}))
        .collect();
    (json!({"results": results}), false)
}

pub(crate) fn example(arguments: &Value) -> (Value, bool) {
    let examples: Vec<SheetSection<'_>> = sections(sheet(locale_of(arguments)))
        .into_iter()
        .filter(|section| section.title.starts_with('`') && section.title.contains('#'))
        .collect();
    let Some(identity) = text(arguments, "id") else {
        let ids: Vec<&str> = examples
            .iter()
            .map(|section| section.title.trim_matches('`'))
            .collect();
        return (json!({"examples": ids}), false);
    };
    match examples
        .iter()
        .find(|section| section.title.trim_matches('`') == identity)
    {
        Some(section) => (example_payload(identity, section.body), false),
        None => (json!({"error": "not_found"}), true),
    }
}

fn example_payload(identity: &str, body: &str) -> Value {
    let blocks: Vec<&str> = body.split("```").collect();
    let program = blocks
        .get(1)
        .map_or("", |block| block.trim_start_matches("pseudolearn\n"));
    let output = blocks
        .get(3)
        .map_or("", |block| block.trim_start_matches("text\n"));
    json!({"id": identity, "program": program, "expected_output": output})
}

fn score(section: &SheetSection<'_>, words: &[String]) -> usize {
    let title = section.title.to_lowercase();
    let body = section.body.to_lowercase();
    words
        .iter()
        .map(|word| {
            title
                .matches(word.as_str())
                .count()
                .saturating_mul(3)
                .saturating_add(body.matches(word.as_str()).count().min(3))
        })
        .fold(0_usize, usize::saturating_add)
}

fn excerpt(body: &str) -> String {
    body.chars().take(EXCERPT_CHARACTERS).collect()
}
