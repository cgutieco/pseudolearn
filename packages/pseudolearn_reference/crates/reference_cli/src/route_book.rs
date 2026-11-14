use crate::book::{Book, section_index};
use crate::route_workspace::RouteLanguage;
use crate::workspace::Workspace;
use reference_export::{Bundle, RouteBundleInput, RouteTerm, build_route_bundle, digest};
use reference_model::{
    CodeEngine, ExampleCheck, ExerciseCheck, ExerciseDocument, Profile, PublishedExercise,
    PublishedLesson, PublishedSection, SourceBlock, Violation,
};
use reference_resolve::{Resolution, SpanishReuse, resolve_runs};
use route_resolve::{RouteCatalog, RouteContext, build_catalog, resolve_exercise, resolve_lesson};
use std::collections::BTreeMap;

pub struct RouteEdition {
    pub language: Profile,
    pub profile: Profile,
    pub lessons: Vec<PublishedLesson>,
    pub exercises: Vec<PublishedExercise>,
    pub examples: Vec<ExampleCheck>,
    pub checks: Vec<ExerciseCheck>,
    pub violations: Vec<Violation>,
    pub terms: BTreeMap<String, RouteTerm>,
    pub specification: BTreeMap<String, PublishedSection>,
}

struct Shared<'shared> {
    reuse: BTreeMap<String, SpanishReuse>,
    spanish: BTreeMap<String, &'shared ExerciseDocument>,
}

pub fn compile_route(
    book: &mut Book,
    workspace: &Workspace,
    engine: &dyn CodeEngine,
) -> Result<(), String> {
    let empty = RouteLanguage::default();
    let spanish = workspace.route.get(&Profile::Spanish).unwrap_or(&empty);
    let shared = Shared {
        reuse: route_reuse(spanish),
        spanish: spanish
            .exercises
            .iter()
            .map(|exercise| (exercise.header.id.clone(), exercise))
            .collect(),
    };
    for (language, route) in &workspace.route {
        if route.lessons.is_empty() {
            continue;
        }
        let catalog = build_catalog(&route.lessons, &route.exercises, &route.terms);
        for profile in Profile::all() {
            let edition = route_edition(
                (workspace, engine),
                (*language, profile),
                (route, &catalog, &shared),
                specification_of(book, *language, profile),
            );
            add_route_edition(book, (engine, route), edition)?;
        }
    }
    Ok(())
}

fn specification_of(
    book: &Book,
    language: Profile,
    profile: Profile,
) -> BTreeMap<String, PublishedSection> {
    book.editions
        .iter()
        .find(|edition| edition.language == language && edition.profile == profile)
        .map(|edition| {
            edition
                .sections
                .iter()
                .map(|section| (section.id.clone(), section.clone()))
                .collect()
        })
        .unwrap_or_default()
}

fn add_route_edition(
    book: &mut Book,
    (engine, route): (&dyn CodeEngine, &RouteLanguage),
    edition: RouteEdition,
) -> Result<(), String> {
    let key = crate::edition_key::edition_key(edition.language, edition.profile);
    let specification = book
        .bundles
        .get(&key)
        .and_then(|bundle| bundle.files.get("manifest.json"))
        .map(|manifest| digest(manifest))
        .unwrap_or_default();
    let bundle = route_bundle(engine, route, &edition, &specification)?;
    book.route_bundles.insert(key, bundle);
    book.route_editions.push(edition);
    Ok(())
}

