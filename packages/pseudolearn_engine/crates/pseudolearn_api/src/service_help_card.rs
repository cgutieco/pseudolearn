use crate::model::{ApiHelpCard, ApiHelpDetail, ApiHelpExample, ApiHelpPart};
use crate::service::HelpContent;

pub(crate) fn card(content: &HelpContent, detail: ApiHelpDetail) -> ApiHelpCard {
    let complete = detail == ApiHelpDetail::Full;
    ApiHelpCard {
        id: content.card_id.to_owned(),
        title: content.title.to_owned(),
        summary: content.summary.to_owned(),
        purpose: complete.then(|| content.purpose.to_owned()),
        parts: complete.then(|| parts(content)),
        constraints: complete.then(|| owned(content.constraints)),
        common_errors: complete.then(|| owned(content.common_errors)),
        examples: complete.then(|| examples(content)),
    }
}

fn owned(lines: &[&str]) -> Vec<String> {
    lines.iter().map(|line| (*line).to_owned()).collect()
}

fn parts(content: &HelpContent) -> Vec<ApiHelpPart> {
    content
        .parts
        .iter()
        .map(|part| ApiHelpPart {
            identity: part.identity.to_owned(),
            text: part.text.to_owned(),
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
            profile: example.profile.to_owned(),
            strictness: example.strictness.to_owned(),
            kind: example.kind.to_owned(),
            label: example.label.to_owned(),
        })
        .collect()
}
