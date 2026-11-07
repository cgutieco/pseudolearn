mod support;

use reference_model::{Block, CodeEngine, Profile, RuleId, Run, Token, TokenCategory};
use reference_resolve::{Resolution, ResolvedSection, SpanishReuse, resolve_section};

fn resolve(body: &str, profile: Profile, reuse: &SpanishReuse) -> ResolvedSection {
    let engine = support::FakeEngine::default();
    resolve_with(&engine, body, (Profile::Spanish, profile), reuse)
}

fn resolve_with(
    engine: &dyn CodeEngine,
    body: &str,
    (language, profile): (Profile, Profile),
    reuse: &SpanishReuse,
) -> ResolvedSection {
    let corpus = support::corpus();
    let categories = support::categories();
    let aliases = support::aliases();
    let pack = support::pack();
    let figures = support::figures();
    let index = support::index();
    let resolution = Resolution {
        engine,
        corpus: &corpus,
        categories: &categories,
        aliases: &aliases,
        pack: &pack,
        figures: &figures,
        index: &index,
        language,
        profile,
    };
    resolve_section(&resolution, &support::document(body), reuse)
}

fn code(runs: &[Run]) -> Vec<Token> {
    runs.iter()
        .flat_map(|run| match run {
            Run::Code { tokens } => tokens.clone(),
            _ => Vec::new(),
        })
        .collect()
}

#[test]
fn translates_inline_code_to_the_target_profile() {
    let resolved = resolve(
        "Usa `Si x Entonces` y `v.Agregar(1)` con `Longitud(t)`.\n",
        Profile::English,
        &SpanishReuse::default(),
    );
    let candidate = resolved.section.blocks.first();
    assert!(matches!(candidate, Some(Block::Paragraph { .. })));
    let Some(Block::Paragraph { runs }) = candidate else {
        return;
    };
    let texts: Vec<String> = code(runs).iter().map(|token| token.text.clone()).collect();
    assert_eq!(texts.join(""), "If x Thenv.append(1)length(t)");
    assert_eq!(
        code(runs).first().and_then(|token| token.category),
        Some(TokenCategory::KeywordStructured)
    );
    assert_eq!(
        code(&resolved.section.title)
            .first()
            .map(|token| token.text.clone()),
        Some("If".to_owned())
    );
}

#[test]
fn numbers_headings_and_extracts_the_phrase() {
    let resolved = resolve(
        "::: frase\nUna frase.\n:::\n\n## Uno {#uno}\n\n## Dos {#dos}\n",
        Profile::Spanish,
        &SpanishReuse::default(),
    );
    let numbers: Vec<String> = resolved
        .section
        .blocks
        .iter()
        .filter_map(|block| match block {
            Block::Heading { number, .. } => Some(number.clone()),
            _ => None,
        })
        .collect();
    assert_eq!(numbers, vec!["6.1.1".to_owned(), "6.1.2".to_owned()]);
    assert_eq!(
        resolved.section.phrase,
        vec![Run::Text {
            text: "Una frase.".to_owned()
        }]
    );
}

#[test]
fn runs_programs_and_records_the_promise() {
    let engine = support::FakeEngine::default();
    let body =
        "```programa id=uno titulo=\"Uno\" ejecutar\nEscribir 1;\n```\n\n```salida\n1\n```\n";
    let resolved = resolve_with(
        &engine,
        body,
        (Profile::Spanish, Profile::English),
        &SpanishReuse::default(),
    );
    assert_eq!(resolved.examples.len(), 1);
    assert_eq!(engine.executions.get(), 2);
    let candidate = resolved.section.blocks.first();
    assert!(matches!(candidate, Some(Block::Program(_))));
    let Some(Block::Program(program)) = candidate else {
        return;
    };
    assert_eq!(program.source, "Write 1;\n");
    assert_eq!(program.output, "1\n");
}

#[test]
fn reuses_the_spanish_program_and_falls_back_to_lexical_translation() {
    let mut reuse = SpanishReuse::default();
    let spanish = resolve(
        "```programa id=roto titulo=\"Roto\" ejecutar\nSi roto\n```\n",
        Profile::Spanish,
        &SpanishReuse::default(),
    );
    if let Some(Block::Program(program)) = spanish.section.blocks.first() {
        assert_eq!(
            program
                .diagnostics
                .first()
                .map(|diagnostic| diagnostic.message.clone()),
            Some("Desbordamiento".to_owned())
        );
    }
    reuse.programs.insert(
        "roto".to_owned(),
        reference_model::ProgramSource {
            id: "roto".to_owned(),
            title: "Roto".to_owned(),
            execute: true,
            code: "Si roto".to_owned(),
            ..Default::default()
        },
    );
    let english = resolve(
        "```programa id=roto titulo=\"Broken\"\n```\n",
        Profile::English,
        &reuse,
    );
    let candidate = english.section.blocks.first();
    assert!(matches!(candidate, Some(Block::Program(_))));
    let Some(Block::Program(program)) = candidate else {
        return;
    };
    assert_eq!(program.title, "Broken");
    assert_eq!(program.source, "If roto\n");
}

#[test]
fn reports_a_program_without_spanish_source() {
    let resolved = resolve(
        "```programa id=nada\n```\n",
        Profile::English,
        &SpanishReuse::default(),
    );
    assert_eq!(
        resolved.violations.first().map(|violation| violation.rule),
        Some(RuleId::Format)
    );
}

