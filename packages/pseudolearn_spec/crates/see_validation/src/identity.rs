use see_model::{Corpus, field};
use std::collections::BTreeSet;

pub fn valid_id(id: &str) -> bool {
    let segments: Vec<_> = id.split('.').collect();
    segments.len() >= 2
        && segments.iter().all(|segment| {
            !segment.is_empty()
                && segment.starts_with(|letter: char| letter.is_ascii_uppercase())
                && segment.chars().all(|letter| {
                    letter.is_ascii_uppercase() || letter.is_ascii_digit() || letter == '-'
                })
        })
}

pub fn check(corpus: &Corpus) -> Vec<String> {
    let mut ids = BTreeSet::new();
    let mut errors = Vec::new();
    for specification in corpus {
        let id = &specification.metadata.id;
        if !valid_id(id) {
            errors.push(format!("SEE-IDENTITY: invalid identifier {id}"));
        }
        if !ids.insert(id) {
            errors.push(format!("SEE-DUPLICATE: duplicate identifier {id}"));
        }
        let mut elements = BTreeSet::new();
        for block in &specification.blocks {
            let element = field(block, "id");
            if !valid_element(element) {
                errors.push(format!("SEE-IDENTITY: invalid element {id}#{element}"));
            }
            if !elements.insert(element) {
                errors.push(format!("SEE-DUPLICATE: duplicate element {id}#{element}"));
            }
        }
    }
    errors
}

fn valid_element(element: &str) -> bool {
    let mut characters = element.chars();
    let prefix = characters.next();
    prefix.is_some_and(|prefix| "RCDEQIPS".contains(prefix))
        && !element.contains(' ')
        && element.len() > 1
        && characters.all(|character| character.is_ascii_digit())
        && element
            .get(1..)
            .is_some_and(|digits| digits.parse::<u64>().is_ok_and(|number| number > 0))
}
