use crate::service::help_campaign::expectation::{Expectation, Query};
use crate::service::help_campaign::oracle::Oracle;
use crate::service::help_campaign::transports::{Answer, LspTransport, Range, escape_markdown};

pub struct Context<'context> {
    pub language: &'context str,
    pub partial: bool,
}

pub fn judge_api(
    oracle: &Oracle,
    answer: &Answer,
    query: &Query,
    context: &Context<'_>,
) -> Result<(), String> {
    match &query.expectation {
        Expectation::Absent => (!answer.has_resolution)
            .then_some(())
            .ok_or_else(|| "help found where none is valid".to_owned()),
        Expectation::UserSymbol(occurrence) => (answer.has_resolution && answer.has_symbol)
            .then_some(())
            .ok_or_else(|| format!("{} was not resolved as the user symbol", occurrence.word)),
        Expectation::Keyword(occurrence) => judge_keyword(oracle, answer, occurrence, context),
    }
}

fn judge_keyword(
    oracle: &Oracle,
    answer: &Answer,
    occurrence: &crate::service::help_campaign::scanner::Occurrence,
    context: &Context<'_>,
) -> Result<(), String> {
    if !answer.has_resolution {
        return Err(format!("no resolution for {}", occurrence.word));
    }
    let wanted = if context.partial {
        "partial"
    } else {
        "certain"
    };
    if answer.certainty != wanted {
        return Err(format!(
            "certainty {} instead of {wanted}",
            answer.certainty
        ));
    }
    if answer.has_symbol {
        return Err(format!("{} resolved as a user symbol", occurrence.word));
    }
    let cards = oracle.cards_for(&occurrence.identity);
    let expected = cards
        .iter()
        .find(|card| Some(&card.card_id) == answer.card_id.as_ref())
        .ok_or_else(|| {
            format!(
                "card {:?} does not declare {}",
                answer.card_id, occurrence.identity
            )
        })?;
    let title = expected.titles.get(context.language);
    (title == answer.title.as_ref())
        .then_some(())
        .ok_or_else(|| format!("title {:?} instead of {title:?}", answer.title))
}

pub fn judge_lsp(
    oracle: &Oracle,
    text: Option<&String>,
    query: &Query,
    language: &str,
) -> Result<(), String> {
    match &query.expectation {
        Expectation::Absent => text
            .is_none()
            .then_some(())
            .ok_or_else(|| "hover shown where none is valid".to_owned()),
        Expectation::UserSymbol(occurrence) => text
            .is_some_and(|shown| shown.contains(&occurrence.word))
            .then_some(())
            .ok_or_else(|| format!("no symbol hover for {}", occurrence.word)),
        Expectation::Keyword(occurrence) => {
            let text = text.ok_or_else(|| format!("no hover for {}", occurrence.word))?;
            let found = oracle.cards_for(&occurrence.identity).iter().any(|card| {
                card.titles
                    .get(language)
                    .is_some_and(|title| text.contains(&escape_markdown(title)))
            });
            found
                .then_some(())
                .ok_or_else(|| format!("hover lacks a card of {}", occurrence.identity))
        }
    }
}

pub fn same_range(lsp: &LspTransport, api: &Answer, shown: &Range) -> bool {
    let Some(expected) = &api.range else {
        return false;
    };
    let convert = |line: u64, column: u64| {
        let line = u32::try_from(line).unwrap_or(0);
        let column = u32::try_from(column).unwrap_or(0);
        (
            u64::from(line.saturating_sub(1)),
            lsp.utf16_character(line, column),
        )
    };
    let (start_line, start_character) = convert(expected.start_line, expected.start_column);
    let (end_line, end_character) = convert(expected.end_line, expected.end_column);
    start_line == shown.start_line
        && start_character == shown.start_column
        && end_line == shown.end_line
        && end_character == shown.end_column
}
