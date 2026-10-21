#![forbid(unsafe_code)]

use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Architecture {
    pub package: String,
    #[serde(default)]
    pub declarative: bool,
    #[serde(default)]
    pub unsafe_allowed: Vec<String>,
    #[serde(default)]
    pub generated_sources: Vec<String>,
    #[serde(default)]
    pub deterministic_output_crates: Vec<String>,
    #[serde(default)]
    pub isolation: Vec<Isolation>,
    pub layers: Vec<Layer>,
    pub limits: Limits,
    pub names: Names,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Isolation {
    pub package: String,
    pub targets: Vec<String>,
    pub forbidden: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Layer {
    pub name: String,
    pub path: String,
    pub may_import: Vec<String>,
    pub external_dependencies: Vec<String>,
    pub unsafe_allowed: bool,
    #[serde(default)]
    pub tooling: bool,
    #[serde(default)]
    pub pending: bool,
    #[serde(default)]
    pub permitted_path_dependencies: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Limits {
    pub file_lines: usize,
    pub function_lines: usize,
    pub positional_parameters: usize,
    pub nesting_depth: usize,
    pub public_methods_per_class: usize,
    pub unsafe_function_lines: usize,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Names {
    pub minimum_length: usize,
    pub permitted_short: Vec<String>,
    pub forbidden_components: Vec<String>,
    pub forbidden_files: Vec<String>,
}

#[derive(Clone, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub struct Violation {
    pub path: String,
    pub line: usize,
    pub rule: String,
    pub message: String,
}

pub fn violation(path: &str, line: usize, rule: &str, message: &str) -> Violation {
    Violation {
        path: path.to_owned(),
        line,
        rule: rule.to_owned(),
        message: message.to_owned(),
    }
}
