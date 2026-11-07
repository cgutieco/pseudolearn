use crate::route_book::RouteBook;
use crate::route_text::{contains_form, marked_terms, prose, recalled_terms, text_groups};
use reference_format::summary_tags;
use reference_model::{CalloutKind, Inline, LessonDocument, RuleId, SourceBlock, Violation};
use std::collections::BTreeSet;

pub fn check_term_owners(book: &RouteBook<'_>) -> Vec<Violation> {
    let mut violations = Vec::new();
    for term in book.terms.keys() {
        let owners: Vec<&LessonDocument> = book
            .lessons
            .iter()
            .filter(|lesson| lesson.header.introduces.contains(term))
            .collect();
        if owners.len() != 1 {
            violations.push(Violation::new(
                RuleId::RouteTermOwner,
                format!("terminos.json#{term}"),
                format!("has {} owner lessons instead of one", owners.len()),
            ));
        }
    }
    for lesson in book.lessons {
        violations.extend(lesson_definitions(book, lesson));
    }
    violations
}

fn lesson_definitions(book: &RouteBook<'_>, lesson: &LessonDocument) -> Vec<Violation> {
    let mut violations = Vec::new();
    let defined: Vec<&str> = text_groups(&lesson.blocks)
        .iter()
        .flat_map(|group| marked_terms(group.inlines))
        .filter(|(_, definition)| *definition)
        .map(|(term, _)| term)
        .collect();
    for term in &lesson.header.introduces {
        let count = defined.iter().filter(|found| **found == term).count();
        let problem = if !book.terms.contains_key(term) {
            Some("is not in terminos.json".to_owned())
        } else if count != 1 {
            Some(format!("has {count} definitions instead of one"))
        } else {
            None
        };
        if let Some(problem) = problem {
            violations.push(Violation::new(
                RuleId::RouteTermOwner,
                lesson.path.clone(),
                format!("the introduced term `{term}` {problem}"),
            ));
        }
    }
    for term in defined {
        if !lesson.header.introduces.iter().any(|owned| owned == term) {
            violations.push(Violation::new(
                RuleId::RouteTermOwner,
                lesson.path.clone(),
                format!("defines `{term}` without introducing it"),
            ));
        }
    }
    violations
}

pub fn check_term_order(book: &RouteBook<'_>) -> Vec<Violation> {
    let mut violations = Vec::new();
    for (position, lesson) in book.lessons.iter().enumerate() {
        let late = |term: &str| book.owner(term).is_some_and(|owner| owner > position);
        let mut found: Vec<(String, &str, &str)> = Vec::new();
        for term in &lesson.header.uses {
            found.push((term.clone(), "usa", &lesson.path));
        }
        for term in recalled_terms(&lesson.blocks) {
            found.push((term, "recuerda", &lesson.path));
        }
        for (path, title, blocks) in documents_of(book, lesson) {
            for (term, how) in found_terms(book, lesson, title, blocks) {
                found.push((term, how, path));
            }
        }
        violations.extend(found.into_iter().filter(|(term, _, _)| late(term)).map(
            |(term, how, path)| {
                Violation::new(
                    RuleId::RouteTermOrder,
                    path,
                    format!("uses `{term}` ({how}) before its owner lesson"),
                )
            },
        ));
    }
    violations
}

fn documents_of<'book>(
    book: &'book RouteBook<'_>,
    lesson: &'book LessonDocument,
) -> Vec<(&'book str, &'book [Inline], &'book [SourceBlock])> {
    let mut documents = vec![(
        lesson.path.as_str(),
        lesson.title.as_slice(),
        lesson.blocks.as_slice(),
    )];
    documents.extend(book.exercises_of(&lesson.header.id).map(|exercise| {
        (
            exercise.path.as_str(),
            exercise.title.as_slice(),
            exercise.blocks.as_slice(),
        )
    }));
    documents
}

fn found_terms(
    book: &RouteBook<'_>,
    lesson: &LessonDocument,
    title: &[Inline],
    blocks: &[SourceBlock],
) -> BTreeSet<(String, &'static str)> {
    let mut found = BTreeSet::new();
    let mut groups = text_groups(blocks);
    groups.push(crate::route_text::TextGroup {
        zone: None,
        inlines: title,
    });
    for group in groups {
        for (term, _) in marked_terms(group.inlines) {
            found.insert((term.to_owned(), "marked"));
        }
        let text = prose(group.inlines);
        let everyday =
            |term: &String| group.in_problem() && lesson.header.everyday_mentions.contains(term);
        found.extend(
            book.terms
                .iter()
                .filter(|(term, definition)| definition.strict && !everyday(term))
                .filter(|(_, definition)| {
                    definition
                        .forms
                        .iter()
                        .any(|form| contains_form(&text, form))
                })
                .map(|(term, _)| (term.clone(), "prose")),
        );
    }
    found
}

pub fn check_recall_sources(book: &RouteBook<'_>) -> Vec<Violation> {
    let mut violations = Vec::new();
    for lesson in book.lessons {
        let tagged: Vec<String> = crate::route_text::summary_lists(&lesson.blocks)
            .into_iter()
            .flat_map(|entry| summary_tags(entry).0)
            .collect();
        for term in &lesson.header.introduces {
            let count = tagged.iter().filter(|tag| *tag == term).count();
            if count != 1 {
                violations.push(Violation::new(
                    RuleId::RouteRecallSource,
                    lesson.path.clone(),
                    format!("`{term}` appears in {count} summary items instead of one"),
                ));
            }
        }
        for term in recalled_terms(&lesson.blocks) {
            if !lesson.header.uses.contains(&term) {
                violations.push(Violation::new(
                    RuleId::RouteRecallSource,
                    lesson.path.clone(),
                    format!("recalls `{term}`, which is not in `usa`"),
                ));
            }
        }
    }
    violations
}

pub fn check_prerequisites(book: &RouteBook<'_>) -> Vec<Violation> {
    let mut violations = Vec::new();
    for (position, lesson) in book.lessons.iter().enumerate() {
        let mut report = |detail: String| {
            violations.push(Violation::new(
                RuleId::RoutePrerequisite,
                lesson.path.clone(),
                detail,
            ));
        };
        for need in &lesson.header.needs {
            if book.position(need).is_none_or(|found| found >= position) {
                report(format!("needs `{need}`, which is not an earlier lesson"));
            }
        }
        let reachable = reachable(book, lesson);
        for term in &lesson.header.uses {
            let owner = book.owner(term).and_then(|owner| book.lessons.get(owner));
            match owner {
                Some(owner) if reachable.contains(owner.header.id.as_str()) => {}
                Some(owner) => report(format!(
                    "uses `{term}` without needing `{}`",
                    owner.header.id
                )),
                None => report(format!("uses `{term}`, which no lesson introduces")),
            }
        }
    }
    violations
}

fn reachable<'book>(
    book: &'book RouteBook<'_>,
    lesson: &'book LessonDocument,
) -> BTreeSet<&'book str> {
    let mut seen = BTreeSet::new();
    let mut pending: Vec<&str> = lesson.header.needs.iter().map(String::as_str).collect();
    while let Some(next) = pending.pop() {
        if !seen.insert(next) {
            continue;
        }
        if let Some(found) = book
            .lessons
            .iter()
            .find(|candidate| candidate.header.id == next)
        {
            pending.extend(found.header.needs.iter().map(String::as_str));
        }
    }
    seen
}

pub fn is_summary(block: &SourceBlock) -> bool {
    matches!(
        block,
        SourceBlock::Callout {
            kind: CalloutKind::Summary,
            ..
        }
    )
}