fn route_edition(
    (workspace, engine): (&Workspace, &dyn CodeEngine),
    (language, profile): (Profile, Profile),
    (route, catalog, shared): (&RouteLanguage, &RouteCatalog, &Shared<'_>),
    specification: BTreeMap<String, PublishedSection>,
) -> RouteEdition {
    let content = workspace.languages.get(&language);
    let documents = content
        .map(|content| content.documents.as_slice())
        .unwrap_or_default();
    let index = section_index(documents);
    let pack = content
        .map(|content| content.pack.clone())
        .unwrap_or_default();
    let resolution = Resolution {
        engine,
        corpus: &workspace.corpus,
        categories: &workspace.categories,
        pack: &pack,
        figures: &workspace.figures,
        index: &index,
        language,
        profile,
    };
    let mut edition = empty_edition(language, profile, terms_of(&resolution, catalog));
    let scope = (&resolution, catalog, &specification);
    resolve_lessons(&mut edition, scope, (route, shared));
    resolve_exercises(&mut edition, scope, (route, shared));
    edition.specification = specification;
    edition
}

fn empty_edition(
    language: Profile,
    profile: Profile,
    terms: BTreeMap<String, RouteTerm>,
) -> RouteEdition {
    RouteEdition {
        language,
        profile,
        lessons: Vec::new(),
        exercises: Vec::new(),
        examples: Vec::new(),
        checks: Vec::new(),
        violations: Vec::new(),
        terms,
        specification: BTreeMap::new(),
    }
}

type Scope<'scope> = (
    &'scope Resolution<'scope>,
    &'scope RouteCatalog,
    &'scope BTreeMap<String, PublishedSection>,
);

fn resolve_lessons(
    edition: &mut RouteEdition,
    (resolution, catalog, specification): Scope<'_>,
    (route, shared): (&RouteLanguage, &Shared<'_>),
) {
    let fallback = SpanishReuse::default();
    for lesson in &route.lessons {
        let context = RouteContext {
            resolution,
            catalog,
            specification,
            current: &lesson.header.id,
        };
        let reuse = shared.reuse.get(&lesson.header.id).unwrap_or(&fallback);
        let resolved = resolve_lesson(&context, lesson, reuse);
        edition.lessons.push(resolved.lesson);
        edition.examples.extend(resolved.examples);
        edition.violations.extend(resolved.violations);
    }
}

fn resolve_exercises(
    edition: &mut RouteEdition,
    (resolution, catalog, specification): Scope<'_>,
    (route, shared): (&RouteLanguage, &Shared<'_>),
) {
    let fallback = SpanishReuse::default();
    for exercise in &route.exercises {
        let context = RouteContext {
            resolution,
            catalog,
            specification,
            current: &exercise.header.lesson,
        };
        let reuse = shared.reuse.get(&exercise.header.id).unwrap_or(&fallback);
        let spanish = shared.spanish.get(&exercise.header.id).copied();
        let resolved = resolve_exercise(&context, exercise, spanish, reuse);
        edition.exercises.push(resolved.exercise);
        edition.checks.extend(resolved.check);
        edition.examples.extend(resolved.examples);
        edition.violations.extend(resolved.violations);
    }
}

fn route_bundle(
    engine: &dyn CodeEngine,
    route: &RouteLanguage,
    edition: &RouteEdition,
    specification: &str,
) -> Result<Bundle, String> {
    build_route_bundle(&RouteBundleInput {
        language: edition.language.code(),
        profile: edition.profile.code(),
        engine: &engine.fingerprint(),
        specification,
        parts: &route.parts,
        lessons: &edition.lessons,
        exercises: &edition.exercises,
        terms: &edition.terms,
    })
}

fn route_reuse(spanish: &RouteLanguage) -> BTreeMap<String, SpanishReuse> {
    let lessons = spanish
        .lessons
        .iter()
        .map(|lesson| (lesson.header.id.clone(), programs_of(&lesson.blocks)));
    let exercises = spanish
        .exercises
        .iter()
        .map(|exercise| (exercise.header.id.clone(), programs_of(&exercise.blocks)));
    lessons.chain(exercises).collect()
}

fn programs_of(blocks: &[SourceBlock]) -> SpanishReuse {
    let mut reuse = SpanishReuse::default();
    for block in crate::book::flattened(blocks) {
        if let SourceBlock::Program(program) = block {
            reuse.programs.insert(program.id.clone(), program.clone());
        }
    }
    reuse
}

pub fn terms_of(
    resolution: &Resolution<'_>,
    catalog: &RouteCatalog,
) -> BTreeMap<String, RouteTerm> {
    catalog
        .terms
        .iter()
        .map(|(term, card)| {
            (
                term.clone(),
                RouteTerm {
                    label: card.label.clone(),
                    lesson: card.owner.id.clone(),
                    phrase: resolve_runs(resolution, &card.summary),
                },
            )
        })
        .collect()
}
