use crate::program_skeleton::{keyword_set, skeleton};
use reference_corpus::Corpus;
use reference_model::{ProgramSource, RuleId, SourceBlock, Violation};

pub fn check_program_parity(
    corpus: &Corpus,
    location: &str,
    (spanish, english): (&[SourceBlock], &[SourceBlock]),
) -> Vec<Violation> {
    let keywords = keyword_set(&corpus.lexicon);
    let spanish_programs = programs(spanish);
    let mut violations = Vec::new();
    for (position, written) in programs(english).into_iter().enumerate() {
        if written.code.trim().is_empty() {
            continue;
        }
        let counterpart = spanish_programs
            .get(position)
            .filter(|candidate| same_program(candidate, written));
        let detail = match counterpart {
            None => Some("the program has no Spanish counterpart in the same position".to_owned()),
            Some(original) if skeleton(&original.code, &keywords) != skeleton(&written.code, &keywords) => Some(
                "the English program differs structurally from the Spanish one: only identifiers and texts between quotes may change".to_owned(),
            ),
            Some(_) => None,
        };
        violations.extend(detail.map(|detail| {
            Violation::new(
                RuleId::RouteParity,
                location,
                format!("program `{}`: {detail}", written.id),
            )
        }));
    }
    violations
}

fn same_program(spanish: &ProgramSource, english: &ProgramSource) -> bool {
    spanish.id == english.id && spanish.role == english.role
}

fn programs(blocks: &[SourceBlock]) -> Vec<&ProgramSource> {
    blocks
        .iter()
        .filter_map(|block| match block {
            SourceBlock::Program(program) => Some(program),
            _ => None,
        })
        .collect()
}
