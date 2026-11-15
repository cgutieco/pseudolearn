use crate::model::{
    ApiHelpCard, ApiHelpCommonError, ApiHelpDetail, ApiHelpExample, ApiHelpFormLine,
    ApiHelpFormSegment, ApiHelpPart, ApiHelpProgram,
};
use crate::service::HelpContent;
use pseudolearn_lexicon::Profile;
use pseudolearn_service::help_form::{ELLIPSIS, PartEntry, entry_text, part_entries};
use pseudolearn_service::{ExampleProgram, FormLine, FormSegment, HelpSlot};

pub(crate) fn card(content: &HelpContent, detail: ApiHelpDetail) -> ApiHelpCard {
    let complete = detail == ApiHelpDetail::Full;
    ApiHelpCard {
        id: content.card_id.to_owned(),
        title: content.title.to_owned(),
        summary: content.summary.to_owned(),
        category: complete.then(|| content.category.code().to_owned()),
        form: complete.then(|| form(content.form, content.slots)),
        parts: complete.then(|| parts(content)),
        result: if complete {
            content.result.map(str::to_owned)
        } else {
            None
        },
        rules: complete.then(|| {
            content
                .rules
                .iter()
                .map(|rule| (*rule).to_owned())
                .collect()
        }),
        common_errors: complete.then(|| common_errors(content)),
        examples: complete.then(|| examples(content)),
    }
}

fn form(lines: &[FormLine], slots: &[HelpSlot]) -> Vec<ApiHelpFormLine> {
    lines
        .iter()
        .map(|line| ApiHelpFormLine {
            indent: line.indent,
            segments: line
                .pieces
                .iter()
                .map(|piece| segment(piece.segment, piece.joined, slots))
                .collect(),
        })
        .collect()
}

fn segment(value: FormSegment, joined: bool, slots: &[HelpSlot]) -> ApiHelpFormSegment {
    let (kind, text, slot) = match value {
        FormSegment::Code { text, .. } => (code_kind(text), text.to_owned(), None),
        FormSegment::Slot(identity) => (
            "slot",
            slots
                .iter()
                .find(|slot| slot.id == identity)
                .map_or(identity, |slot| slot.label)
                .to_owned(),
            Some(identity.to_owned()),
        ),
        FormSegment::Ellipsis => ("ellipsis", ELLIPSIS.to_owned(), None),
    };
    ApiHelpFormSegment {
        kind: kind.to_owned(),
        text,
        slot,
        joined,
    }
}

fn code_kind(text: &str) -> &'static str {
    if text.chars().next().is_some_and(char::is_alphabetic) {
        "word"
    } else {
        "symbol"
    }
}

fn parts(content: &HelpContent) -> Vec<ApiHelpPart> {
    part_entries(content.form, content.parts, content.slots)
        .into_iter()
        .map(|entry| {
            let (kind, identity, name) = match entry {
                PartEntry::Word(part) => ("word", part.identity, part.lexeme(content.profile)),
                PartEntry::Slot(slot) => ("slot", slot.id, slot.label),
            };
            ApiHelpPart {
                kind: kind.to_owned(),
                identity: identity.to_owned(),
                name: name.to_owned(),
                text: entry_text(entry).to_owned(),
            }
        })
        .collect()
}

fn common_errors(content: &HelpContent) -> Vec<ApiHelpCommonError> {
    content
        .common_errors
        .iter()
        .map(|error| ApiHelpCommonError {
            text: error.text.to_owned(),
            program: error
                .program
                .map(|program| api_program(&program, content.profile)),
        })
        .collect()
}

fn examples(content: &HelpContent) -> Vec<ApiHelpExample> {
    content
        .examples
        .iter()
        .map(|example| ApiHelpExample {
            specification: example.specification.to_owned(),
            version: example.version.to_owned(),
            case: example.case.to_owned(),
            kind: example.kind.to_owned(),
            note: example.note.to_owned(),
            program: api_program(&example.program, content.profile),
        })
        .collect()
}

fn api_program(program: &ExampleProgram, profile: Profile) -> ApiHelpProgram {
    ApiHelpProgram {
        source: program.source(profile).to_owned(),
        output: program.output.map(str::to_owned),
    }
}
