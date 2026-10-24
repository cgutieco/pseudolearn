use sha2::{Digest, Sha256};
use std::collections::BTreeMap;

const FILE_DOMAIN: &[u8] = b"pseudolearn.lock.file.v1\n";
const PACKAGE_DOMAIN: &[u8] = b"pseudolearn.lock.package.v1\n";

pub(crate) fn file_digest(bytes: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(FILE_DOMAIN);
    hasher.update(bytes);
    render(hasher)
}

pub(crate) fn package_digest(files: &BTreeMap<String, String>) -> String {
    let mut hasher = Sha256::new();
    hasher.update(PACKAGE_DOMAIN);
    let mut paths: Vec<(&String, &String)> = files.iter().collect();
    paths.sort_by(|left, right| {
        pseudolearn_project::logical_path_key(left.0)
            .cmp(&pseudolearn_project::logical_path_key(right.0))
            .then_with(|| left.0.cmp(right.0))
    });
    for (path, digest) in paths {
        let normalized =
            pseudolearn_project::normalize_logical_path(path).unwrap_or_else(|| path.clone());
        hasher.update(normalized.as_bytes());
        hasher.update([0_u8]);
        hasher.update(digest.as_bytes());
        hasher.update(b"\n");
    }
    render(hasher)
}

fn render(hasher: Sha256) -> String {
    format!(
        "{}{:x}",
        pseudolearn_project::DIGEST_PREFIX,
        hasher.finalize()
    )
}
