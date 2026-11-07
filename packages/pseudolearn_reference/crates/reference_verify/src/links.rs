use reference_model::{Block, PublishedSection, RuleId, Run, Violation};
use std::collections::BTreeSet;

pub fn check_links(sections: &[PublishedSection]) -> Vec<Violation> {
    let known: BTreeSet<&str> = sections.iter().map(|section| section.id.as_str()).collect();
    let mut violations = Vec::new();
    for section in sections {
        let mut targets = Vec::new();
        for block in &section.blocks {
            collect(block, &mut targets);
        }
        for target in targets {
            if !known.contains(target.as_str()) {
                violations.push(Violation::new(
                    RuleId::LinkValid,
                    section.id.clone(),
                    format!("link to unknown section `{target}`"),
                ));
            }
        }
    }
    violations
}

fn collect(block: &Block, targets: &mut Vec<String>) {
    let groups: Vec<&Vec<Run>> = match block {
        Block::Paragraph { runs } | Block::Heading { runs, .. } => vec![runs],
        Block::List { entries, .. } => entries.iter().collect(),
        Block::Summary { points } => points.iter().collect(),
        Block::Table(table) => table
            .rows
            .iter()
            .flatten()
            .chain(table.header.iter())
            .collect(),
        Block::Callout { blocks, .. } => {
            for inner in blocks {
                collect(inner, targets);
            }
            Vec::new()
        }
        _ => Vec::new(),
    };
    for run in groups.into_iter().flatten() {
        if let Run::Link { section, .. } = run {
            targets.push(section.clone());
        }
    }
}
