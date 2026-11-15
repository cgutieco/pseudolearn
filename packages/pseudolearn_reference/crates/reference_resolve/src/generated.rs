use crate::Resolution;
use crate::generated_tables::{code_run, message_runs, table};
use crate::resolution::Collector;
use crate::runs::plain;
use crate::spelling::canonical_spelling;
use reference_corpus::{DiagnosticEntry, LexemeFamily, fold};
use reference_model::{Block, Profile, RuleId, Run, TokenCategory};

pub fn catalog_blocks(
    resolution: &Resolution<'_>,
    collector: &mut Collector<'_>,
    catalog: &str,
) -> Vec<Block> {
    match catalog {
        "palabras" => vec![words(resolution)],
        "diagnosticos" => vec![diagnostics(resolution)],
        "funciones" => vec![functions(resolution)],
        "gramatica" => vec![crate::generated_tables::grammar(resolution)],
        "indice" => vec![index(resolution)],
        other => {
            collector.report(
                RuleId::Format,
                format!("unknown generated catalog `{other}`"),
            );
            Vec::new()
        }
    }
}

fn words(resolution: &Resolution<'_>) -> Block {
    let mut entries: Vec<_> = resolution
        .corpus
        .lexicon
        .entries()
        .filter(|entry| {
            matches!(
                entry.family,
                LexemeFamily::Reserved | LexemeFamily::Contextual
            )
        })
        .collect();
    entries.sort_by_key(|entry| fold(&entry.spanish));
    let rows = entries
        .iter()
        .map(|entry| {
            let category = resolution.categories.category(&entry.identity);
            vec![
                vec![code_run(&entry.spanish, category)],
                vec![code_run(
                    &canonical_spelling(&entry.english, Profile::English),
                    category,
                )],
                plain(category_label(resolution, category)),
            ]
        })
        .collect();
    table(
        resolution,
        &["table.spanish", "table.english", "table.category"],
        rows,
    )
}

fn category_label(resolution: &Resolution<'_>, category: Option<TokenCategory>) -> String {
    let key = category
        .and_then(|category| serde_json::to_value(category).ok())
        .and_then(|value| value.as_str().map(str::to_owned))
        .unwrap_or_else(|| "identifier".to_owned());
    resolution.pack.phrase(&format!("category.{key}"))
}

fn diagnostics(resolution: &Resolution<'_>) -> Block {
    let rows = resolution
        .corpus
        .diagnostics
        .values()
        .map(|entry| diagnostic_row(resolution, entry))
        .collect();
    table(
        resolution,
        &[
            "table.code",
            "table.severity",
            "table.class",
            "table.message",
            "table.section",
        ],
        rows,
    )
}

fn diagnostic_row(resolution: &Resolution<'_>, entry: &DiagnosticEntry) -> Vec<Vec<Run>> {
    let message = match resolution.language {
        Profile::Spanish => &entry.spanish,
        Profile::English => &entry.english,
    };
    let section = resolution
        .index
        .section_for_diagnostic(&entry.code)
        .map(|(identity, section)| Run::Link {
            section: identity.clone(),
            text: section.number.clone(),
        })
        .map_or_else(Vec::new, |link| vec![link]);
    vec![
        vec![code_run(&entry.code, None)],
        plain(
            resolution
                .pack
                .phrase(&format!("severity.{}", entry.severity)),
        ),
        plain(resolution.pack.phrase(&format!("class.{}", entry.class))),
        message_runs(message),
        section,
    ]
}

fn functions(resolution: &Resolution<'_>) -> Block {
    let mut functions = resolution.corpus.functions.clone();
    functions.sort_by_key(|function| (function.family.clone(), fold(&function.spanish)));
    let rows = functions
        .iter()
        .map(|function| {
            vec![
                plain(
                    resolution
                        .pack
                        .phrase(&format!("family.{}", function.family)),
                ),
                vec![code_run(&function.spanish, Some(TokenCategory::Identifier))],
                vec![code_run(&function.english, Some(TokenCategory::Identifier))],
                plain(function.parameters.join(", ")),
                plain(function.result.clone()),
            ]
        })
        .collect();
    table(
        resolution,
        &[
            "table.family",
            "table.spanish",
            "table.english",
            "table.parameters",
            "table.result",
        ],
        rows,
    )
}

fn index(resolution: &Resolution<'_>) -> Block {
    let mut entries: Vec<(String, String, String)> = Vec::new();
    for (identity, section) in &resolution.index.sections {
        entries.push((
            section.title.clone(),
            identity.clone(),
            section.number.clone(),
        ));
        for term in &section.terms {
            entries.push((term.clone(), identity.clone(), section.number.clone()));
        }
    }
    entries.sort_by_key(|(text, _, number)| (fold(text), number.clone()));
    entries.dedup();
    Block::List {
        ordered: false,
        entries: entries
            .into_iter()
            .map(|(text, section, number)| {
                vec![
                    Run::Text {
                        text: format!("{text} — "),
                    },
                    Run::Link {
                        section,
                        text: number,
                    },
                ]
            })
            .collect(),
    }
}
