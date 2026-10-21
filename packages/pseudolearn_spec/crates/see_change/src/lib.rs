#![forbid(unsafe_code)]

pub mod classification;
pub mod locking;

pub const VERSIONING_FROZEN: bool = true;

use see_model::{Specification, field};
use sha2::{Digest, Sha256};

pub fn hash(specification: &Specification) -> Result<String, String> {
    let metadata = &specification.metadata;
    let mut blocks: Vec<_> = specification
        .blocks
        .iter()
        .filter(|block| block.kind != "pregunta")
        .collect();
    blocks.sort_by_key(|block| (block.kind.as_str(), field(block, "id")));
    let normative = serde_json::json!({"id": metadata.id, "dominio": metadata.dominio, "edicion": metadata.edicion, "sujetos": metadata.sujetos, "depende_de": metadata.depende_de, "reemplaza": metadata.reemplaza, "blocks": blocks});
    let bytes = serde_json::to_vec(&normative).map_err(|error| error.to_string())?;
    Ok(format!("{:x}", Sha256::digest(bytes)))
}

pub fn elements(specification: &Specification) -> std::collections::BTreeMap<String, String> {
    specification
        .blocks
        .iter()
        .map(|block| (field(block, "id").to_owned(), block.kind.clone()))
        .collect()
}
