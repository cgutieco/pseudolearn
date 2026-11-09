use crate::inline_parser::parse_inline;
use reference_model::AnatomySource;

pub fn parse(body: &str) -> Result<Vec<AnatomySource>, String> {
    let parts = body
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .map(part)
        .collect::<Result<Vec<_>, String>>()?;
    if parts.len() < 2 {
        return Err("an anatomy needs at least two parts".to_owned());
    }
    Ok(parts)
}

fn part(line: &str) -> Result<AnatomySource, String> {
    let Some((code, label)) = line.split_once('|') else {
        return Err(format!("the anatomy part `{line}` needs `code | label`"));
    };
    let (code, label) = (code.trim(), label.trim());
    if code.is_empty() || label.is_empty() {
        return Err(format!("the anatomy part `{line}` needs code and a label"));
    }
    Ok(AnatomySource {
        code: code.to_owned(),
        label: parse_inline(label)?,
    })
}
