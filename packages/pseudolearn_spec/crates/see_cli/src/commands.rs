use crate::{arguments::Arguments, storage};
use see_model::Specification;
use serde_json::json;

pub fn run(arguments: Arguments) -> Result<String, String> {
    if arguments.command == "new" {
        return create(&arguments);
    }
    let corpus = storage::valid(&arguments.root)?;
    match arguments.command.as_str() {
        "validate" => Ok(format!("Validated {} specifications", corpus.len())),
        "graph" => see_graph::render(
            &corpus,
            arguments.options.get("focus").map(String::as_str),
            arguments.options.contains_key("dot"),
        ),
        "impact" => {
            see_graph::impact(&corpus, first(&arguments)?).map(|affected| affected.join("\n"))
        }
        "lock" => {
            let lock = see_change::locking::generate(&corpus, &storage::lock(&arguments.root)?)?;
            storage::artifact(
                &arguments.root.join("specifications/specifications.lock"),
                &json!(lock),
                arguments.options.contains_key("check"),
            )
        }
        "export" => storage::artifact(
            &arguments.root.join("specifications/export.json"),
            &see_export::generate(&corpus)?,
            arguments.options.contains_key("check"),
        ),
        "diff" => crate::history::diff(&arguments, &corpus),
        "conform" => crate::conformance::execute(&arguments, &corpus),
        "matrix" => crate::conformance::matrix(&arguments, &corpus),
        "feature" => feature(&arguments, &corpus),
        _ => Err(format!("Unknown command: {}", arguments.command)),
    }
}

pub fn first(arguments: &Arguments) -> Result<&str, String> {
    arguments
        .positional
        .first()
        .map(String::as_str)
        .ok_or("Missing specification, feature or revision".to_owned())
}

fn create(arguments: &Arguments) -> Result<String, String> {
    let id = first(arguments)?;
    if !see_validation::identity::valid_id(id) {
        return Err("SEE-IDENTITY: invalid identifier".to_owned());
    }
    let domain = domain(arguments, id)?;
    available(arguments, id)?;
    let metadata = crate::templates::metadata(id, domain);
    let path = arguments
        .root
        .join("specifications")
        .join(domain)
        .join(format!("{}.md", id.to_lowercase()));
    std::fs::create_dir_all(path.parent().ok_or("Invalid path")?)
        .map_err(|error| error.to_string())?;
    let text = see_format::write(&Specification {
        path: path.to_string_lossy().into_owned(),
        metadata,
        blocks: vec![],
    })?;
    use std::io::Write;
    let mut file = std::fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .open(&path)
        .map_err(|error| error.to_string())?;
    file.write_all(text.as_bytes())
        .map_err(|error| error.to_string())?;
    Ok(format!("Created {}", path.display()))
}

fn feature(arguments: &Arguments, corpus: &see_model::Corpus) -> Result<String, String> {
    let name = first(arguments)?;
    if !name
        .chars()
        .all(|character| character.is_ascii_alphanumeric() || character == '-')
    {
        return Err("Invalid feature name".to_owned());
    }
    let text = std::fs::read_to_string(
        arguments
            .root
            .join("specifications/features")
            .join(format!("{name}.yaml")),
    )
    .map_err(|error| error.to_string())?;
    let manifest = serde_saphyr::from_str(&text).map_err(|error| error.to_string())?;
    serde_json::to_string_pretty(&see_report::feature(corpus, &manifest)?)
        .map_err(|error| error.to_string())
}

fn available(arguments: &Arguments, id: &str) -> Result<(), String> {
    let existing = storage::corpus(&arguments.root)?;
    if existing
        .iter()
        .any(|specification| specification.metadata.id == id)
        || storage::lock(&arguments.root)?
            .specifications
            .contains_key(id)
    {
        return Err("SEE-DUPLICATE: identifier already exists".to_owned());
    }
    Ok(())
}

fn domain<'arguments>(
    arguments: &'arguments Arguments,
    id: &str,
) -> Result<&'arguments str, String> {
    let domain = arguments.options.get("domain").ok_or("Missing --domain")?;
    if ![
        "see", "lang", "diag", "lib", "eng", "mem", "ir", "rt", "api", "tool", "app", "perf",
    ]
    .contains(&domain.as_str())
    {
        return Err("Unknown domain".to_owned());
    }
    if id
        .split('.')
        .next()
        .is_none_or(|prefix| prefix.to_lowercase() != *domain)
    {
        return Err("SEE-IDENTITY: domain/namespace mismatch".to_owned());
    }
    Ok(domain)
}
