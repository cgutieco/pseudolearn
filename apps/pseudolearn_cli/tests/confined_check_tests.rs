#![forbid(unsafe_code)]

use pseudolearn_api::ApiSession;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::atomic::{AtomicU64, Ordering};

type OrderedDiagnostic = (String, String, u32, u32);

static NEXT_DIRECTORY: AtomicU64 = AtomicU64::new(0);

fn directory() -> Result<PathBuf, std::io::Error> {
    let sequence = NEXT_DIRECTORY.fetch_add(1, Ordering::Relaxed);
    let path = std::env::temp_dir().join(format!(
        "pseudo-confined-check-{}-{sequence}",
        std::process::id()
    ));
    std::fs::create_dir_all(&path)?;
    Ok(path)
}

fn path_text(path: &Path) -> Result<&str, String> {
    path.to_str()
        .ok_or_else(|| "temporary path is not UTF-8".to_owned())
}

fn api_diagnostic_order() -> Result<Vec<OrderedDiagnostic>, String> {
    let source_text = "Algoritmo P\nEscribir @;\nFinAlgoritmo\n";
    let request = serde_json::json!({
        "profile": "es",
        "strictness": "strict",
        "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
                {"name": "zeta", "root": "zeta", "kind": "application", "entries": [], "dependencies": {}},
                {"name": "alpha", "root": "alpha", "kind": "application", "entries": [], "dependencies": {}}
            ],
            "files": [
                {"path": "zeta/main", "source_id": 1, "text": source_text},
                {"path": "alpha/main", "source_id": 2, "text": source_text}
            ]
        }
    });
    let result = ApiSession::default().call("analyze_project", &request);
    let diagnostics = result
        .pointer("/value/diagnostics")
        .and_then(serde_json::Value::as_array)
        .ok_or_else(|| format!("project analysis failed: {result}"))?;
    diagnostics
        .iter()
        .map(|diagnostic| {
            let source_id = diagnostic
                .pointer("/span/source/source_id")
                .and_then(serde_json::Value::as_u64)
                .ok_or_else(|| "diagnostic source is missing".to_owned())?;
            let path = match source_id {
                1 => "zeta/main",
                2 => "alpha/main",
                _ => return Err("diagnostic source is unknown".to_owned()),
            };
            let code = diagnostic["code"]
                .as_str()
                .ok_or_else(|| "diagnostic code is missing".to_owned())?;
            let line = coordinate(diagnostic, "/span/start/line")?;
            let column = coordinate(diagnostic, "/span/start/column")?;
            Ok((path.to_owned(), code.to_owned(), line, column))
        })
        .collect()
}

fn coordinate(value: &serde_json::Value, pointer: &str) -> Result<u32, String> {
    let value = value
        .pointer(pointer)
        .and_then(serde_json::Value::as_u64)
        .ok_or_else(|| format!("coordinate {pointer} is missing"))?;
    u32::try_from(value).map_err(|error| error.to_string())
}

fn cli_diagnostic_order(root: &Path) -> Result<Vec<OrderedDiagnostic>, String> {
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["check", "--json", "--language", "es"])
        .arg(path_text(root)?)
        .output()
        .map_err(|error| error.to_string())?;
    let response: serde_json::Value =
        serde_json::from_slice(&output.stdout).map_err(|error| error.to_string())?;
    let files = response["files"].as_array().ok_or("files are absent")?;
    files
        .iter()
        .flat_map(|file| {
            let path = file["path"].as_str().unwrap_or("").to_owned();
            file["diagnostics"]
                .as_array()
                .into_iter()
                .flatten()
                .map(move |diagnostic| (path.clone(), diagnostic.clone()))
        })
        .map(|(path, diagnostic)| {
            let module = Path::new(&path)
                .parent()
                .and_then(Path::file_name)
                .and_then(|name| name.to_str())
                .ok_or_else(|| "source module path is missing".to_owned())?;
            Ok((
                format!("{module}/main"),
                diagnostic["code"].as_str().unwrap_or("").to_owned(),
                coordinate(&diagnostic, "/span/start/line")?,
                coordinate(&diagnostic, "/span/start/column")?,
            ))
        })
        .collect()
}

