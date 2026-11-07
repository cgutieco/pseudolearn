use reference_model::{RuleId, SourceBlock, SourceDocument, Violation};
use std::collections::BTreeMap;

pub fn check_parity(spanish: &[SourceDocument], english: &[SourceDocument]) -> Vec<Violation> {
    let english_by_id: BTreeMap<&str, &SourceDocument> = english
        .iter()
        .map(|document| (document.header.id.as_str(), document))
        .collect();
    let mut violations: Vec<Violation> = spanish
        .iter()
        .flat_map(|document| {
            pair_problems(document, english_by_id.get(document.header.id.as_str()))
        })
        .collect();
    let spanish_ids: Vec<&str> = spanish
        .iter()
        .map(|document| document.header.id.as_str())
        .collect();
    violations.extend(
        english
            .iter()
            .filter(|document| !spanish_ids.contains(&document.header.id.as_str()))
            .map(|document| violation(document, "the section has no Spanish counterpart")),
    );
    violations
}

fn pair_problems(
    document: &SourceDocument,
    counterpart: Option<&&SourceDocument>,
) -> Vec<Violation> {
    let Some(counterpart) = counterpart else {
        return vec![violation(
            document,
            "the section has no English counterpart",
        )];
    };
    let mut problems = Vec::new();
    if !same_header(document, counterpart) {
        problems.push(violation(
            counterpart,
            "number, kind, anchors, cards or diagnostics differ",
        ));
    }
    if signature(&document.blocks) != signature(&counterpart.blocks) {
        problems.push(violation(
            counterpart,
            "the block structure differs from the Spanish section",
        ));
    }
    problems
}

fn violation(document: &SourceDocument, detail: &str) -> Violation {
    Violation::new(RuleId::Parity, document.path.clone(), detail)
}

fn same_header(first: &SourceDocument, second: &SourceDocument) -> bool {
    let (left, right) = (&first.header, &second.header);
    left.number == right.number
        && left.kind == right.kind
        && left.anchors == right.anchors
        && left.cards == right.cards
        && left.diagnostics == right.diagnostics
}

pub fn signature(blocks: &[SourceBlock]) -> Vec<String> {
    blocks.iter().filter_map(block_signature).collect()
}

fn block_signature(block: &SourceBlock) -> Option<String> {
    let text = match block {
        SourceBlock::Heading { id, .. } => format!("heading:{id}"),
        SourceBlock::Program(program) => format!("program:{}", program.id),
        SourceBlock::Figure(figure) => format!("figure:{}:{}", figure.id, figure.steps.len()),
        SourceBlock::Form(_) => "form".to_owned(),
        SourceBlock::Rails(request) => format!("rails:{}", request.production),
        SourceBlock::Intermediate { program } => format!("intermediate:{program}"),
        SourceBlock::Trace { program } => format!("trace:{program}"),
        SourceBlock::Generated { catalog } => format!("generated:{catalog}"),
        SourceBlock::Route(fence) => format!("data:{}", fence.name()),
        SourceBlock::Callout { kind, blocks, .. } => {
            format!("{}[{}]", kind.directive(), signature(blocks).join(","))
        }
        _ => return None,
    };
    Some(text)
}
