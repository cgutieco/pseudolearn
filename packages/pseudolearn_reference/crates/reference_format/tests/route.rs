use reference_format::{parse_exercise, parse_lesson, summary_tags};
use reference_model::{CalloutKind, Inline, RouteFence, SourceBlock};

const LESSON: &str = "---\nid: inicio.base\nnumero: \"0.1\"\ntipo: leccion\ntitulo: Base\nduracion: 10\nproblema_breve: Algo\n---\n\n";

fn lesson_blocks(body: &str) -> Vec<SourceBlock> {
    let parsed = parse_lesson("leccion.md", &format!("{LESSON}{body}"));
    assert!(parsed.is_ok(), "{parsed:?}");
    parsed.map(|lesson| lesson.blocks).unwrap_or_default()
}

fn fence(body: &str) -> Option<RouteFence> {
    lesson_blocks(body)
        .into_iter()
        .find_map(|block| match block {
            SourceBlock::Route(fence) => Some(fence),
            _ => None,
        })
}

#[test]
fn reads_phase_headings_and_callout_attributes() {
    let blocks = lesson_blocks(
        "## Entender y planear {#entender fase=1-2}\n\n::: recuerda termino=bucle\n:::\n\n::: profundizar titulo=\"Más\"\nTexto.\n:::\n",
    );
    assert!(matches!(
        blocks.first(),
        Some(SourceBlock::Heading { id, phase: Some(phase), .. }) if id == "entender" && phase == "1-2"
    ));
    assert!(matches!(
        blocks.get(1),
        Some(SourceBlock::Callout { kind: CalloutKind::Recall, attributes, .. })
            if attributes.get("termino").map(String::as_str) == Some("bucle")
    ));
    assert!(matches!(
        blocks.get(2),
        Some(SourceBlock::Callout { kind: CalloutKind::Deepen, attributes, .. })
            if attributes.get("titulo").map(String::as_str) == Some("Más")
    ));
}

#[test]
fn reads_definitions_and_links_between_books() {
    let blocks = lesson_blocks(
        "Un [[def:bucle|bucle]] y un [[vuelta|par]], ver [esto](especificacion:control.si#funciona) y [aquello](ruta:inicio.otra).\n",
    );
    let inlines = match blocks.first() {
        Some(SourceBlock::Paragraph(inlines)) => inlines.clone(),
        _ => Vec::new(),
    };
    assert!(inlines.contains(&Inline::Definition {
        term: "bucle".to_owned(),
        text: "bucle".to_owned()
    }));
    assert!(inlines.contains(&Inline::SpecLink {
        section: "control.si".to_owned(),
        anchor: Some("funciona".to_owned()),
        text: "esto".to_owned()
    }));
    assert!(inlines.contains(&Inline::LessonLink {
        lesson: "inicio.otra".to_owned(),
        text: "aquello".to_owned()
    }));
}

#[test]
fn reads_cases_breakers_and_solution_limits() {
    let cases = fence(
        "```casos\nvisible | 50 | Día 9\noculto | 14 ; 17 ; -1 | 14.0 ⏎ fin\nvisible | — | 6\n```\n",
    );
    let cases = match cases {
        Some(RouteFence::Cases(cases)) => cases,
        _ => Vec::new(),
    };
    assert_eq!(cases.len(), 3);
    assert_eq!(cases.get(1).map(|case| case.inputs.len()), Some(3));
    assert_eq!(
        cases.get(1).and_then(|case| case.expected.clone()),
        Some("14.0\nfin".to_owned())
    );
    assert!(
        cases
            .get(2)
            .is_some_and(|case| case.inputs.is_empty() && !case.hidden)
    );
    let solution = fence("```casos-solucion minimo=2 maximo=4\n95 | 3\n```\n");
    assert!(matches!(
        solution,
        Some(RouteFence::SolutionCases {
            minimum: 2,
            maximum: 4,
            ..
        })
    ));
}

