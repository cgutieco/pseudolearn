#![forbid(unsafe_code)]

pub mod contract;
pub mod evidence;

use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct Metadata {
    pub formato: String,
    pub id: String,
    pub titulo: String,
    pub dominio: String,
    pub estado: String,
    pub version: String,
    pub duenos: Vec<String>,
    pub sujetos: Vec<String>,
    pub resumen: String,
    #[serde(default)]
    pub titulo_en: Option<String>,
    #[serde(default)]
    pub edicion: BTreeMap<String, String>,
    #[serde(default)]
    pub depende_de: Vec<Dependency>,
    #[serde(default)]
    pub reemplaza: Option<String>,
    #[serde(default)]
    pub reemplazada_por: Option<String>,
    #[serde(default)]
    pub cambio: Option<Change>,
    #[serde(default)]
    pub revisado_por: Vec<String>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct Dependency {
    pub id: String,
    pub version: String,
    pub tipo: String,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct Change {
    pub clase: String,
    pub impacto_usuarios: String,
    pub impacto_implementaciones: String,
    pub justificacion: String,
    pub revisado_por: String,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
pub struct Block {
    pub kind: String,
    pub fields: BTreeMap<String, Value>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
pub struct Specification {
    pub path: String,
    pub metadata: Metadata,
    pub blocks: Vec<Block>,
}

pub type Corpus = Vec<Specification>;

pub fn field<'block>(block: &'block Block, name: &str) -> &'block str {
    block.fields.get(name).and_then(Value::as_str).unwrap_or("")
}

pub fn strings(value: Option<&Value>) -> Vec<&str> {
    value
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
        .collect()
}
