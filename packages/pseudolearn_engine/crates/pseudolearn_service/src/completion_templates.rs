use crate::template_catalog::build_template;
use crate::template_model::{Segment, StopRole};
use crate::template_render::{DEFAULT_INDENT_UNIT, plain_layout, render, render_snippet};
use pseudolearn_lexicon::{KeywordKind, Profile};

pub fn template_constructions() -> &'static [&'static str] {
    &[
        "algorithm",
        "subroutine",
        "function",
        "class",
        "if",
        "while",
        "for",
        "repeat",
        "switch",
    ]
}

pub fn get_template(construction: &str, profile: Profile) -> Option<String> {
    let template = build_template(construction, profile)?;
    Some(render(&template, plain_layout()).text)
}

pub fn is_unit_construction(construction: &str) -> bool {
    matches!(
        construction,
        "algorithm" | "subroutine" | "function" | "class"
    )
}

pub fn construction_for(kind: KeywordKind) -> Option<&'static str> {
    match kind {
        KeywordKind::Algorithm => Some("algorithm"),
        KeywordKind::Subroutine => Some("subroutine"),
        KeywordKind::ClassKeyword => Some("class"),
        KeywordKind::IfKeyword => Some("if"),
        KeywordKind::WhileKeyword => Some("while"),
        KeywordKind::ForKeyword => Some("for"),
        KeywordKind::Repeat => Some("repeat"),
        KeywordKind::SwitchKeyword => Some("switch"),
        _ => None,
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct StopOutline {
    pub index: u8,
    pub role: StopRole,
    pub marker: String,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TemplateOutline {
    pub stops: Vec<StopOutline>,
    pub snippet: String,
}

pub fn template_outline(construction: &str, profile: Profile) -> Option<TemplateOutline> {
    let template = build_template(construction, profile)?;
    let mut stops: Vec<StopOutline> = template
        .segments
        .iter()
        .filter_map(|segment| match segment {
            Segment::Stop(spec) => Some(StopOutline {
                index: spec.index,
                role: spec.role,
                marker: spec.marker.clone(),
            }),
            _ => None,
        })
        .collect();
    stops.sort_by_key(|stop| stop.index);
    Some(TemplateOutline {
        stops,
        snippet: render_snippet(&template, DEFAULT_INDENT_UNIT),
    })
}
