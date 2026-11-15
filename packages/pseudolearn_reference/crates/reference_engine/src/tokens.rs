use crate::offsets::LineStarts;
use pseudolearn_api::{AnalyzeRequest, execute_analyze};
use reference_model::{Profile, RawToken};

pub fn tokenize(code: &str, profile: Profile) -> Vec<RawToken> {
    let response = execute_analyze(&AnalyzeRequest {
        program: code.to_owned(),
        profile: profile.code().to_owned(),
        source: None,
    });
    let starts = LineStarts::new(code);
    response
        .tokens
        .into_iter()
        .map(|token| RawToken {
            start: starts.offset(token.span.start.line, token.span.start.column),
            end: starts.offset(token.span.end.line, token.span.end.column),
            kind: token.kind,
            keyword: token.keyword,
        })
        .filter(|token| token.end > token.start)
        .collect()
}
