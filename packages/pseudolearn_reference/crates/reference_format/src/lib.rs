#![forbid(unsafe_code)]

mod assembly;
mod fence;
mod fence_blocks;
mod figure_body;
mod front_matter;
mod inline_parser;
mod line_kind;
mod table_row;

pub use fence::{FenceOpening, parse_fence_opening};
pub use inline_parser::parse_inline;

use reference_model::{RuleId, SourceDocument, Violation};

pub fn parse_document(path: &str, text: &str) -> Result<SourceDocument, Violation> {
    let (header, body) = front_matter::split(path, text)?;
    let lines = line_kind::classify(path, body)?;
    let blocks = assembly::assemble(path, lines)?;
    let title = parse_inline(&header.title)
        .map_err(|detail| Violation::new(RuleId::Format, path, detail))?;
    Ok(SourceDocument {
        path: path.to_owned(),
        title,
        header,
        blocks,
    })
}
