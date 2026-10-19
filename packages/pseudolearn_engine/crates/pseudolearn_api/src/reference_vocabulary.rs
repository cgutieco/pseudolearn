use crate::ApiError;
use pseudolearn_lexicon::{BuiltinKind, Profile, signature_for_builtin};
use serde_json::{Value, json};

const PRECEDENCE: &[(&[&str], bool)] = &[
    (&["plus", "minus", "not"], true),
    (&["power"], true),
    (&["multiply", "divide", "integerDivide", "modulo"], false),
    (&["plus", "minus"], false),
    (
        &[
            "lessThan",
            "lessThanOrEqual",
            "greaterThan",
            "greaterThanOrEqual",
        ],
        false,
    ),
    (&["equal", "notEqual"], false),
    (&["and"], false),
    (&["or"], false),
];

pub(crate) fn query(arguments: &Value) -> Result<Value, ApiError> {
    let profile_name = arguments
        .get("profile")
        .and_then(Value::as_str)
        .ok_or_else(|| usage("missing profile"))?;
    let profile = Profile::from_name(profile_name).ok_or_else(|| usage("invalid profile"))?;
    Ok(json!({
        "profile": profile.as_str(),
        "builtins": builtins(profile),
        "precedence": precedence(),
        "identifier_label": identifier_label(profile),
    }))
}

fn builtins(profile: Profile) -> Vec<Value> {
    BuiltinKind::all()
        .iter()
        .filter_map(|kind| {
            let signature = signature_for_builtin(*kind);
            Some(json!({
                "identity": kind.as_str(),
                "lexeme": kind.lexeme(profile)?,
                "parameters": signature.parameter_types,
                "returns": signature.return_type,
            }))
        })
        .collect()
}

fn identifier_label(profile: Profile) -> &'static str {
    match profile {
        Profile::Spanish => "identificador",
        Profile::English => "identifier",
    }
}

fn precedence() -> Vec<Value> {
    PRECEDENCE
        .iter()
        .enumerate()
        .map(|(index, (operators, right_associative))| {
            json!({
                "level": index.saturating_add(1),
                "operators": operators,
                "right_associative": right_associative,
            })
        })
        .collect()
}

fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}
