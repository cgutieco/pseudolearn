use reference_model::{RuleId, SectionHeader, Violation};

pub fn split<'text>(
    path: &str,
    text: &'text str,
) -> Result<(SectionHeader, &'text str), Violation> {
    let failure = |detail: &str| Violation::new(RuleId::Format, path, detail);
    let rest = text
        .strip_prefix("---\n")
        .ok_or_else(|| failure("the document must start with a front matter block"))?;
    let closing = rest
        .find("\n---\n")
        .ok_or_else(|| failure("the front matter block is not closed"))?;
    let (yaml, body) = rest.split_at(closing);
    let body = body.get(5..).unwrap_or_default();
    let header: SectionHeader = serde_saphyr::from_str(yaml)
        .map_err(|error| failure(&format!("invalid front matter: {error}")))?;
    Ok((header, body))
}
