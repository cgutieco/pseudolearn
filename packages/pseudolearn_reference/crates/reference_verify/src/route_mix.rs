use crate::route_book::RouteBook;
use crate::route_text::{contains_form, prose, text_groups};
use reference_corpus::{Corpus, LexemeFamily};
use reference_model::{
    CalloutKind, ExerciseDocument, Inline, LessonKind, RouteFence, RuleId, SourceBlock, Violation,
};
use std::collections::BTreeSet;

pub fn check_exercise_mix(book: &RouteBook<'_>) -> Vec<Violation> {
    let mut violations = Vec::new();
    for lesson in book.lessons {
        let listed = practice_list(&lesson.blocks);
        let mut report = |detail: String| {
            violations.push(Violation::new(
                RuleId::RouteExerciseMix,
                lesson.path.clone(),
                detail,
            ));
        };
        let owned: Vec<&ExerciseDocument> = book.exercises_of(&lesson.header.id).collect();
        for exercise in &owned {
            if !listed.contains(&exercise.header.id) {
                report(format!(
                    "`{}` is not listed in practice",
                    exercise.header.id
                ));
            }
        }
        for identity in &listed {
            if !owned.iter().any(|exercise| &exercise.header.id == identity) {
                report(format!(
                    "practice lists `{identity}`, which is not one of its exercises"
                ));
            }
        }
        if lesson.header.kind != LessonKind::Project {
            mix_problems(&owned).into_iter().for_each(&mut report);
        }
    }
    violations
}

fn mix_problems(exercises: &[&ExerciseDocument]) -> Vec<String> {
    let kinds: BTreeSet<_> = exercises
        .iter()
        .map(|exercise| exercise.header.kind)
        .collect();
    let levels: BTreeSet<_> = exercises
        .iter()
        .map(|exercise| exercise.header.level)
        .collect();
    let required = exercises
        .iter()
        .filter(|exercise| exercise.header.required)
        .count();
    let mut problems = Vec::new();
    if exercises.len() < 5 {
        problems.push(format!(
            "has {} exercises instead of at least 5",
            exercises.len()
        ));
    }
    if kinds.len() < 3 {
        problems.push(format!(
            "has {} exercise kinds instead of at least 3",
            kinds.len()
        ));
    }
    if levels.len() < 2 {
        problems.push(format!("has {} levels instead of at least 2", levels.len()));
    }
    if required < 3 {
        problems.push(format!(
            "has {required} required exercises instead of at least 3"
        ));
    }
    problems
}

fn practice_list(blocks: &[SourceBlock]) -> Vec<String> {
    blocks
        .iter()
        .filter_map(|block| match block {
            SourceBlock::Callout {
                kind: CalloutKind::Practice,
                blocks,
                ..
            } => Some(blocks),
            _ => None,
        })
        .flatten()
        .flat_map(|block| match block {
            SourceBlock::List { entries, .. } => entries
                .iter()
                .map(|entry| prose(entry).trim().to_owned())
                .collect(),
            _ => Vec::new(),
        })
        .collect()
}

pub fn check_hints(exercise: &ExerciseDocument) -> Vec<Violation> {
    if !exercise.header.kind.needs_hint_ladder() {
        return Vec::new();
    }
    let hints = hint_count(&exercise.blocks);
    let has_variant = exercise.blocks.iter().any(|block| {
        matches!(
            block,
            SourceBlock::Callout {
                kind: CalloutKind::Variant,
                ..
            }
        )
    });
    let mut problems = Vec::new();
    if hints != Some(4) {
        problems.push(format!("has {} hints instead of four", hints.unwrap_or(0)));
    }
    if !has_variant {
        problems.push("has no `variante`".to_owned());
    }
    problems
        .into_iter()
        .map(|detail| Violation::new(RuleId::RouteHints, exercise.path.clone(), detail))
        .collect()
}

fn hint_count(blocks: &[SourceBlock]) -> Option<usize> {
    blocks.iter().find_map(|block| match block {
        SourceBlock::Callout {
            kind: CalloutKind::Hints,
            blocks,
            ..
        } => Some(
            blocks
                .iter()
                .map(|inner| match inner {
                    SourceBlock::List { entries, .. } => entries.len(),
                    _ => 0,
                })
                .sum::<usize>(),
        ),
        _ => None,
    })
}

pub fn check_no_recipe(
    book: &RouteBook<'_>,
    corpus: &Corpus,
    (path, blocks): (&str, &[SourceBlock]),
    names_code: bool,
) -> Vec<Violation> {
    let reserved = reserved_words(corpus);
    let mut problems = Vec::new();
    for group in text_groups(blocks)
        .iter()
        .filter(|group| group.in_problem())
    {
        for code in codes(group.inlines).into_iter().filter(|_| names_code) {
            if code
                .split(|character: char| !character.is_alphanumeric())
                .any(|word| reserved.contains(&word.to_lowercase()))
            {
                problems.push(format!("names the construction `{code}`"));
            }
        }
        let text = prose(group.inlines);
        for (term, definition) in book
            .terms
            .iter()
            .filter(|(_, definition)| definition.recipe)
        {
            if definition
                .forms
                .iter()
                .any(|form| contains_form(&text, form))
            {
                problems.push(format!("names the recipe term `{term}`"));
            }
        }
    }
    problems
        .into_iter()
        .map(|detail| Violation::new(RuleId::RouteStatementNoRecipe, path, detail))
        .collect()
}

fn reserved_words(corpus: &Corpus) -> BTreeSet<String> {
    corpus
        .lexicon
        .entries()
        .filter(|entry| {
            matches!(
                entry.family,
                LexemeFamily::Reserved | LexemeFamily::Contextual
            )
        })
        .flat_map(|entry| [entry.spanish.to_lowercase(), entry.english.to_lowercase()])
        .collect()
}

fn codes(inlines: &[Inline]) -> Vec<&str> {
    inlines
        .iter()
        .filter_map(|inline| match inline {
            Inline::Code(code) => Some(code.as_str()),
            _ => None,
        })
        .collect()
}

pub fn fence<'document>(
    document: &'document [SourceBlock],
    name: &str,
) -> Option<&'document RouteFence> {
    document.iter().find_map(|block| match block {
        SourceBlock::Route(fence) if fence.name() == name => Some(fence),
        _ => None,
    })
}
