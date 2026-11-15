#![cfg(windows)]

use pseudolearn_host::PhysicalHost;
use serde_json::{Value, json};
use std::path::PathBuf;

struct Sandbox {
    root: PathBuf,
}

impl Sandbox {
    fn new(name: &str) -> Result<Self, String> {
        let root = std::env::temp_dir().join(format!(
            "pseudolearn_host_paths_{}_{name}",
            std::process::id()
        ));
        let _ = std::fs::remove_dir_all(&root);
        std::fs::create_dir_all(root.join("work").join("sub"))
            .map_err(|error| error.to_string())?;
        Ok(Self { root })
    }

    fn text(&self) -> String {
        self.root.join("work").to_string_lossy().into_owned()
    }
}

impl Drop for Sandbox {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.root);
    }
}

fn request_directory(host: &mut PhysicalHost, path: &str) -> Value {
    host.perform(&json!({"effect_seq":1,"operation":"request_directory",
        "arguments":[{"kind":"text","value":path}],"receiver":null,
        "result_capability":{"slot":1,"generation":1,"rights":3,"kind":2}}))
}

fn outcome(reply: &Value) -> Option<&str> {
    reply.get("outcome").and_then(Value::as_str)
}

#[test]
fn drive_letter_paths_open_with_either_separator() -> Result<(), String> {
    let sandbox = Sandbox::new("drive")?;
    let mut host = PhysicalHost::new(std::env::temp_dir(), Vec::new());
    let native = sandbox.text();
    assert!(native.chars().nth(1) == Some(':'), "{native}");
    assert_eq!(
        outcome(&request_directory(&mut host, &native)),
        Some("committed")
    );
    let forward = native.replace('\\', "/");
    assert_eq!(
        outcome(&request_directory(&mut host, &forward)),
        Some("committed")
    );
    Ok(())
}

#[test]
fn verbatim_and_relative_backslash_paths_open() -> Result<(), String> {
    let sandbox = Sandbox::new("verbatim")?;
    let mut host = PhysicalHost::new(sandbox.root.clone(), Vec::new());
    let verbatim = format!(r"\\?\{}", sandbox.text());
    assert_eq!(
        outcome(&request_directory(&mut host, &verbatim)),
        Some("committed")
    );
    assert_eq!(
        outcome(&request_directory(&mut host, r"work\sub")),
        Some("committed")
    );
    Ok(())
}

#[test]
fn unc_paths_answer_with_a_value_and_never_abort() {
    let mut host = PhysicalHost::new(std::env::temp_dir(), Vec::new());
    let reply = request_directory(&mut host, r"\\localhost\C$\Windows");
    assert!(
        matches!(outcome(&reply), Some("committed" | "failed")),
        "{reply}"
    );
}

#[test]
fn missing_drive_and_file_target_fail_as_typed_errors() -> Result<(), String> {
    let sandbox = Sandbox::new("missing")?;
    let file = sandbox.root.join("work").join("plain.txt");
    std::fs::write(&file, "x").map_err(|error| error.to_string())?;
    let mut host = PhysicalHost::new(std::env::temp_dir(), Vec::new());
    for path in [
        r"Q:\pseudolearn\missing".to_owned(),
        file.to_string_lossy().into_owned(),
    ] {
        let reply = request_directory(&mut host, &path);
        assert_eq!(outcome(&reply), Some("failed"), "{reply}");
        assert!(reply.pointer("/value/code").is_some(), "{reply}");
    }
    Ok(())
}
