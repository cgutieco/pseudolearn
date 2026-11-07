use crate::parity::signature;
use reference_model::{ExerciseDocument, LessonDocument, RuleId, Violation};
use std::collections::BTreeMap;

pub fn check_route_parity(
    (spanish_lessons, english_lessons): (&[LessonDocument], &[LessonDocument]),
    (spanish_exercises, english_exercises): (&[ExerciseDocument], &[ExerciseDocument]),
) -> Vec<Violation> {
    let mut violations = pair_up(spanish_lessons, english_lessons, |spanish, english| {
        let (left, right) = (&spanish.header, &english.header);
        left.number == right.number
            && left.kind == right.kind
            && left.minutes == right.minutes
            && left.needs == right.needs
            && left.introduces == right.introduces
            && left.uses == right.uses
            && left.piece == right.piece
            && signature(&spanish.blocks) == signature(&english.blocks)
    });
    violations.extend(pair_up(
        spanish_exercises,
        english_exercises,
        |spanish, english| {
            let (left, right) = (&spanish.header, &english.header);
            left.lesson == right.lesson
                && left.kind == right.kind
                && left.level == right.level
                && left.required == right.required
                && signature(&spanish.blocks) == signature(&english.blocks)
        },
    ));
    violations
}

trait Identified {
    fn identity(&self) -> &str;
    fn location(&self) -> &str;
}

impl Identified for LessonDocument {
    fn identity(&self) -> &str {
        &self.header.id
    }
    fn location(&self) -> &str {
        &self.path
    }
}

impl Identified for ExerciseDocument {
    fn identity(&self) -> &str {
        &self.header.id
    }
    fn location(&self) -> &str {
        &self.path
    }
}

fn pair_up<Document: Identified>(
    spanish: &[Document],
    english: &[Document],
    same: fn(&Document, &Document) -> bool,
) -> Vec<Violation> {
    let english_by_id: BTreeMap<&str, &Document> = english
        .iter()
        .map(|document| (document.identity(), document))
        .collect();
    let mut violations = Vec::new();
    for document in spanish {
        match english_by_id.get(document.identity()) {
            None => violations.push(violation(document, "has no English counterpart")),
            Some(counterpart) if !same(document, counterpart) => violations.push(violation(
                *counterpart,
                "differs from the Spanish header or block structure",
            )),
            Some(_) => {}
        }
    }
    for document in english {
        if !spanish
            .iter()
            .any(|candidate| candidate.identity() == document.identity())
        {
            violations.push(violation(document, "has no Spanish counterpart"));
        }
    }
    violations
}

fn violation<Document: Identified>(document: &Document, detail: &str) -> Violation {
    Violation::new(RuleId::RouteParity, document.location(), detail)
}
