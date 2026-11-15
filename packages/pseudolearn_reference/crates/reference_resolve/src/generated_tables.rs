use crate::Resolution;
use crate::runs::plain;
use crate::spelling::canonical_spelling;
use reference_model::{Block, Run, TableBlock, Token, TokenCategory};

pub fn code_run(text: &str, category: Option<TokenCategory>) -> Run {
    Run::Code {
        tokens: vec![Token {
            text: text.to_owned(),
            category,
        }],
    }
}

pub fn table(resolution: &Resolution<'_>, header: &[&str], rows: Vec<Vec<Vec<Run>>>) -> Block {
    Block::Table(TableBlock {
        header: header
            .iter()
            .map(|key| plain(resolution.pack.phrase(key)))
            .collect(),
        rows,
    })
}

pub fn message_runs(message: &str) -> Vec<Run> {
    let mut runs = Vec::new();
    let mut rest = message;
    while let Some((before, after)) = rest.split_once('{') {
        let Some((name, remaining)) = after.split_once('}') else {
            break;
        };
        if !before.is_empty() {
            runs.push(Run::Text {
                text: before.to_owned(),
            });
        }
        runs.push(Run::Slot {
            text: name.to_owned(),
        });
        rest = remaining;
    }
    if !rest.is_empty() {
        runs.push(Run::Text {
            text: rest.to_owned(),
        });
    }
    runs
}

pub fn grammar(resolution: &Resolution<'_>) -> Block {
    let rows = resolution
        .corpus
        .productions
        .iter()
        .map(|(name, rule)| {
            vec![
                vec![Run::Slot {
                    text: label(resolution, name),
                }],
                rule_runs(resolution, rule),
            ]
        })
        .collect();
    table(resolution, &["table.production", "table.rule"], rows)
}

fn label(resolution: &Resolution<'_>, name: &str) -> String {
    resolution
        .pack
        .productions
        .get(name)
        .cloned()
        .unwrap_or_else(|| name.to_owned())
}

fn rule_runs(resolution: &Resolution<'_>, rule: &str) -> Vec<Run> {
    let mut runs = Vec::new();
    let mut word = String::new();
    for character in rule.chars().chain(std::iter::once(' ')) {
        if character.is_alphanumeric() || character == '@' {
            word.push(character);
            continue;
        }
        if !word.is_empty() {
            runs.push(symbol_run(resolution, &std::mem::take(&mut word)));
        }
        if character != ' ' && character != ',' {
            runs.push(Run::Text {
                text: format!(" {character} "),
            });
        }
    }
    runs
}

fn symbol_run(resolution: &Resolution<'_>, symbol: &str) -> Run {
    match symbol.strip_prefix('@') {
        Some(identity) => {
            let lexeme = resolution
                .corpus
                .lexicon
                .lexeme(identity, resolution.profile)
                .map_or_else(
                    || identity.to_owned(),
                    |lexeme| canonical_spelling(lexeme, resolution.profile),
                );
            code_run(&lexeme, resolution.categories.category(identity))
        }
        None => Run::Slot {
            text: label(resolution, symbol),
        },
    }
}
