use reference_model::{RuleId, Violation};
use serde::de::DeserializeOwned;

pub fn split<'text, Header: DeserializeOwned>(
    path: &str,
    text: &'text str,
    rule: RuleId,
) -> Result<(Header, &'text str), Violation> {
    let failure = |detail: &str| Violation::new(rule, path, detail);
    let rest = text
        .strip_prefix("---\n")
        .ok_or_else(|| failure("the document must start with a front matter block"))?;
    let closing = rest
        .find("\n---\n")
        .ok_or_else(|| failure("the front matter block is not closed"))?;
    let (yaml, body) = rest.split_at(closing);
    let body = body.get(5..).unwrap_or_default();
    let header: Header = serde_saphyr::from_str(yaml)
        .map_err(|error| failure(&format!("invalid front matter: {error}")))?;
    Ok((header, body))
}
