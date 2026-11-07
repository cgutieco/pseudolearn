use crate::source_walk::all_blocks;
use reference_model::{CalloutKind, RuleId, SectionKind, SourceBlock, SourceDocument, Violation};

struct Requirement {
    required: fn(SectionKind) -> bool,
    present: fn(&[&SourceBlock], SectionKind) -> bool,
    missing: &'static str,
}

const REQUIREMENTS: [Requirement; 11] = [
    Requirement {
        required: always,
        present: |blocks, _| callout(blocks, CalloutKind::Phrase),
        missing: "the one-sentence box",
    },
    Requirement {
        required: always,
        present: |blocks, _| {
            blocks
                .iter()
                .any(|block| matches!(block, SourceBlock::Figure(_)))
        },
        missing: "a main figure",
    },
    Requirement {
        required: always,
        present: |blocks, _| callout(blocks, CalloutKind::Summary),
        missing: "the summary",
    },
    Requirement {
        required: always,
        present: |blocks, _| callout(blocks, CalloutKind::SeeAlso),
        missing: "the see-also list",
    },
    Requirement {
        required: SectionKind::requires_form,
        present: |blocks, _| {
            blocks
                .iter()
                .any(|block| matches!(block, SourceBlock::Form(_)))
        },
        missing: "the written form",
    },
    Requirement {
        required: SectionKind::requires_parts,
        present: |blocks, _| callout(blocks, CalloutKind::Parts),
        missing: "the parts box",
    },
    Requirement {
        required: SectionKind::requires_how_it_works,
        present: |blocks, _| blocks.iter().any(|block| is_how_it_works(block)),
        missing: "the how-it-works heading",
    },
    Requirement {
        required: SectionKind::requires_errors,
        present: |blocks, _| callout(blocks, CalloutKind::Errors),
        missing: "the common errors box",
    },
    Requirement {
        required: SectionKind::requires_inside,
        present: |blocks, _| callout(blocks, CalloutKind::Inside),
        missing: "the inside box",
    },
    Requirement {
        required: SectionKind::requires_limit,
        present: |blocks, _| callout(blocks, CalloutKind::Limit),
        missing: "the exact limit box",
    },
    Requirement {
        required: always,
        present: enough_programs,
        missing: "enough executed programs",
    },
];

pub fn check_anatomy(document: &SourceDocument) -> Vec<Violation> {
    let kind = document.header.kind;
    if kind == SectionKind::Appendix {
        return Vec::new();
    }
    let blocks = all_blocks(&document.blocks);
    REQUIREMENTS
        .iter()
        .filter(|requirement| (requirement.required)(kind) && !(requirement.present)(&blocks, kind))
        .map(|requirement| {
            Violation::new(
                RuleId::Anatomy,
                document.path.clone(),
                format!("missing {}", requirement.missing),
            )
        })
        .collect()
}

fn always(_: SectionKind) -> bool {
    true
}

fn callout(blocks: &[&SourceBlock], wanted: CalloutKind) -> bool {
    blocks
        .iter()
        .any(|block| matches!(block, SourceBlock::Callout { kind, .. } if *kind == wanted))
}

fn enough_programs(blocks: &[&SourceBlock], kind: SectionKind) -> bool {
    let executed = blocks
        .iter()
        .filter(|block| matches!(block, SourceBlock::Program(program) if program.execute))
        .count();
    executed >= kind.minimum_programs()
}

fn is_how_it_works(block: &SourceBlock) -> bool {
    matches!(block, SourceBlock::Heading { id, .. } if id == "funciona")
}
