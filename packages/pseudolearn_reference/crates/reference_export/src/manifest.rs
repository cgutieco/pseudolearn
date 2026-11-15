use serde::Serialize;
use sha2::{Digest, Sha256};
use std::collections::BTreeMap;

#[derive(Serialize)]
pub struct Manifest<'manifest> {
    pub format: &'static str,
    pub language: &'manifest str,
    pub profile: &'manifest str,
    pub corpus: &'manifest str,
    pub engine: &'manifest str,
    pub files: BTreeMap<String, String>,
}

pub fn digest(text: &str) -> String {
    Sha256::digest(text.as_bytes())
        .iter()
        .map(|byte| format!("{byte:02x}"))
        .collect()
}
