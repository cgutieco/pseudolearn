#![forbid(unsafe_code)]

mod assembly;
mod fence;
mod fence_blocks;
mod figure_body;
mod front_matter;
mod inline_parser;
mod line_kind;
mod route_fences;
mod summary_tags;
mod table_row;

pub use fence::{FenceOpening, parse_fence_opening};
pub use inline_parser::parse_inline;
pub use summary_tags::summary_tags;

use reference_model::{
    ExerciseDocument, LessonDocument, RouteDocument, RuleId, SourceBlock, SourceDocument, Violation,
};
use serde::de::DeserializeOwned;

pub fn parse_document(path: &str, text: &str) -> Result<SourceDocument, Violation> {
    let parsed: RouteDocument<reference_model::SectionHeader> = parse_with(
        path,
        text,
        RuleId::Format,
        |header: &reference_model::SectionHeader| &header.title,
    )?;
    Ok(SourceDocument {
        path: parsed.path,
        header: parsed.header,
        title: parsed.title,
        blocks: parsed.blocks,
    })
}

pub fn parse_lesson(path: &str, text: &str) -> Result<LessonDocument, Violation> {
    parse_with(
        path,
        text,
        RuleId::RouteFormat,
        |header: &reference_model::LessonHeader| &header.title,
    )
}

pub fn parse_exercise(path: &str, text: &str) -> Result<ExerciseDocument, Violation> {
    parse_with(
        path,
        text,
        RuleId::RouteFormat,
        |header: &reference_model::ExerciseHeader| &header.title,
    )
}

fn parse_with<Header: DeserializeOwned>(
    path: &str,
    text: &str,
    rule: RuleId,
    title_of: fn(&Header) -> &String,
) -> Result<RouteDocument<Header>, Violation> {
    let (header, body) = front_matter::split::<Header>(path, text, rule)?;
    let lines = line_kind::classify(path, body).map_err(|violation| retag(violation, rule))?;
    let blocks: Vec<SourceBlock> =
        assembly::assemble(path, lines).map_err(|violation| retag(violation, rule))?;
    let title =
        parse_inline(title_of(&header)).map_err(|detail| Violation::new(rule, path, detail))?;
    Ok(RouteDocument {
        path: path.to_owned(),
        header,
        title,
        blocks,
    })
}

fn retag(violation: Violation, rule: RuleId) -> Violation {
    Violation::new(rule, violation.location, violation.detail)
}
