use crate::book::Book;
use crate::route_workspace::RouteLanguage;
use crate::workspace::Workspace;
use reference_model::{Profile, RuleId, SectionHeader, SectionKind, SourceDocument, Violation};
use reference_verify::{
    LinkTargets, RouteBook, check_examples, check_exercise_mix, check_exercise_runs,
    check_exercise_shape, check_hints, check_inline_code, check_new_tool, check_no_recipe,
    check_no_spec_duplicate, check_prerequisites, check_recall_sources, check_route_anatomy,
    check_route_format, check_route_links, check_route_parity, check_scaffold, check_term_order,
    check_term_owners, find_identifier,
};

pub fn verify_route(workspace: &Workspace, book: &Book) -> Vec<Violation> {
    let empty = RouteLanguage::default();
    let spanish = workspace.route.get(&Profile::Spanish).unwrap_or(&empty);
    let english = workspace.route.get(&Profile::English).unwrap_or(&empty);
    let mut violations = edition_violations(book);
    for (language, route) in [(Profile::Spanish, spanish), (Profile::English, english)] {
        violations.extend(language_violations(workspace, route, language));
    }
    violations.extend(spanish_only(spanish));
    violations.extend(check_route_parity(
        (&spanish.lessons, &english.lessons),
        (&spanish.exercises, &english.exercises),
    ));
    violations
}

fn edition_violations(book: &Book) -> Vec<Violation> {
    let mut violations = Vec::new();
    for edition in &book.route_editions {
        violations.extend(edition.violations.iter().cloned());
        violations.extend(check_examples(&edition.examples).into_iter().map(retag));
        violations.extend(edition.checks.iter().flat_map(check_exercise_runs));
        let targets = LinkTargets {
            sections: &edition.specification,
            lessons: edition
                .lessons
                .iter()
                .map(|lesson| lesson.id.clone())
                .collect(),
        };
        for lesson in &edition.lessons {
            violations.extend(check_route_links(&lesson.id, lesson, &targets));
            violations.extend(internal_ids(
                &lesson.id,
                &serde_json::to_string(lesson).unwrap_or_default(),
            ));
        }
        for exercise in &edition.exercises {
            violations.extend(check_route_links(&exercise.id, exercise, &targets));
            violations.extend(internal_ids(
                &exercise.id,
                &serde_json::to_string(exercise).unwrap_or_default(),
            ));
        }
    }
    violations
}

fn retag(violation: Violation) -> Violation {
    Violation::new(
        RuleId::RouteExampleVerified,
        violation.location,
        violation.detail,
    )
}

fn internal_ids(location: &str, text: &str) -> Vec<Violation> {
    find_identifier(text)
        .map(|found| {
            Violation::new(
                RuleId::NoInternalIds,
                location,
                format!("published text contains the internal identifier `{found}`"),
            )
        })
        .into_iter()
        .collect()
}

fn language_violations(
    workspace: &Workspace,
    route: &RouteLanguage,
    language: Profile,
) -> Vec<Violation> {
    let book = RouteBook {
        lessons: &route.lessons,
        exercises: &route.exercises,
        terms: &route.terms,
    };
    let mut violations = check_term_order(&book);
    for lesson in &route.lessons {
        violations.extend(check_route_format(&lesson.path, &lesson.blocks));
        violations.extend(check_no_recipe(
            &book,
            &workspace.corpus,
            (&lesson.path, &lesson.blocks),
            true,
        ));
        let document = as_source(&lesson.path, &lesson.title, &lesson.blocks);
        violations.extend(check_inline_code(&document, &workspace.corpus, language));
    }
    for exercise in &route.exercises {
        violations.extend(check_route_format(&exercise.path, &exercise.blocks));
        violations.extend(check_no_recipe(
            &book,
            &workspace.corpus,
            (&exercise.path, &exercise.blocks),
            exercise.header.kind.writes_code(),
        ));
        let document = as_source(&exercise.path, &exercise.title, &exercise.blocks);
        violations.extend(check_inline_code(&document, &workspace.corpus, language));
    }
    violations
}

fn spanish_only(route: &RouteLanguage) -> Vec<Violation> {
    let book = RouteBook {
        lessons: &route.lessons,
        exercises: &route.exercises,
        terms: &route.terms,
    };
    let mut violations = check_term_owners(&book);
    violations.extend(check_recall_sources(&book));
    violations.extend(check_prerequisites(&book));
    violations.extend(check_exercise_mix(&book));
    let last = route.lessons.last().map(|lesson| lesson.header.id.clone());
    for lesson in &route.lessons {
        violations.extend(check_route_anatomy(
            lesson,
            last.as_ref() == Some(&lesson.header.id),
        ));
        violations.extend(check_scaffold(lesson));
        violations.extend(check_new_tool(lesson));
        violations.extend(check_no_spec_duplicate(lesson));
    }
    for exercise in &route.exercises {
        violations.extend(check_hints(exercise));
        violations.extend(check_exercise_shape(exercise));
    }
    violations
}

fn as_source(
    path: &str,
    title: &[reference_model::Inline],
    blocks: &[reference_model::SourceBlock],
) -> SourceDocument {
    SourceDocument {
        path: path.to_owned(),
        header: SectionHeader {
            id: String::new(),
            number: String::new(),
            kind: SectionKind::Concept,
            title: String::new(),
            anchors: Vec::new(),
            cards: Vec::new(),
            diagnostics: Vec::new(),
            terms: Vec::new(),
        },
        title: title.to_vec(),
        blocks: blocks.to_vec(),
    }
}
