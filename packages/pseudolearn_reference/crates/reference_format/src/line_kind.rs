use crate::fence::{FenceOpening, parse_fence_opening};
use reference_model::{CalloutKind, RuleId, Violation};

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum LineElement {
    Fence { opening: FenceOpening, body: String },
    CalloutOpen(CalloutKind),
    CalloutClose,
    Heading { id: String, text: String },
    ListEntry { ordered: bool, text: String },
    TableRow(Vec<String>),
    Blank,
    Text(String),
}

pub fn classify(path: &str, body: &str) -> Result<Vec<LineElement>, Violation> {
    let mut elements = Vec::new();
    let mut lines = body.lines().enumerate();
    while let Some((number, line)) = lines.next() {
        let location = format!("{path}:{}", number.saturating_add(1));
        if let Some(opening) = parse_fence_opening(line) {
            let fence_body = collect_fence(&mut lines, &location)?;
            elements.push(LineElement::Fence {
                opening,
                body: fence_body,
            });
            continue;
        }
        if continues_list(&elements, line) {
            extend_last_entry(&mut elements, line.trim());
            continue;
        }
        elements.push(classify_line(&location, line)?);
    }
    Ok(elements)
}

fn collect_fence<'text>(
    lines: &mut impl Iterator<Item = (usize, &'text str)>,
    location: &str,
) -> Result<String, Violation> {
    let mut collected = Vec::new();
    for (_, line) in lines.by_ref() {
        if line.trim_end() == "```" {
            return Ok(collected.join("\n"));
        }
        collected.push(line);
    }
    Err(Violation::new(
        RuleId::Format,
        location,
        "a fenced block is not closed",
    ))
}

fn continues_list(elements: &[LineElement], line: &str) -> bool {
    line.starts_with("  ")
        && !line.trim().is_empty()
        && matches!(elements.last(), Some(LineElement::ListEntry { .. }))
}

fn extend_last_entry(elements: &mut [LineElement], addition: &str) {
    if let Some(LineElement::ListEntry { text, .. }) = elements.last_mut() {
        text.push(' ');
        text.push_str(addition);
    }
}

fn classify_line(location: &str, line: &str) -> Result<LineElement, Violation> {
    let trimmed = line.trim();
    if trimmed.is_empty() {
        return Ok(LineElement::Blank);
    }
    if trimmed == ":::" {
        return Ok(LineElement::CalloutClose);
    }
    if let Some(name) = trimmed.strip_prefix("::: ") {
        return CalloutKind::from_directive(name.trim())
            .map(LineElement::CalloutOpen)
            .ok_or_else(|| Violation::new(RuleId::Format, location, "unknown box kind"));
    }
    if let Some(heading) = trimmed.strip_prefix("## ") {
        return parse_heading(location, heading);
    }
    Ok(classify_content(trimmed))
}

fn classify_content(trimmed: &str) -> LineElement {
    if let Some(text) = trimmed.strip_prefix("- ") {
        return LineElement::ListEntry {
            ordered: false,
            text: text.to_owned(),
        };
    }
    if let Some(text) = ordered_entry(trimmed) {
        return LineElement::ListEntry {
            ordered: true,
            text: text.to_owned(),
        };
    }
    if trimmed.starts_with('|') {
        return LineElement::TableRow(crate::table_row::cells(trimmed));
    }
    LineElement::Text(trimmed.to_owned())
}

fn ordered_entry(trimmed: &str) -> Option<&str> {
    let (digits, rest) = trimmed.split_once(". ")?;
    (!digits.is_empty() && digits.chars().all(|character| character.is_ascii_digit()))
        .then_some(rest)
}

fn parse_heading(location: &str, heading: &str) -> Result<LineElement, Violation> {
    let failure = || Violation::new(RuleId::Format, location, "a heading needs an {#id}");
    let (text, identity) = heading.rsplit_once("{#").ok_or_else(failure)?;
    let identity = identity.strip_suffix('}').ok_or_else(failure)?;
    Ok(LineElement::Heading {
        id: identity.to_owned(),
        text: text.trim().to_owned(),
    })
}
