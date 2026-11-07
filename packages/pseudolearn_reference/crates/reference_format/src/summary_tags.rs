use reference_model::Inline;

pub fn summary_tags(entry: &[Inline]) -> (Vec<String>, Vec<Inline>) {
    let Some((Inline::Text(first), rest)) = entry.split_first() else {
        return (Vec::new(), entry.to_vec());
    };
    let Some((tags, after)) = first
        .strip_prefix('{')
        .and_then(|tail| tail.split_once('}'))
    else {
        return (Vec::new(), entry.to_vec());
    };
    let terms = tags.split(',').map(|tag| tag.trim().to_owned()).collect();
    let mut text = Vec::new();
    let after = after.trim_start();
    if !after.is_empty() {
        text.push(Inline::Text(after.to_owned()));
    }
    text.extend(rest.iter().cloned());
    (terms, text)
}
