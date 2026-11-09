mod route_support;

use reference_model::{
    ExerciseCheck, ExerciseKind, LapCheck, LapSource, RoleRuns, RuleId, RunRecord, Violation,
};
use reference_verify::{
    RouteBook, check_exercise_mix, check_exercise_runs, check_exercise_shape, check_hints,
    check_no_recipe, check_no_spec_duplicate, check_prerequisites, check_recall_sources,
    check_route_anatomy, check_route_format, check_route_parity, check_scaffold, check_term_order,
    check_term_owners, outputs_match,
};
use route_support::{exercise, exercises_for_valid, lesson, terms};

fn rules(violations: &[Violation]) -> Vec<RuleId> {
    violations.iter().map(|violation| violation.rule).collect()
}

fn book_check(
    lessons: &[reference_model::LessonDocument],
    check: fn(&RouteBook<'_>) -> Vec<Violation>,
) -> Vec<Violation> {
    let exercises = exercises_for_valid();
    let terms = terms();
    check(&RouteBook {
        lessons,
        exercises: &exercises,
        terms: &terms,
    })
}

#[test]
fn the_valid_lesson_passes_every_source_check() {
    let valid = [lesson("valid/leccion.md")];
    for check in [
        check_term_order,
        check_recall_sources,
        check_prerequisites,
        check_exercise_mix,
    ] {
        assert_eq!(book_check(&valid, check), Vec::new());
    }
    let only = valid.first().cloned();
    assert!(only.is_some());
    let only = only.unwrap_or_else(|| lesson("valid/leccion.md"));
    assert!(check_route_anatomy(&only, false).is_empty());
    assert!(check_scaffold(&only).is_empty());
    assert!(check_no_spec_duplicate(&only).is_empty());
    assert!(check_route_format(&only.path, &only.blocks).is_empty());
}

#[test]
fn an_answer_without_attempt_breaks_the_format() {
    let broken = lesson("format/leccion.md");
    assert_eq!(
        rules(&check_route_format(&broken.path, &broken.blocks)),
        vec![RuleId::RouteFormat]
    );
}

#[test]
fn a_lesson_without_problem_breaks_the_anatomy() {
    let broken = lesson("anatomy/leccion.md");
    assert_eq!(
        rules(&check_route_anatomy(&broken, false)),
        vec![RuleId::RouteAnatomy]
    );
    let valid = lesson("valid/leccion.md");
    assert!(check_route_anatomy(&valid, true).is_empty());
}

#[test]
fn a_term_introduced_twice_has_two_owners() {
    let lessons = [
        lesson("term-owner/leccion.md"),
        lesson("term-owner/otra.md"),
    ];
    let found = book_check(&lessons, check_term_owners);
    assert!(rules(&found).contains(&RuleId::RouteTermOwner));
}

#[test]
fn a_strict_term_before_its_owner_is_reported() {
    let owner = lesson("valid/leccion.md")
        .header
        .id
        .replace("base", "duena");
    let mut later = lesson("valid/leccion.md");
    later.header.id = owner;
    later.header.introduces = vec!["variable".to_owned()];
    let lessons = [lesson("term-order/leccion.md"), later];
    let found = book_check(&lessons, check_term_order);
    assert_eq!(rules(&found), vec![RuleId::RouteTermOrder]);
}

#[test]
fn an_untagged_summary_has_no_recall_source() {
    let lessons = [lesson("recall-source/leccion.md")];
    assert_eq!(
        rules(&book_check(&lessons, check_recall_sources)),
        vec![RuleId::RouteRecallSource]
    );
}

#[test]
fn a_used_term_without_its_owner_needs_a_prerequisite() {
    let lessons = [lesson("prereq/leccion.md")];
    assert_eq!(
        rules(&book_check(&lessons, check_prerequisites)),
        vec![RuleId::RoutePrerequisite]
    );
}

#[test]
fn a_syntax_form_duplicates_the_specification() {
    let broken = lesson("no-spec-dup/leccion.md");
    assert_eq!(
        rules(&check_no_spec_duplicate(&broken)),
        vec![RuleId::RouteNoSpecDuplicate]
    );
}

#[test]
fn an_anatomy_duplicates_the_specification() {
    let mut broken = lesson("valid/leccion.md");
    broken
        .blocks
        .push(reference_model::SourceBlock::Anatomy(vec![
            reference_model::AnatomySource {
                code: "Escribir".to_owned(),
                label: vec![reference_model::Inline::Text("orden".to_owned())],
            },
        ]));
    assert_eq!(
        rules(&check_no_spec_duplicate(&broken)),
        vec![RuleId::RouteNoSpecDuplicate]
    );
}

#[test]
fn four_exercises_are_not_enough() {
    let lessons = [lesson("exercise-mix/leccion.md")];
    assert!(rules(&book_check(&lessons, check_exercise_mix)).contains(&RuleId::RouteExerciseMix));
}

#[test]
fn a_recipe_term_in_a_problem_is_reported() {
    let broken = lesson("statement-no-recipe/leccion.md");
    let (exercises, terms) = (exercises_for_valid(), terms());
    let lessons = [broken.clone()];
    let book = RouteBook {
        lessons: &lessons,
        exercises: &exercises,
        terms: &terms,
    };
    let found = check_no_recipe(
        &book,
        &route_support::corpus(),
        (&broken.path, &broken.blocks),
        true,
    );
    assert_eq!(rules(&found), vec![RuleId::RouteStatementNoRecipe]);
}

#[test]
fn three_hints_break_the_ladder() {
    assert_eq!(
        rules(&check_hints(&exercise("hints/ejercicio.md"))),
        vec![RuleId::RouteHints]
    );
    assert!(check_hints(&exercise("parity/ejercicio.md")).is_empty());
}

#[test]
fn separated_phases_in_part_two_break_the_scaffold() {
    assert_eq!(
        rules(&check_scaffold(&lesson("scaffold/leccion.md"))),
        vec![RuleId::RouteScaffold]
    );
}

#[test]
fn an_exercise_only_in_spanish_breaks_parity() {
    let spanish = [exercise("parity/ejercicio.md")];
    let found = check_route_parity((&[], &[]), (&spanish, &[]));
    assert_eq!(rules(&found), vec![RuleId::RouteParity]);
}

fn record(output: &str, expected: Option<&str>) -> RunRecord {
    RunRecord {
        inputs: vec!["1".to_owned()],
        expected: expected.map(str::to_owned),
        hidden: false,
        output: output.to_owned(),
        termination: "completed".to_owned(),
    }
}

fn runs(role: &str, cases: Vec<RunRecord>, breakers: Vec<RunRecord>) -> RoleRuns {
    RoleRuns {
        role: role.to_owned(),
        id: role.to_owned(),
        cases,
        breakers,
        solution: Vec::new(),
    }
}

#[test]
fn a_breaker_that_does_not_break_is_reported() {
    let check = ExerciseCheck {
        location: "romper.md".to_owned(),
        kind: ExerciseKind::Break,
        roles: vec![
            runs(
                "defectuoso",
                vec![record("5", Some("5"))],
                vec![record("2", None)],
            ),
            runs(
                "referencia",
                vec![record("5", Some("5"))],
                vec![record("2", None)],
            ),
        ],
        laps: None,
        structural: false,
    };
    assert_eq!(
        rules(&check_exercise_runs(&check)),
        vec![RuleId::RouteExerciseVerified]
    );
}

#[test]
fn a_breaker_that_breaks_and_a_matching_trace_pass() {
    let check = ExerciseCheck {
        location: "romper.md".to_owned(),
        kind: ExerciseKind::Break,
        roles: vec![
            runs(
                "defectuoso",
                vec![record("5", Some("5"))],
                vec![record("3", None)],
            ),
            runs(
                "referencia",
                vec![record("5", Some("5.0"))],
                vec![record("2", None)],
            ),
        ],
        laps: None,
        structural: false,
    };
    assert!(check_exercise_runs(&check).is_empty());
    let traced = ExerciseCheck {
        location: "rastrear.md".to_owned(),
        kind: ExerciseKind::Trace,
        roles: Vec::new(),
        laps: Some(LapCheck {
            expected: vec![LapSource {
                label: "antes".to_owned(),
                cells: vec!["0".to_owned(), "?1".to_owned()],
            }],
            observed: vec![vec!["0".to_owned(), "2".to_owned()]],
            termination: "completed".to_owned(),
        }),
        structural: false,
    };
    assert_eq!(
        rules(&check_exercise_runs(&traced)),
        vec![RuleId::RouteExerciseVerified]
    );
}

fn modification(structural: bool) -> ExerciseCheck {
    ExerciseCheck {
        location: "modificar.md".to_owned(),
        kind: ExerciseKind::Modify,
        roles: vec![
            runs("inicial", vec![hidden(record("5", Some("5")))], Vec::new()),
            runs(
                "referencia",
                vec![hidden(record("5", Some("5")))],
                Vec::new(),
            ),
        ],
        laps: None,
        structural,
    }
}

fn hidden(mut record: RunRecord) -> RunRecord {
    record.hidden = true;
    record
}

#[test]
fn a_modification_without_assertions_must_change_the_behaviour() {
    assert_eq!(
        rules(&check_exercise_runs(&modification(false))),
        vec![RuleId::RouteExerciseVerified]
    );
}

#[test]
fn a_structural_modification_may_keep_the_behaviour() {
    assert!(check_exercise_runs(&modification(true)).is_empty());
}

#[test]
fn a_solve_exercise_with_inputs_needs_hidden_cases() {
    let text = std::fs::read_to_string(format!(
        "{}/../../fixtures/route/valid/ejercicio.md",
        env!("CARGO_MANIFEST_DIR")
    ))
    .unwrap_or_default()
    .replace("visible | — | 3", "visible | 1 | 3\nvisible | 2 | 3");
    let found = check_exercise_shape(&route_support::exercise_text("casos.md", &text));
    assert_eq!(rules(&found), vec![RuleId::RouteExerciseVerified]);
    assert!(check_exercise_shape(&exercise("parity/ejercicio.md")).is_empty());
}

#[test]
fn outputs_compare_like_the_app() {
    assert!(outputs_match("14.0\n", "14"));
    assert!(outputs_match("Día  9\n\n", "Día 9"));
    assert!(!outputs_match("Día 9", "Día 10"));
    assert!(!outputs_match("", "x"));
    assert!(outputs_match("0.30000000000000004", "0.3"));
}

#[test]
fn a_false_promise_in_a_lesson_program_is_parsed_for_checking() {
    let promised = lesson("example-verified/leccion.md");
    let program = promised.blocks.iter().find_map(|block| match block {
        reference_model::SourceBlock::Program(program) => Some(program.clone()),
        _ => None,
    });
    assert_eq!(
        program.and_then(|program| program.promise.output),
        Some("4".to_owned())
    );
}

fn spec_targets() -> std::collections::BTreeMap<String, reference_model::PublishedSection> {
    use reference_model::{Block, PublishedSection, SectionKind};
    let section = PublishedSection {
        id: "control.si".to_owned(),
        number: "6.1".to_owned(),
        kind: SectionKind::Construction,
        title: Vec::new(),
        phrase: Vec::new(),
        blocks: vec![Block::Heading {
            id: "funciona".to_owned(),
            number: "6.1.1".to_owned(),
            runs: Vec::new(),
        }],
    };
    std::collections::BTreeMap::from([("control.si".to_owned(), section)])
}

fn spec_link(section: &str, anchor: Option<&str>) -> reference_model::Run {
    reference_model::Run::SpecLink {
        section: section.to_owned(),
        anchor: anchor.map(str::to_owned),
        text: "x".to_owned(),
    }
}

fn lesson_link(lesson: &str) -> reference_model::Run {
    reference_model::Run::LessonLink {
        lesson: lesson.to_owned(),
        text: "x".to_owned(),
    }
}

#[test]
fn links_to_unknown_sections_anchors_and_lessons_are_reported() {
    use reference_verify::{LinkTargets, check_route_links};
    let sections = spec_targets();
    let targets = LinkTargets {
        sections: &sections,
        lessons: ["inicio.base".to_owned()].into_iter().collect(),
    };
    let good = vec![
        spec_link("control.si", Some("funciona")),
        lesson_link("inicio.base"),
    ];
    assert!(check_route_links("leccion", &good, &targets).is_empty());
    let bad = vec![
        spec_link("control.no", None),
        spec_link("control.si", Some("nada")),
        lesson_link("inicio.nada"),
    ];
    assert_eq!(
        rules(&check_route_links("leccion", &bad, &targets)),
        vec![
            RuleId::RouteSpecLink,
            RuleId::RouteSpecLink,
            RuleId::RouteLinkValid
        ]
    );
}

fn shaped(kind: &str, body: &str) -> Vec<RuleId> {
    let text = format!(
        "---\nid: inicio.base.x\nleccion: inicio.base\ntipo: {kind}\nnivel: semilla\ntitulo: X\n---\n\n{body}"
    );
    rules(&check_exercise_shape(&route_support::exercise_text(
        "x.md", &text,
    )))
}

#[test]
fn assertions_outside_the_closed_catalog_are_reported() {
    let valid = "```aserciones\n- declara-subprograma | Area | 2 | Usa Area\n- contiene | bucle-contado | Usa un bucle\n```\n";
    assert!(shaped("modificar", valid).is_empty());
    for broken in [
        "```aserciones\n- contiene | funcion-pura | Usa funciones puras\n```\n",
        "```aserciones\n- declara-miembro | Caja | saldo | secreto | Oculta el saldo\n```\n",
        "```aserciones\n- repite-como-mucho | bucle-contado | muchos | Un bucle\n```\n",
        "```aserciones\n- contiene | clase\n```\n",
    ] {
        assert_eq!(
            shaped("modificar", broken),
            vec![RuleId::RouteExerciseVerified]
        );
    }
}

#[test]
fn solution_cases_must_fit_their_limits() {
    assert!(
        shaped(
            "disenar-pruebas",
            "```casos-solucion minimo=1 maximo=2\n1 | 1\n```\n"
        )
        .is_empty()
    );
    assert_eq!(
        shaped(
            "disenar-pruebas",
            "```casos-solucion minimo=2 maximo=3\n1 | 1\n```\n"
        ),
        vec![RuleId::RouteExerciseVerified]
    );
    assert_eq!(
        shaped(
            "disenar-pruebas",
            "```casos-solucion minimo=3 maximo=2\n1 | 1\n2 | 2\n```\n"
        )
        .len(),
        2
    );
}

#[test]
fn breaking_inputs_give_as_many_values_as_the_program_reads() {
    let body = "```casos\nvisible | 1 ; 2 | 3\n```\n\n```rompe\n4 ; 5\n6\n```\n";
    assert_eq!(
        shaped("romperlo", body),
        vec![RuleId::RouteExerciseVerified]
    );
}

#[test]
fn trace_tables_need_a_cell_to_fill_and_a_start_for_the_first_row() {
    assert!(
        shaped(
            "rastrear",
            "```vueltas marca=3 inicio=2 columnas=n\nantes | 0\n1 | ?1\n```\n"
        )
        .is_empty()
    );
    assert_eq!(
        shaped(
            "rastrear",
            "```vueltas marca=3 columnas=n\nantes | 0\n1 | 1\n```\n"
        )
        .len(),
        2
    );
}

#[test]
fn a_classification_needs_two_categories() {
    let body = "```categorias\n- Entero\n```\n\n```elementos\n- 1 | Entero\n```\n";
    assert_eq!(
        shaped("clasificar", body),
        vec![RuleId::RouteExerciseVerified]
    );
}
