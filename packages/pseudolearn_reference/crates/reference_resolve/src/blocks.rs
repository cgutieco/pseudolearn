use crate::Resolution;
use crate::programs::{program_block, target_code};
use crate::resolution::Collector;
use crate::runs::runs;
use reference_model::{Block, ExecutionRequest, Profile, RuleId, SourceBlock, TableBlock};

pub fn resolve_blocks(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    blocks: &[SourceBlock],
    top_level: bool,
) -> Vec<Block> {
    blocks
        .iter()
        .flat_map(|block| resolve_block(resolution, collector, block, top_level))
        .collect()
}

fn resolve_block(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    block: &SourceBlock,
    top_level: bool,
) -> Vec<Block> {
    let resolved = match block {
        SourceBlock::Heading { id, text, .. } => Some(Block::Heading {
            id: id.clone(),
            number: if top_level {
                collector.next_heading()
            } else {
                String::new()
            },
            runs: runs(resolution, text),
        }),
        SourceBlock::Form(text) => form(resolution, collector, text),
        SourceBlock::Program(source) => {
            program_block(resolution, collector, source).map(Block::Program)
        }
        SourceBlock::Generated { catalog } => {
            return crate::generated::catalog_blocks(resolution, collector, catalog);
        }
        SourceBlock::Paragraph(_) | SourceBlock::List { .. } | SourceBlock::Table { .. } => {
            Some(prose(resolution, block))
        }
        other => companion(resolution, collector, other),
    };
    resolved.into_iter().collect()
}

fn prose(resolution: &Resolution<'_>, block: &SourceBlock) -> Block {
    match block {
        SourceBlock::List { ordered, entries } => Block::List {
            ordered: *ordered,
            entries: entries
                .iter()
                .map(|entry| runs(resolution, entry))
                .collect(),
        },
        SourceBlock::Table { header, rows } => Block::Table(TableBlock {
            header: header.iter().map(|cell| runs(resolution, cell)).collect(),
            rows: rows
                .iter()
                .map(|row| row.iter().map(|cell| runs(resolution, cell)).collect())
                .collect(),
        }),
        SourceBlock::Paragraph(text) => Block::Paragraph {
            runs: runs(resolution, text),
        },
        _ => Block::Paragraph { runs: Vec::new() },
    }
}

fn companion(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    block: &SourceBlock,
) -> Option<Block> {
    match block {
        SourceBlock::Rails(request) => crate::rails::rails_block(resolution, collector, request),
        SourceBlock::Figure(source) => crate::figures::figure_block(resolution, collector, source),
        SourceBlock::Callout { kind, blocks, .. } => {
            crate::callouts::callout(resolution, collector, *kind, blocks)
        }
        SourceBlock::Intermediate { program } => intermediate(resolution, collector, program),
        SourceBlock::Trace { program } => trace(resolution, collector, program),
        _ => None,
    }
}

fn form(resolution: &Resolution<'_>, collector: &mut Collector<'_>, text: &str) -> Option<Block> {
    let position = collector.forms;
    collector.forms = collector.forms.saturating_add(1);
    let (effective, written_in) = if text.trim().is_empty() {
        let Some(reused) = collector.reuse.forms.get(position) else {
            collector.report(RuleId::Format, "an empty form has no Spanish form to reuse");
            return None;
        };
        (reused.clone(), Profile::Spanish)
    } else {
        (text.to_owned(), resolution.language)
    };
    Some(Block::Form {
        lines: crate::forms::form_lines(resolution, &effective, written_in),
    })
}

fn program_code(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    program: &str,
) -> Option<String> {
    let Some(spanish) = collector.programs.get(program).cloned() else {
        collector.report(RuleId::Format, format!("unknown program `{program}`"));
        return None;
    };
    Some(target_code(resolution, &spanish))
}

fn intermediate(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    program: &str,
) -> Option<Block> {
    let code = program_code(resolution, collector, program)?;
    match resolution.engine.intermediate(&code, resolution.profile) {
        Ok(text) => Some(Block::Intermediate {
            program: program.to_owned(),
            lines: text.lines().map(str::to_owned).collect(),
        }),
        Err(error) => {
            collector.report(
                RuleId::ExampleVerified,
                format!("`{program}` does not lower: {error}"),
            );
            None
        }
    }
}

fn trace(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    program: &str,
) -> Option<Block> {
    let code = program_code(resolution, collector, program)?;
    let report = resolution.engine.execute(&ExecutionRequest {
        code,
        profile: resolution.profile,
        inputs: Vec::new(),
        host: None,
        trace: true,
        statement_limit: None,
        depth_limit: None,
    });
    Some(Block::Trace {
        program: program.to_owned(),
        events: crate::trace::trace_lines(resolution.pack, &report.trace),
    })
}
