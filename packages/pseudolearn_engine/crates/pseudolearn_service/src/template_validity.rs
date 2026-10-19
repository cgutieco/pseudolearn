use crate::completion_templates::{get_template, is_unit_construction};
use crate::spelling::keyword_spelling;
use pseudolearn_lexicon::{KeywordKind, Profile};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

pub fn template_program(construction: &str, profile: Profile) -> Option<String> {
    let template = get_template(construction, profile)?;
    let open = keyword_spelling(KeywordKind::Algorithm, profile);
    let close = keyword_spelling(KeywordKind::EndAlgorithm, profile);
    let program = match construction {
        "algorithm" => template,
        _ if is_unit_construction(construction) => {
            format!("{template}\n{open} Main\n{close}\n")
        }
        _ => format!("{open} Main\n{template}\n{close}\n"),
    };
    Some(program)
}

pub fn template_parses_cleanly(construction: &str, profile: Profile) -> bool {
    let Some(program) = template_program(construction, profile) else {
        return false;
    };
    let (_, diagnostics) = parse_source(&SourceText::new(program), profile);
    diagnostics.is_empty()
}
