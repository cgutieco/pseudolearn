use crate::source_walk::all_blocks;
use reference_model::{CalloutKind, LessonDocument, LessonKind, RuleId, SourceBlock, Violation};

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
enum Marker {
    Phrase,
    Problem,
    Attempt,
    Paradigm,
    Phase,
    Summary,
    Practice,
    Next,
}

fn marker(block: &SourceBlock) -> Option<Marker> {
    let marker = match block {
        SourceBlock::Heading { phase: Some(_), .. } => Marker::Phase,
        SourceBlock::Callout { kind, .. } => match kind {
            CalloutKind::Phrase => Marker::Phrase,
            CalloutKind::Problem => Marker::Problem,
            CalloutKind::Attempt => Marker::Attempt,
            CalloutKind::Paradigm => Marker::Paradigm,
            CalloutKind::Summary => Marker::Summary,
            CalloutKind::Practice => Marker::Practice,
            CalloutKind::Next => Marker::Next,
            _ => return None,
        },
        _ => return None,
    };
    Some(marker)
}

pub fn check_route_anatomy(lesson: &LessonDocument, last: bool) -> Vec<Violation> {
    let markers: Vec<Marker> = lesson.blocks.iter().filter_map(marker).collect();
    let mut problems = Vec::new();
    let mut required = vec![
        Marker::Phrase,
        Marker::Problem,
        Marker::Attempt,
        Marker::Phase,
        Marker::Summary,
        Marker::Practice,
    ];
    if !last {
        required.push(Marker::Next);
    }
    if lesson.header.kind == LessonKind::Opening {
        required.push(Marker::Paradigm);
    }
    for wanted in required {
        if !markers.contains(&wanted) {
            problems.push(format!("the lesson has no {wanted:?} block"));
        }
    }
    if lesson.header.kind != LessonKind::Opening && markers.contains(&Marker::Paradigm) {
        problems.push("only an opening lesson has a paradigm block".to_owned());
    }
    if markers.windows(2).any(|pair| pair.first() > pair.get(1)) {
        problems.push("the blocks are not in the anatomy order".to_owned());
    }
    problems
        .into_iter()
        .map(|detail| Violation::new(RuleId::RouteAnatomy, lesson.path.clone(), detail))
        .collect()
}

pub fn check_scaffold(lesson: &LessonDocument) -> Vec<Violation> {
    let phases: Vec<&str> = lesson
        .blocks
        .iter()
        .filter_map(|block| match block {
            SourceBlock::Heading {
                phase: Some(phase), ..
            } => Some(phase.as_str()),
            _ => None,
        })
        .collect();
    let condensed = condensed_part(&lesson.header.id) && lesson.header.kind != LessonKind::Project;
    let expected: &[&str] = if condensed {
        &["1-2", "3", "4", "5"]
    } else {
        &["1", "2", "3", "4", "5"]
    };
    if phases == expected {
        return Vec::new();
    }
    vec![Violation::new(
        RuleId::RouteScaffold,
        lesson.path.clone(),
        format!("phases {phases:?} differ from {expected:?} for this part"),
    )]
}

pub fn check_new_tool(lesson: &LessonDocument) -> Vec<Violation> {
    let header = &lesson.header;
    let introduces_construct = header.kind == LessonKind::Lesson
        && !header.introduces.is_empty()
        && !header.needs.is_empty();
    let has_section = lesson
        .blocks
        .iter()
        .any(|block| matches!(block, SourceBlock::Heading { id, .. } if id == NEW_TOOL_ANCHOR));
    if !introduces_construct || has_section {
        return Vec::new();
    }
    vec![Violation::new(
        RuleId::RouteNewTool,
        lesson.path.clone(),
        format!(
            "a lesson that introduces concepts needs a section with the anchor {NEW_TOOL_ANCHOR}"
        ),
    )]
}

const NEW_TOOL_ANCHOR: &str = "herramienta";

fn condensed_part(lesson: &str) -> bool {
    !matches!(lesson.split('.').next(), Some("inicio" | "imperativo"))
}

pub fn check_no_spec_duplicate(lesson: &LessonDocument) -> Vec<Violation> {
    let mut problems = Vec::new();
    for block in all_blocks(&lesson.blocks) {
        match block {
            SourceBlock::Form(_)
            | SourceBlock::Anatomy(_)
            | SourceBlock::Intermediate { .. }
            | SourceBlock::Trace { .. } => {
                problems.push("a lesson does not draw syntax or engine views")
            }
            SourceBlock::Callout {
                kind: CalloutKind::Parts | CalloutKind::Limit | CalloutKind::Errors,
                ..
            } => problems.push("parts, limits and error catalogs belong to the specification"),
            SourceBlock::Callout {
                kind: CalloutKind::Inside,
                blocks,
                ..
            } if !blocks.iter().all(inside_allowed) => {
                problems.push("«Bajo el capó» only holds short paragraphs and specification links")
            }
            _ => {}
        }
    }
    problems
        .into_iter()
        .map(|detail| Violation::new(RuleId::RouteNoSpecDuplicate, lesson.path.clone(), detail))
        .collect()
}

fn inside_allowed(block: &SourceBlock) -> bool {
    matches!(
        block,
        SourceBlock::Paragraph(_)
            | SourceBlock::Callout {
                kind: CalloutKind::SpecLinks,
                ..
            }
    )
}

pub fn check_route_format(path: &str, blocks: &[SourceBlock]) -> Vec<Violation> {
    let mut problems = Vec::new();
    let mut previous: Option<&SourceBlock> = None;
    for block in blocks {
        if is_callout(block, CalloutKind::Answer)
            && !previous.is_some_and(|before| is_callout(before, CalloutKind::Attempt))
        {
            problems.push(Violation::new(
                RuleId::RouteFormat,
                path,
                "`respuesta` must come right after `intento`",
            ));
        }
        if let SourceBlock::Callout { blocks: inner, .. } = block {
            problems.extend(check_route_format(path, inner));
        }
        previous = Some(block);
    }
    problems
}

fn is_callout(block: &SourceBlock, wanted: CalloutKind) -> bool {
    matches!(block, SourceBlock::Callout { kind, .. } if *kind == wanted)
}
