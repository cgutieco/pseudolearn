use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Default, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct Lock {
    pub formato: String,
    pub specifications: BTreeMap<String, Anchor>,
    pub history: BTreeMap<String, Anchor>,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct Anchor {
    pub version: String,
    pub hash: String,
    pub state: String,
    pub elements: BTreeMap<String, String>,
    #[serde(default)]
    pub edition: BTreeMap<String, String>,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Manifest {
    pub caracteristica: String,
    pub titulo: String,
    pub estado_agregado: String,
    pub edicion: String,
    pub especificaciones: Vec<String>,
    pub criterio_de_terminado: Vec<String>,
}

pub type Vocabulary = BTreeMap<String, BTreeMap<String, String>>;
