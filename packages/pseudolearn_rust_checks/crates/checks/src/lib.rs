#![forbid(unsafe_code)]

pub mod attributes;
pub mod comments;
pub mod declarative;
pub mod isolation;
pub mod layers;
pub mod limits;
pub mod names;
pub mod safety;
pub mod toolchain;

use pseudolearn_check_model::Violation;
use pseudolearn_check_source::loading::{load_sources, read_architecture};
use std::path::Path;

pub const COMMANDS: [&str; 7] = [
    "layers",
    "isolation",
    "comments",
    "names",
    "limits",
    "unsafe",
    "attributes",
];

pub fn verify(command: &str, root: &Path) -> Result<Vec<Violation>, String> {
    let rules = read_architecture(root)?;
    let mut violations = Vec::new();
    if command == "all" {
        for name in COMMANDS {
            violations.extend(verify(name, root)?);
        }
    } else if command == "layers" {
        violations.extend(layers::check(root, &rules)?);
    } else if command == "isolation" {
        violations.extend(isolation::check(root, &rules)?);
    } else {
        violations.extend(verify_sources(command, root, &rules)?);
    }
    violations.sort();
    violations.dedup();
    Ok(violations)
}

fn verify_sources(
    command: &str,
    root: &Path,
    rules: &pseudolearn_check_model::Architecture,
) -> Result<Vec<Violation>, String> {
    let sources = load_sources(root, rules)?;
    let mut violations = Vec::new();
    for source in &sources {
        let findings = match command {
            "comments" => comments::check(source),
            "attributes" => attributes::check(source),
            "names" => names::check(source, &rules.names),
            "limits" => limits::check(source, &rules.limits),
            "unsafe" => safety::check(source, rules, root)?,
            _ => return Err(format!("Unknown verifier: {command}")),
        };
        violations.extend(findings);
    }
    if command == "unsafe" {
        violations.extend(safety::check_orphan_rows(&sources, rules, root)?);
    }
    Ok(violations)
}
