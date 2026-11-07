mod support;

use reference_model::{
    Evaluation, LapSource, LapTable, LessonBlock, Profile, PublishedSection, RouteBlock, RuleId,
    SectionKind,
};
use reference_resolve::{Resolution, SpanishReuse};
use route_resolve::{
    RouteContext, build_catalog, instrument, observed_rows, program_blocks, resolve_exercise,
    resolve_lesson, shuffled_order,
};
use std::collections::BTreeMap;
use support::EchoEngine;

const HEADER: &str = "---\nid: inicio.base\nnumero: \"0.1\"\ntipo: leccion\ntitulo: Base\nduracion: 10\nproblema_breve: Algo\nintroduce: [problema]\n---\n\n";

fn lesson(body: &str) -> reference_model::LessonDocument {
    reference_format::parse_lesson("leccion.md", &format!("{HEADER}{body}"))
        .unwrap_or_else(|violation| panic_free(&violation.detail))
}

fn panic_free(detail: &str) -> reference_model::LessonDocument {
    assert!(detail.is_empty(), "{detail}");
    reference_format::parse_lesson("vacio.md", HEADER).unwrap_or_else(|_| unreachable_lesson())
}

fn unreachable_lesson() -> reference_model::LessonDocument {
    reference_model::RouteDocument {
        path: String::new(),
        header: reference_model::LessonHeader {
            id: String::new(),
            number: String::new(),
            kind: reference_model::LessonKind::Lesson,
            title: String::new(),
            minutes: 0,
            brief_problem: String::new(),
            needs: Vec::new(),
            introduces: Vec::new(),
            uses: Vec::new(),
            piece: None,
            everyday_mentions: Vec::new(),
        },
        title: Vec::new(),
        blocks: Vec::new(),
    }
}

fn exercise(kind: &str, body: &str) -> reference_model::ExerciseDocument {
    let text = format!(
        "---\nid: inicio.base.x\nleccion: inicio.base\ntipo: {kind}\nnivel: semilla\ntitulo: X\n---\n\n{body}"
    );
    let parsed = reference_format::parse_exercise("x.md", &text);
    assert!(parsed.is_ok(), "{parsed:?}");
    parsed.unwrap_or_else(|_| reference_model::RouteDocument {
        path: String::new(),
        header: reference_model::ExerciseHeader {
            id: String::new(),
            lesson: String::new(),
            kind: reference_model::ExerciseKind::Solve,
            level: reference_model::ExerciseLevel::Seed,
            required: false,
            title: String::new(),
        },
        title: Vec::new(),
        blocks: Vec::new(),
    })
}

struct Fixture {
    corpus: reference_corpus::Corpus,
    categories: reference_resolve::CategoryTable,
    pack: reference_resolve::LanguagePack,
    figures: BTreeMap<String, String>,
    index: reference_resolve::SectionIndex,
    specification: BTreeMap<String, PublishedSection>,
}

fn fixture() -> Fixture {
    let section = PublishedSection {
        id: "control.si".to_owned(),
        number: "6.1".to_owned(),
        kind: SectionKind::Construction,
        title: Vec::new(),
        phrase: Vec::new(),
        blocks: Vec::new(),
    };
    Fixture {
        corpus: support::corpus(),
        categories: support::categories(),
        pack: support::pack(),
        figures: support::figures(),
        index: support::index(),
        specification: BTreeMap::from([("control.si".to_owned(), section)]),
    }
}

