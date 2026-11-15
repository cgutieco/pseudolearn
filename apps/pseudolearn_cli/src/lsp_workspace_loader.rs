use crate::project_files::{self, ProjectSnapshot};
use crate::project_session;
use serde_json::{Value, json};
use std::collections::BTreeMap;

const SOURCE_SUFFIX: &str = ".pseudo";
const FILE_SCHEME: &str = "file://";

pub(crate) struct WorkspaceLoader {
    directory: Option<String>,
    revision: u64,
    locale: String,
    manifests: BTreeMap<String, (String, Value)>,
}

impl WorkspaceLoader {
    pub(crate) fn new(locale: &str) -> Self {
        Self {
            directory: None,
            revision: 0,
            locale: locale.to_owned(),
            manifests: BTreeMap::new(),
        }
    }

    pub(crate) fn observe(&mut self, message: &Value) {
        if method_of(message) == Some("initialize") {
            self.directory = root_directory(message);
        }
    }

    pub(crate) fn resync(&mut self, message: &Value) -> Option<Value> {
        if !matches!(
            method_of(message),
            Some("initialized" | "textDocument/didSave")
        ) {
            return None;
        }
        let directory = self.directory.as_deref()?;
        self.revision = self.revision.saturating_add(1);
        snapshot_message_cached(directory, &self.locale, self.revision, &mut self.manifests)
    }
}

fn method_of(message: &Value) -> Option<&str> {
    message.get("method").and_then(Value::as_str)
}

pub(crate) fn root_directory(initialize: &Value) -> Option<String> {
    let folder = initialize
        .pointer("/params/workspaceFolders/0/uri")
        .and_then(Value::as_str);
    let root = initialize
        .pointer("/params/rootUri")
        .and_then(Value::as_str);
    decode_file_uri(folder.or(root)?)
}

#[cfg(test)]
pub(crate) fn snapshot_message(directory: &str, locale: &str, revision: u64) -> Option<Value> {
    snapshot_message_cached(directory, locale, revision, &mut BTreeMap::new())
}

fn snapshot_message_cached(
    directory: &str,
    locale: &str,
    revision: u64,
    manifest_cache: &mut BTreeMap<String, (String, Value)>,
) -> Option<Value> {
    let snapshot = project_files::load(directory, locale).ok()?;
    let packages = packages_of(&snapshot, manifest_cache)?;
    if packages.is_empty() {
        return None;
    }
    Some(json!({
        "jsonrpc": "2.0",
        "method": "pseudolearn/workspaceSnapshot",
        "params": {
            "project": {
                "project_id": 1,
                "revision_id": revision,
                "packages": packages,
                "files": files_of(&snapshot),
            },
            "uris": uris_of(&snapshot, directory),
        },
    }))
}

fn packages_of(
    snapshot: &ProjectSnapshot,
    manifest_cache: &mut BTreeMap<String, (String, Value)>,
) -> Option<Vec<Value>> {
    let mut packages = Vec::new();
    let mut current = BTreeMap::new();
    for manifest in &snapshot.manifests {
        let resolved = cached_manifest(manifest, manifest_cache)?;
        packages.push(package_of(resolved.get("configuration")?)?);
        current.insert(manifest.location.clone(), (manifest.text.clone(), resolved));
    }
    *manifest_cache = current;
    Some(packages)
}

fn cached_manifest(
    manifest: &crate::project_files::ManifestFile,
    manifest_cache: &BTreeMap<String, (String, Value)>,
) -> Option<Value> {
    cached_manifest_with(manifest, manifest_cache, |request| {
        project_session::call("resolve_manifest", request).ok()
    })
}

pub(crate) fn cached_manifest_with(
    manifest: &crate::project_files::ManifestFile,
    manifest_cache: &BTreeMap<String, (String, Value)>,
    mut resolve: impl FnMut(&Value) -> Option<Value>,
) -> Option<Value> {
    if let Some((text, resolved)) = manifest_cache.get(&manifest.location)
        && text == &manifest.text
    {
        return Some(resolved.clone());
    }
    let request = json!({"manifest": manifest.text, "location": manifest.location});
    resolve(&request)
}

fn package_of(configuration: &Value) -> Option<Value> {
    let field = |name: &str| {
        configuration
            .pointer(&format!("/package/{name}/value"))
            .cloned()
    };
    let dependencies: BTreeMap<String, String> = configuration
        .get("dependencies")?
        .as_array()?
        .iter()
        .filter_map(|dependency| {
            Some((
                dependency.get("alias")?.as_str()?.to_owned(),
                dependency.get("package")?.as_str()?.to_owned(),
            ))
        })
        .collect();
    Some(json!({
        "name": field("name")?,
        "root": field("root")?,
        "kind": field("kind")?,
        "entries": field("entries")?,
        "dependencies": dependencies,
    }))
}

fn files_of(snapshot: &ProjectSnapshot) -> Vec<Value> {
    snapshot
        .sources
        .iter()
        .map(|source| json!({"path": source.path, "source_id": source.source_id, "text": source.text}))
        .collect()
}

fn uris_of(snapshot: &ProjectSnapshot, directory: &str) -> BTreeMap<String, String> {
    let base = directory.trim_end_matches('/');
    snapshot
        .sources
        .iter()
        .map(|source| {
            let location = format!("{base}/{}{SOURCE_SUFFIX}", source.path);
            (source.path.clone(), encode_file_uri(&location))
        })
        .collect()
}

pub(crate) fn encode_file_uri(path: &str) -> String {
    let mut uri = String::from(FILE_SCHEME);
    for byte in path.bytes() {
        if byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'.' | b'_' | b'~' | b'/') {
            uri.push(char::from(byte));
        } else {
            uri.push('%');
            uri.push(hex_digit(byte / 16));
            uri.push(hex_digit(byte % 16));
        }
    }
    uri
}

fn hex_digit(value: u8) -> char {
    char::from_digit(u32::from(value), 16).map_or('0', |digit| digit.to_ascii_uppercase())
}

pub(crate) fn decode_file_uri(uri: &str) -> Option<String> {
    let encoded = uri.strip_prefix(FILE_SCHEME)?;
    let bytes = encoded.as_bytes();
    let mut decoded = Vec::with_capacity(bytes.len());
    let mut index = 0;
    while let Some(&byte) = bytes.get(index) {
        if byte == b'%' {
            let digits = encoded.get(index + 1..index + 3)?;
            decoded.push(u8::from_str_radix(digits, 16).ok()?);
            index += 3;
        } else {
            decoded.push(byte);
            index += 1;
        }
    }
    String::from_utf8(decoded).ok()
}
