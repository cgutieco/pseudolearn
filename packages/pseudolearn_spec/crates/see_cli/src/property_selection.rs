use crate::arguments::Arguments;
use see_model::{Corpus, properties::PropertyBinding};

pub(crate) fn selected(
    arguments: &Arguments,
    corpus: &Corpus,
    entries: Vec<PropertyBinding>,
) -> Result<Vec<PropertyBinding>, String> {
    let subject = arguments
        .options
        .get("subject")
        .ok_or("Missing --subject")?;
    let mut selected = Vec::new();
    for mut binding in entries {
        let identity = binding
            .reference
            .split_once('@')
            .ok_or("SEE-PROPERTY: invalid reference")?
            .0;
        let eligible = corpus.iter().any(|specification| {
            specification.metadata.id == identity
                && specification.metadata.sujetos.contains(subject)
        });
        let only = arguments
            .options
            .get("only")
            .is_none_or(|only| only == identity);
        let property = arguments
            .options
            .get("property")
            .is_none_or(|property| property == &binding.reference);
        if eligible && only && property {
            binding.seed = number(arguments, "seed")?.unwrap_or(binding.seed);
            binding.samples = number(arguments, "samples")?.unwrap_or(binding.samples);
            selected.push(binding);
        }
    }
    if selected.is_empty() {
        return Err("SEE-PROPERTY: no properties selected".to_owned());
    }
    Ok(selected)
}

pub(crate) fn number<Number: std::str::FromStr>(
    arguments: &Arguments,
    name: &str,
) -> Result<Option<Number>, String> {
    arguments
        .options
        .get(name)
        .map(|value| {
            value
                .parse()
                .map_err(|_| format!("SEE-PROPERTY: invalid --{name}"))
        })
        .transpose()
}