#[test]
fn rejects_malformed_exercise_fences() {
    let lesson = |body: &str| parse_lesson("leccion.md", &format!("{LESSON}{body}"));
    assert!(lesson("```casos\nquizas | 1 | 2\n```\n").is_err());
    assert!(lesson("```casos-solucion\n1 | 2\n```\n").is_err());
    assert!(lesson("```vueltas marca=3\nantes | 0\n```\n").is_err());
    assert!(
        lesson("```programa id=x sentencias=muchas\nAlgoritmo X\nFinAlgoritmo\n```\n").is_err()
    );
    assert!(lesson("```elementos\nsin categoría\n```\n").is_err());
    assert!(lesson("```desconocida\n```\n").is_err());
}

#[test]
fn reads_laps_choices_elements_steps_and_assertions() {
    let laps =
        fence("```vueltas marca=7 inicio=4 columnas=n,total\nantes | 0 | 0\n1 | ?1 | ?1\n```\n");
    assert!(
        matches!(laps, Some(RouteFence::Laps(table)) if table.mark == 7 && table.start == Some(4) && table.rows.len() == 2)
    );
    let choices = fence("```opciones\n- [x] Sí | porque sí\n- [ ] No | porque no\n```\n");
    assert!(
        matches!(choices, Some(RouteFence::Choices(choices)) if choices.iter().filter(|choice| choice.correct).count() == 1)
    );
    let elements = fence("```elementos\n- `23` | Entero\n- \"Ana\" | Cadena\n```\n");
    assert!(matches!(elements, Some(RouteFence::Elements(elements)) if elements.len() == 2));
    let steps = fence("```pasos\n- Leer.\n- Sumar.\n```\n");
    assert!(matches!(steps, Some(RouteFence::Steps(steps)) if steps.len() == 2));
    let assertions = fence("```aserciones\n- declara-subprograma | Area | 2 | Usa Area\n```\n");
    assert!(
        matches!(assertions, Some(RouteFence::Assertions(found)) if found.first().is_some_and(|assertion| assertion.kind == "declara-subprograma" && assertion.fields.len() == 2))
    );
    let figure = fence("```figura-especificacion seccion=control.si figura=si-ordinograma\n```\n");
    assert!(
        matches!(figure, Some(RouteFence::SpecFigure { section, figure }) if section == "control.si" && figure == "si-ordinograma")
    );
}

#[test]
fn reads_program_roles_and_statement_limits() {
    let parsed = parse_exercise(
        "ejercicio.md",
        "---\nid: a.b.c\nleccion: a.b\ntipo: romperlo\nnivel: brote\ntitulo: X\n---\n\n```programa rol=defectuoso sentencias=500\nAlgoritmo X\nFinAlgoritmo\n```\n",
    );
    let program = parsed.ok().and_then(|exercise| {
        exercise.blocks.into_iter().find_map(|block| match block {
            SourceBlock::Program(program) => Some(program),
            _ => None,
        })
    });
    assert!(program.is_some_and(|program| program.id == "defectuoso"
        && program.role.as_deref() == Some("defectuoso")
        && program.statement_limit == Some(500)
        && program.execute));
}

#[test]
fn rejects_unknown_header_fields_and_missing_front_matter() {
    assert!(parse_lesson("x.md", "sin cabecera").is_err());
    assert!(
        parse_lesson(
            "x.md",
            &LESSON.replace("duracion: 10", "duracion: 10\nextra: 1")
        )
        .is_err()
    );
    assert!(
        parse_exercise(
            "x.md",
            "---\nid: a\nleccion: b\ntipo: adivinar\nnivel: semilla\ntitulo: X\n---\n"
        )
        .is_err()
    );
}

#[test]
fn splits_summary_tags() {
    let (tags, text) = summary_tags(&[Inline::Text("{a,b} Texto".to_owned())]);
    assert_eq!(tags, vec!["a".to_owned(), "b".to_owned()]);
    assert_eq!(text, vec![Inline::Text("Texto".to_owned())]);
    let (none, same) = summary_tags(&[Inline::Text("Sin etiqueta".to_owned())]);
    assert!(none.is_empty());
    assert_eq!(same.len(), 1);
    assert_eq!(summary_tags(&[]).0, Vec::<String>::new());
}
