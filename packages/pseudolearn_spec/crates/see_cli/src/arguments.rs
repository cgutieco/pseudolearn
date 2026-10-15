use std::collections::BTreeMap;
use std::path::PathBuf;

pub struct Arguments {
    pub command: String,
    pub positional: Vec<String>,
    pub options: BTreeMap<String, String>,
    pub root: PathBuf,
}

const ALLOWED_OPTIONS: &[&str] = &[
    "root",
    "domain",
    "focus",
    "subject",
    "only",
    "check",
    "dot",
    "operation",
    "property",
    "seed",
    "samples",
    "sample",
    "output",
    "input",
    "count",
];

fn parse_option(
    name: &str,
    words: &mut impl Iterator<Item = String>,
    options: &mut BTreeMap<String, String>,
) -> Result<(), String> {
    if !ALLOWED_OPTIONS.contains(&name) {
        return Err(format!("Unknown option --{name}"));
    }
    let value = if ["check", "dot"].contains(&name) {
        "true".to_owned()
    } else {
        words.next().ok_or(format!("Missing value for --{name}"))?
    };
    if options.insert(name.to_owned(), value).is_some() {
        return Err(format!("Duplicate option --{name}"));
    }
    Ok(())
}

pub fn parse(arguments: Vec<String>) -> Result<Arguments, String> {
    let mut words = arguments.into_iter();
    let command = words
        .next()
        .ok_or("Usage: see <new|validate|graph|lock|diff|impact|conform|matrix|feature|export|math-arguments|math-check>")?;
    let mut options = BTreeMap::new();
    let mut positional = Vec::new();
    while let Some(word) = words.next() {
        if let Some(name) = word.strip_prefix("--") {
            parse_option(name, &mut words, &mut options)?;
        } else {
            positional.push(word);
        }
    }
    let root = PathBuf::from(options.get("root").map_or(".", String::as_str));
    Ok(Arguments {
        command,
        positional,
        options,
        root,
    })
}
