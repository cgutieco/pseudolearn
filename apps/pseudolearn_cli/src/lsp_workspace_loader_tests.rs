use crate::lsp_workspace_loader::{
    decode_file_uri, encode_file_uri, root_directory, snapshot_message,
};
use serde_json::json;
use std::fs;

#[test]
fn uri_round_trips_spaces_accents_and_non_bmp() {
    let path = "/tmp/ps ñandú/espacio 😀/main.pseudo";
    let uri = encode_file_uri(path);
    assert_eq!(
        uri,
        "file:///tmp/ps%20%C3%B1and%C3%BA/espacio%20%F0%9F%98%80/main.pseudo"
    );
    assert_eq!(decode_file_uri(&uri).as_deref(), Some(path));
}

#[test]
fn malformed_or_foreign_uris_are_refused() {
    assert_eq!(decode_file_uri("https://example.com/a"), None);
    assert_eq!(decode_file_uri("file:///a%2"), None);
    assert_eq!(decode_file_uri("file:///a%ZZ"), None);
    assert_eq!(decode_file_uri("file:///a%FF"), None);
}

#[test]
fn root_prefers_the_first_workspace_folder_over_the_root_uri() {
    let both =
        json!({"params": {"workspaceFolders": [{"uri": "file:///one"}], "rootUri": "file:///two"}});
    assert_eq!(root_directory(&both).as_deref(), Some("/one"));
    let legacy = json!({"params": {"rootUri": "file:///two"}});
    assert_eq!(root_directory(&legacy).as_deref(), Some("/two"));
    assert_eq!(root_directory(&json!({"params": {"rootUri": null}})), None);
    assert_eq!(root_directory(&json!({"params": {}})), None);
}

fn write_project(root: &std::path::Path) -> Result<(), String> {
    let failure = |error: std::io::Error| error.to_string();
    fs::create_dir_all(root.join("app")).map_err(failure)?;
    fs::create_dir_all(root.join("geo")).map_err(failure)?;
    fs::write(
        root.join("app/pseudolearn.toml"),
        "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n",
    )
    .map_err(failure)?;
    fs::write(
        root.join("app/main.pseudo"),
        "Importar geo.vectores.Doble;\n",
    )
    .map_err(failure)?;
    fs::write(
        root.join("geo/pseudolearn.toml"),
        "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
    )
    .map_err(failure)?;
    fs::write(
        root.join("geo/vectores.pseudo"),
        "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n;\nFinSubProceso\n",
    )
    .map_err(failure)
}

#[test]
fn snapshot_describes_packages_files_and_uris_of_a_project() -> Result<(), String> {
    let directory = std::env::temp_dir().join(format!("pseudo loader ñ {}", std::process::id()));
    write_project(&directory)?;
    let root = directory.to_str().ok_or("path")?;
    let message = snapshot_message(root, "es", 3).ok_or("no snapshot")?;
    fs::remove_dir_all(&directory).map_err(|error| error.to_string())?;
    assert_eq!(
        message.pointer("/params/project/revision_id"),
        Some(&json!(3))
    );
    let packages = message
        .pointer("/params/project/packages")
        .and_then(|found| found.as_array())
        .ok_or("packages")?;
    assert_eq!(packages.len(), 2);
    assert_eq!(packages[0]["name"], json!("app"));
    assert_eq!(packages[0]["dependencies"]["geo"], json!("geo"));
    assert_eq!(
        message
            .pointer("/params/project/files")
            .and_then(|found| found.as_array())
            .map(Vec::len),
        Some(2)
    );
    let uri = message
        .pointer("/params/uris/geo~1vectores")
        .and_then(|found| found.as_str())
        .ok_or("uri")?;
    assert!(uri.ends_with("/geo/vectores.pseudo") && uri.contains("%C3%B1"));
    Ok(())
}

#[test]
fn a_folder_of_loose_files_without_manifests_produces_no_snapshot() -> Result<(), String> {
    let directory =
        std::env::temp_dir().join(format!("pseudo loader loose {}", std::process::id()));
    fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    fs::write(directory.join("hola.pseudo"), "Algoritmo X\nFinAlgoritmo\n")
        .map_err(|error| error.to_string())?;
    let produced = snapshot_message(directory.to_str().ok_or("path")?, "es", 1);
    fs::remove_dir_all(&directory).map_err(|error| error.to_string())?;
    assert!(produced.is_none());
    Ok(())
}

#[test]
fn missing_or_empty_roots_produce_no_snapshot() {
    assert!(snapshot_message("/definitely/missing/pseudo-root", "es", 1).is_none());
}

#[test]
fn loader_resyncs_only_after_initialized_and_save_with_increasing_revisions() -> Result<(), String>
{
    let directory = std::env::temp_dir().join(format!("pseudo loader sync {}", std::process::id()));
    write_project(&directory)?;
    let root = directory.to_str().ok_or("path")?;
    let mut loader = crate::lsp_workspace_loader::WorkspaceLoader::new("es");
    let initialize = json!({"jsonrpc":"2.0","id":1,"method":"initialize","params":{"rootUri": encode_file_uri(root)}});
    loader.observe(&initialize);
    assert!(loader.resync(&initialize).is_none());
    let first = loader
        .resync(&json!({"method":"initialized"}))
        .ok_or("first")?;
    let second = loader
        .resync(&json!({"method":"textDocument/didSave"}))
        .ok_or("second")?;
    assert!(
        loader
            .resync(&json!({"method":"textDocument/didOpen"}))
            .is_none()
    );
    fs::remove_dir_all(&directory).map_err(|error| error.to_string())?;
    assert_eq!(
        first.pointer("/params/project/revision_id"),
        Some(&json!(1))
    );
    assert_eq!(
        second.pointer("/params/project/revision_id"),
        Some(&json!(2))
    );
    Ok(())
}

#[test]
fn loader_without_a_root_never_resyncs() {
    let mut loader = crate::lsp_workspace_loader::WorkspaceLoader::new("es");
    loader.observe(&json!({"method":"initialize","params":{}}));
    assert!(loader.resync(&json!({"method":"initialized"})).is_none());
}
