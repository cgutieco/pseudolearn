use serde::{Deserialize, Serialize};
use serde_json::Value;

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Conformance {
    pub sujeto: String,
    pub paquete: String,
    pub activadas: Vec<String>,
    pub fases_cerradas: Vec<String>,
    pub vinculos: Vec<Binding>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Binding {
    pub regla: String,
    pub verificacion: String,
    pub estado: String,
    #[serde(default)]
    pub resuelve_en: Option<String>,
    #[serde(default)]
    pub justificacion: Option<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct Observation {
    pub specification: String,
    pub rule: String,
    pub case: String,
    pub profile: String,
    pub strictness: String,
    pub verdict: String,
    pub differences: Vec<String>,
    pub expected: Value,
    pub actual: Value,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct Evidence {
    pub protocol: String,
    pub subject: String,
    pub subject_version: String,
    pub corpus_hashes: std::collections::BTreeMap<String, String>,
    pub observations: Vec<Observation>,
    pub stderr: String,
}
