use std::collections::BTreeMap;
use std::path::PathBuf;

pub struct Arguments {
    pub command: String,
    pub positional: Vec<String>,
    pub options: BTreeMap<String, String>,
    pub root: PathBuf,
}

pub fn parse(arguments: Vec<String>) -> Result<Arguments, String> {
    let mut words = arguments.into_iter();
    let command = words
        .next()
        .ok_or("Usage: see <new|validate|graph|lock|diff|impact|conform|matrix|feature|export>")?;
    let mut options = BTreeMap::new();
    let mut positional = Vec::new();
    while let Some(word) = words.next() {
        if let Some(name) = word.strip_prefix("--") {
            if !["root", "domain", "focus", "subject", "only", "check", "dot"].contains(&name) {
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
