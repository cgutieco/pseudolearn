use crate::template_model::{Segment, StopRole, Template};

pub const DEFAULT_INDENT_UNIT: &str = "  ";

#[derive(Clone, Copy, Debug)]
pub struct Layout<'layout> {
    pub base_indent: &'layout str,
    pub unit: &'layout str,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RenderedStop {
    pub index: u8,
    pub role: StopRole,
    pub start: usize,
    pub end: usize,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct RenderedTemplate {
    pub text: String,
    pub stops: Vec<RenderedStop>,
    pub final_offset: usize,
}

pub fn render(template: &Template, layout: Layout<'_>) -> RenderedTemplate {
    let mut text = String::new();
    let mut stops = Vec::new();
    let mut final_offset = None;
    for segment in &template.segments {
        match segment {
            Segment::Text(value) => text.push_str(value),
            Segment::NewLine => {
                text.push('\n');
                text.push_str(layout.base_indent);
            }
            Segment::Indent(depth) => text.push_str(&layout.unit.repeat(*depth)),
            Segment::Final => final_offset = Some(text.len()),
            Segment::Stop(spec) => {
                let start = text.len();
                text.push_str(&spec.marker);
                stops.push(RenderedStop {
                    index: spec.index,
                    role: spec.role,
                    start,
                    end: text.len(),
                });
            }
        }
    }
    stops.sort_by_key(|stop| stop.index);
    let final_offset = final_offset.unwrap_or(text.len());
    RenderedTemplate {
        text,
        stops,
        final_offset,
    }
}

pub fn render_snippet(template: &Template, unit: &str) -> String {
    let mut snippet = String::new();
    let mut has_final = false;
    for segment in &template.segments {
        match segment {
            Segment::Text(value) => snippet.push_str(&escape_snippet(value)),
            Segment::NewLine => snippet.push('\n'),
            Segment::Indent(depth) => snippet.push_str(&unit.repeat(*depth)),
            Segment::Final => {
                has_final = true;
                snippet.push_str("$0");
            }
            Segment::Stop(spec) => snippet.push_str(&format!(
                "${{{}:{}}}",
                spec.index,
                escape_snippet(&spec.marker)
            )),
        }
    }
    if !has_final {
        snippet.push_str("$0");
    }
    snippet
}

fn escape_snippet(value: &str) -> String {
    let mut escaped = String::with_capacity(value.len());
    for glyph in value.chars() {
        if matches!(glyph, '$' | '}' | '\\') {
            escaped.push('\\');
        }
        escaped.push(glyph);
    }
    escaped
}

pub fn plain_layout() -> Layout<'static> {
    Layout {
        base_indent: "",
        unit: DEFAULT_INDENT_UNIT,
    }
}
