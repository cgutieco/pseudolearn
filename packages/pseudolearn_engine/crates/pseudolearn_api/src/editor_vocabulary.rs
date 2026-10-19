use crate::ApiError;
use pseudolearn_lexicon::{KeywordKind, Profile};
use serde_json::{Value, json};

const BLOCK_OPENERS: &[&str] = &[
    "algorithm",
    "ifKeyword",
    "elseKeyword",
    "switchKeyword",
    "whileKeyword",
    "repeat",
    "forKeyword",
    "subroutine",
    "classKeyword",
    "method",
];

pub(crate) fn query(arguments: &Value) -> Result<Value, ApiError> {
    let profile_name = arguments
        .get("profile")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing profile"))?;
    let profile = Profile::from_name(profile_name).ok_or_else(|| usage("invalid profile"))?;
    let keywords = KeywordKind::all()
        .iter()
        .filter_map(|kind| kind.lexeme(profile).map(|lexeme| (kind.as_str(), lexeme)))
        .collect::<Vec<_>>();
    let openers = BLOCK_OPENERS
        .iter()
        .filter_map(|identity| {
            KeywordKind::all()
                .iter()
                .find(|kind| kind.as_str() == *identity)
                .and_then(|kind| kind.lexeme(profile))
        })
        .collect::<Vec<_>>();
    Ok(json!({
        "profile": profile.as_str(),
        "keywords": keywords,
        "block_openers": openers,
        "symbols": {
            "assignment": "<-",
            "quote": "\"",
            "left_parenthesis": "(",
            "right_parenthesis": ")",
            "greater_equal": ">=",
            "less_equal": "<="
        }
    }))
}

fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}