#[cfg(unix)]
#[test]
fn rejects_external_symlink_without_partial_check_output() -> Result<(), String> {
    use std::os::unix::fs::symlink;

    let root = directory().map_err(|error| error.to_string())?;
    let outside = directory().map_err(|error| error.to_string())?;
    let safe_source = root.join("safe.pseudo");
    std::fs::write(
        &safe_source,
        "Algoritmo P\nEscribir unknown_name;\nFinAlgoritmo\n",
    )
    .map_err(|error| error.to_string())?;
    std::fs::write(outside.join("secret.pseudo"), "secret bytes")
        .map_err(|error| error.to_string())?;
    symlink(outside.join("secret.pseudo"), root.join("escape.pseudo"))
        .map_err(|error| error.to_string())?;

    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["check", "--json"])
        .arg(path_text(&safe_source)?)
        .arg(path_text(&root)?)
        .output()
        .map_err(|error| error.to_string())?;

    assert_eq!(output.status.code(), Some(3));
    assert_eq!(output.stdout.as_slice(), b"");
    assert!(!String::from_utf8_lossy(&output.stderr).is_empty());
    std::fs::remove_dir_all(root).map_err(|error| error.to_string())?;
    std::fs::remove_dir_all(outside).map_err(|error| error.to_string())?;
    Ok(())
}

#[cfg(unix)]
#[test]
fn follows_internal_file_symlink_through_check_command() -> Result<(), String> {
    use std::os::unix::fs::symlink;

    let root = directory().map_err(|error| error.to_string())?;
    std::fs::write(
        root.join("source.pseudo"),
        "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    )
    .map_err(|error| error.to_string())?;
    symlink("source.pseudo", root.join("alias.pseudo")).map_err(|error| error.to_string())?;

    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["check", "--json"])
        .arg(path_text(&root)?)
        .output()
        .map_err(|error| error.to_string())?;

    assert_eq!(output.status.code(), Some(0));
    let response: serde_json::Value =
        serde_json::from_slice(&output.stdout).map_err(|error| error.to_string())?;
    let files = response["files"].as_array().ok_or("files are absent")?;
    assert_eq!(files.len(), 2);
    assert!(
        files[0]["path"]
            .as_str()
            .is_some_and(|path| path.ends_with("alias.pseudo"))
    );
    assert!(
        files[1]["path"]
            .as_str()
            .is_some_and(|path| path.ends_with("source.pseudo"))
    );
    std::fs::remove_dir_all(root).map_err(|error| error.to_string())?;
    Ok(())
}

#[test]
fn check_json_order_ignores_argument_order_and_interface_locale() -> Result<(), String> {
    let root = directory().map_err(|error| error.to_string())?;
    let alpha = root.join("alpha.pseudo");
    let zeta = root.join("zeta.pseudo");
    std::fs::write(&alpha, "Algoritmo P\nEscribir @;\nFinAlgoritmo\n")
        .map_err(|error| error.to_string())?;
    std::fs::write(&zeta, "Algoritmo P\nEscribir $;\nFinAlgoritmo\n")
        .map_err(|error| error.to_string())?;

    let spanish = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["check", "--json", "--language", "es"])
        .arg(path_text(&zeta)?)
        .arg(path_text(&alpha)?)
        .output()
        .map_err(|error| error.to_string())?;
    let english = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["check", "--json", "--language", "en"])
        .arg(path_text(&alpha)?)
        .arg(path_text(&zeta)?)
        .output()
        .map_err(|error| error.to_string())?;

    assert_eq!(spanish.status.code(), Some(1));
    assert_eq!(english.status.code(), Some(1));
    let spanish_json: serde_json::Value =
        serde_json::from_slice(&spanish.stdout).map_err(|error| error.to_string())?;
    let english_json: serde_json::Value =
        serde_json::from_slice(&english.stdout).map_err(|error| error.to_string())?;
    assert_eq!(spanish_json, english_json);
    let files = spanish_json["files"].as_array().ok_or("files are absent")?;
    assert!(
        files[0]["path"]
            .as_str()
            .is_some_and(|path| path.ends_with("alpha.pseudo"))
    );
    assert!(
        files[1]["path"]
            .as_str()
            .is_some_and(|path| path.ends_with("zeta.pseudo"))
    );
    std::fs::remove_dir_all(root).map_err(|error| error.to_string())?;
    Ok(())
}

#[test]
fn cli_and_project_api_return_diagnostics_in_the_same_path_order() -> Result<(), String> {
    let root = directory().map_err(|error| error.to_string())?;
    for module in ["alpha", "zeta"] {
        let directory = root.join(module);
        std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
        std::fs::write(
            directory.join("main.pseudo"),
            "Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
        )
        .map_err(|error| error.to_string())?;
    }
    assert_eq!(cli_diagnostic_order(&root)?, api_diagnostic_order()?);
    std::fs::remove_dir_all(root).map_err(|error| error.to_string())?;
    Ok(())
}