fn with_context<Output>(
    profile: Profile,
    lessons: &[reference_model::LessonDocument],
    run: impl FnOnce(&RouteContext<'_>) -> Output,
) -> Output {
    let fixture = fixture();
    let resolution = Resolution {
        engine: &EchoEngine,
        corpus: &fixture.corpus,
        categories: &fixture.categories,
        pack: &fixture.pack,
        figures: &fixture.figures,
        index: &fixture.index,
        language: Profile::Spanish,
        profile,
    };
    let catalog = build_catalog(lessons, &[], &BTreeMap::new());
    let context = RouteContext {
        resolution: &resolution,
        catalog: &catalog,
        specification: &fixture.specification,
        current: "inicio.base",
    };
    run(&context)
}

#[test]
fn shuffles_deterministically_without_keeping_the_order() {
    let order = shuffled_order("ejercicio", 5);
    assert_eq!(order, shuffled_order("ejercicio", 5));
    let mut sorted = order.clone();
    sorted.sort_unstable();
    assert_eq!(sorted, vec![0, 1, 2, 3, 4]);
    assert_ne!(order, vec![0, 1, 2, 3, 4]);
    assert_eq!(shuffled_order("x", 1), vec![0]);
    assert!(shuffled_order("x", 0).is_empty());
}

#[test]
fn instruments_the_lap_lines_and_reads_them_back() {
    let table = LapTable {
        mark: 3,
        start: Some(2),
        columns: vec!["n".to_owned(), "total".to_owned()],
        rows: vec![LapSource::default()],
    };
    let code = instrument("Algoritmo A\nMientras x\n  x <- 1;\nFinMientras\n", &table);
    let lines: Vec<&str> = code.lines().collect();
    assert_eq!(lines.len(), 6);
    assert!(
        lines
            .get(1)
            .is_some_and(|line| line.contains("\"⟦\", n, \"|\", total"))
    );
    assert!(
        lines
            .get(3)
            .is_some_and(|line| line.starts_with("Escribir"))
    );
    assert_eq!(
        observed_rows("hola\n⟦1|Verdadero⟧\n"),
        vec![vec!["1".to_owned(), "Verdadero".to_owned()]]
    );
}

#[test]
fn keeps_the_first_and_last_program_lines_fixed() {
    let (head, blocks, tail) =
        program_blocks("Algoritmo A\n  Leer x;\n\n  Escribir x;\nFinAlgoritmo\n");
    assert_eq!(head, "Algoritmo A");
    assert_eq!(blocks, vec!["Leer x;".to_owned(), "Escribir x;".to_owned()]);
    assert_eq!(tail, "FinAlgoritmo");
    assert_eq!(
        program_blocks(""),
        (String::new(), Vec::new(), String::new())
    );
}

#[test]
fn publishes_phase_strips_and_pairs_attempts() {
    let lessons = [lesson(
        "## Entender {#entender fase=1}\n\n::: intento\nPiensa.\n:::\n\n::: respuesta\nTres.\n:::\n",
    )];
    let resolved = with_context(Profile::Spanish, &lessons, |context| {
        resolve_lesson(context, &lessons[0], &SpanishReuse::default())
    });
    let kinds: Vec<&str> = resolved
        .lesson
        .blocks
        .iter()
        .map(|block| match block {
            LessonBlock::Route(RouteBlock::Cycle { .. }) => "cycle",
            LessonBlock::Route(RouteBlock::PhaseHeading { .. }) => "phase",
            LessonBlock::Route(RouteBlock::Attempt { answer, .. }) if !answer.is_empty() => {
                "attempt"
            }
            _ => "other",
        })
        .collect();
    assert_eq!(kinds, vec!["cycle", "phase", "attempt"]);
    assert!(resolved.violations.is_empty());
}

#[test]
fn reports_lonely_attempts_unknown_recalls_figures_and_exercises() {
    let lessons = [lesson(
        "::: intento\nPiensa.\n:::\n\n::: recuerda termino=nada\n:::\n\n```figura-especificacion seccion=control.no figura=x\n```\n\n```figura-especificacion seccion=control.si figura=x\n```\n\n::: practica\n- inicio.base.nada\n:::\n\n```casos\nvisible | 1 | 1\n```\n",
    )];
    let resolved = with_context(Profile::Spanish, &lessons, |context| {
        resolve_lesson(context, &lessons[0], &SpanishReuse::default())
    });
    let rules: Vec<RuleId> = resolved
        .violations
        .iter()
        .map(|violation| violation.rule)
        .collect();
    assert_eq!(
        rules,
        vec![
            RuleId::RouteFormat,
            RuleId::RouteRecallSource,
            RuleId::RouteSpecLink,
            RuleId::RouteSpecLink,
            RuleId::RouteExerciseMix,
            RuleId::RouteFormat,
        ]
    );
}

#[test]
fn orders_steps_with_a_solution_that_restores_them() {
    let document = exercise(
        "ordenar",
        "```pasos\n- Uno.\n- Dos.\n- Tres.\n- Cuatro.\n```\n",
    );
    let resolved = with_context(Profile::Spanish, &[], |context| {
        resolve_exercise(context, &document, None, &SpanishReuse::default())
    });
    let (steps, solution) = match resolved.exercise.evaluation {
        Evaluation::OrderSteps { steps, solution } => (steps, solution),
        _ => (Vec::new(), Vec::new()),
    };
    let text = |index: &usize| {
        steps
            .get(*index)
            .map(|runs| format!("{runs:?}"))
            .unwrap_or_default()
    };
    let restored: Vec<String> = solution.iter().map(text).collect();
    assert!(restored.first().is_some_and(|first| first.contains("Uno")));
    assert!(restored.last().is_some_and(|last| last.contains("Cuatro")));
}

#[test]
fn checks_break_exercises_only_in_the_spanish_profile() {
    let body = "```programa rol=defectuoso\nAlgoritmo D\nFinAlgoritmo\n```\n\n```programa rol=referencia\nAlgoritmo R doble\nFinAlgoritmo\n```\n\n```casos\nvisible | 5 | 55\n```\n\n```rompe\n2\n```\n";
    let document = exercise("romperlo", body);
    let spanish = with_context(Profile::Spanish, &[], |context| {
        resolve_exercise(context, &document, None, &SpanishReuse::default())
    });
    let check = spanish.check.unwrap_or_else(unreachable_check);
    assert_eq!(check.roles.len(), 2);
    assert_eq!(
        check
            .role("defectuoso")
            .and_then(|runs| runs.breakers.first())
            .map(|run| run.output.clone()),
        Some("2\n".to_owned())
    );
    assert!(matches!(
        spanish.exercise.evaluation,
        Evaluation::Break { reads: 1, ref cases, .. } if cases.first().is_some_and(|case| case.expected == "55")
    ));
    let english = with_context(Profile::English, &[], |context| {
        resolve_exercise(context, &document, None, &SpanishReuse::default())
    });
    assert!(english.check.is_none());
}

fn unreachable_check() -> reference_model::ExerciseCheck {
    reference_model::ExerciseCheck {
        location: String::new(),
        kind: reference_model::ExerciseKind::Break,
        roles: Vec::new(),
        laps: None,
    }
}

#[test]
fn classifies_and_reuses_spanish_fences() {
    let spanish = exercise(
        "clasificar",
        "```categorias\n- Entero\n- Cadena\n```\n\n```elementos\n- 23 | Entero\n- \"Ana\" | Cadena\n- 2.5 | Real\n```\n",
    );
    let resolved = with_context(Profile::Spanish, &[], |context| {
        resolve_exercise(context, &spanish, None, &SpanishReuse::default())
    });
    assert!(matches!(
        resolved.exercise.evaluation,
        Evaluation::Classify { ref elements, .. }
            if elements.iter().map(|element| element.category).collect::<Vec<_>>() == vec![0, 1, usize::MAX]
    ));
    let english = exercise(
        "resolver",
        "```programa rol=referencia\nAlgoritmo R\nFinAlgoritmo\n```\n\n```casos\n```\n",
    );
    let original = exercise(
        "resolver",
        "```programa rol=referencia\nAlgoritmo R\nFinAlgoritmo\n```\n\n```casos\nvisible | 7 | 7\n```\n",
    );
    let reused = with_context(Profile::Spanish, &[], |context| {
        resolve_exercise(context, &english, Some(&original), &SpanishReuse::default())
    });
    assert!(matches!(
        reused.exercise.evaluation,
        Evaluation::Cases { ref cases, .. } if cases.len() == 1
    ));
}