#[test]
fn resolves_figures_with_layers_and_steps() {
    let body = "```figura id=caja\npie: Una caja.\npaso: Primero.\npaso: Segundo.\npanel Memoria 2: `x`\n```\n";
    let resolved = resolve(body, Profile::English, &SpanishReuse::default());
    let candidate = resolved.section.blocks.first();
    assert!(matches!(candidate, Some(Block::Figure { .. })));
    let Some(Block::Figure {
        number,
        svg,
        layers,
        steps,
        panels,
        ..
    }) = candidate
    else {
        return;
    };
    assert_eq!(number, "6.1-1");
    assert!(svg.contains("edad If"));
    assert_eq!((layers.len(), steps.len(), panels.len()), (1, 2, 1));
}

#[test]
fn reports_a_missing_figure_and_an_unknown_link() {
    let resolved = resolve(
        "```figura id=nada\npie: x\n```\n\n::: vease\n- [Otra](#otra)\n- [Esta](#prueba)\n:::\n",
        Profile::Spanish,
        &SpanishReuse::default(),
    );
    let rules: Vec<RuleId> = resolved
        .violations
        .iter()
        .map(|violation| violation.rule)
        .collect();
    assert_eq!(rules, vec![RuleId::FigureContract, RuleId::LinkValid]);
    assert!(
        matches!(resolved.section.blocks.last(), Some(Block::SeeAlso { links }) if links.len() == 1)
    );
}

#[test]
fn draws_rails_and_reports_unknown_productions() {
    let resolved = resolve(
        "```railes produccion=conditional\n```\n\n```railes produccion=nada\n```\n",
        Profile::English,
        &SpanishReuse::default(),
    );
    assert!(
        matches!(resolved.section.blocks.first(), Some(Block::Rails { svg, alt }) if svg.contains(">If<") && alt == "Raíles: decisión")
    );
    assert_eq!(resolved.violations.len(), 1);
}

#[test]
fn lowers_and_traces_known_programs() {
    let body = "```programa id=uno\nEscribir 1;\n```\n\n```ri programa=uno\n```\n\n```traza programa=uno\n```\n\n```ri programa=otro\n```\n";
    let resolved = resolve(body, Profile::Spanish, &SpanishReuse::default());
    assert!(
        matches!(resolved.section.blocks.get(1), Some(Block::Intermediate { lines, .. }) if lines.len() == 2)
    );
    let candidate = resolved.section.blocks.get(2);
    assert!(matches!(candidate, Some(Block::Trace { .. })));
    let Some(Block::Trace { events, .. }) = candidate else {
        return;
    };
    let details: Vec<String> = events.iter().map(|event| event.detail.clone()).collect();
    assert_eq!(details, vec!["entra".to_owned(), "escribe · 1".to_owned()]);
    assert_eq!(resolved.violations.len(), 1);
}

#[test]
fn builds_forms_with_slots_and_optional_marks() {
    let resolved = resolve(
        "```forma\nSi «condición» ⟦Entonces⟧\n```\n",
        Profile::English,
        &SpanishReuse::default(),
    );
    let candidate = resolved.section.blocks.first();
    assert!(matches!(candidate, Some(Block::Form { .. })));
    let Some(Block::Form { lines }) = candidate else {
        return;
    };
    let kinds: Vec<String> = lines
        .iter()
        .flatten()
        .map(|segment| {
            format!("{segment:?}")
                .split_whitespace()
                .next()
                .unwrap_or_default()
                .to_owned()
        })
        .collect();
    assert_eq!(kinds.len(), 7);
}

#[test]
fn generates_catalogs_and_rejects_unknown_ones() {
    let resolved = resolve(
        "```generado catalogo=palabras\n```\n\n```generado catalogo=diagnosticos\n```\n\n```generado catalogo=indice\n```\n\n```generado catalogo=nada\n```\n",
        Profile::Spanish,
        &SpanishReuse::default(),
    );
    assert!(
        matches!(resolved.section.blocks.first(), Some(Block::Table(table)) if table.rows.len() == 6)
    );
    assert!(
        matches!(resolved.section.blocks.get(1), Some(Block::Table(table)) if table.rows.len() == 1)
    );
    assert!(
        matches!(resolved.section.blocks.get(2), Some(Block::List { entries, .. }) if entries.len() == 2)
    );
    assert_eq!(resolved.violations.len(), 1);
}

#[test]
fn keeps_alias_spellings_in_inline_code_and_programs() {
    let resolved = resolve(
        "Una `Funcion` no es un `SubProceso`.\n\n```programa id=pura\nFuncion f\nEscribir 1;\n```\n",
        Profile::English,
        &SpanishReuse::default(),
    );
    let Some(Block::Paragraph { runs }) = resolved.section.blocks.first() else {
        return;
    };
    let texts: Vec<String> = code(runs).iter().map(|token| token.text.clone()).collect();
    assert_eq!(texts, vec!["Function".to_owned(), "Subroutine".to_owned()]);
    assert!(
        matches!(resolved.section.blocks.get(1), Some(Block::Program(program)) if program.source == "Function f\nWrite 1;\n")
    );
}
