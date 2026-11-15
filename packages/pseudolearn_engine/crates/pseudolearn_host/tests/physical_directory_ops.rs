use pseudolearn_host::PhysicalHost;
use serde_json::{Value, json};
use std::path::PathBuf;

struct Sandbox {
    root: PathBuf,
}

impl Sandbox {
    fn new(name: &str) -> Result<Self, String> {
        let root = std::env::temp_dir().join(format!(
            "pseudolearn_host_directory_ops_{}_{name}",
            std::process::id()
        ));
        let _ = std::fs::remove_dir_all(&root);
        std::fs::create_dir_all(root.join("work")).map_err(|error| error.to_string())?;
        Ok(Self { root })
    }

    fn work(&self) -> PathBuf {
        self.root.join("work")
    }
}

impl Drop for Sandbox {
    fn drop(&mut self) {
        let _ = std::fs::remove_dir_all(&self.root);
    }
}

fn capability(slot: u32, rights: u8, kind: u32) -> Value {
    json!({"slot":slot,"generation":1,"rights":rights,"kind":kind})
}

fn text(value: &str) -> Value {
    json!({"kind":"text","value":value})
}

fn perform(
    host: &mut PhysicalHost,
    operation: &str,
    receiver: u32,
    arguments: Vec<Value>,
) -> Value {
    host.perform(
        &json!({"effect_seq":1,"operation":operation,"arguments":arguments,
        "receiver":capability(receiver, 3, 2),"result_capability":null}),
    )
}

fn open_root(host: &mut PhysicalHost, path: &str, slot: u32) {
    let reply = host.perform(&json!({"effect_seq":1,"operation":"request_directory",
        "arguments":[text(path)],"receiver":null,"result_capability":capability(slot, 3, 2)}));
    assert_eq!(reply.get("outcome"), Some(&json!("committed")), "{reply}");
}

fn derive(
    host: &mut PhysicalHost,
    receiver: u32,
    path: &str,
    mode: &str,
    slot: u32,
    rights: u8,
) -> Value {
    host.perform(&json!({"effect_seq":1,"operation":"directory_derive",
        "arguments":[text(path), text(mode)],
        "receiver":capability(receiver, 3, 2),"result_capability":capability(slot, rights, 2)}))
}

fn code(reply: &Value) -> Option<&str> {
    reply.pointer("/value/code").and_then(Value::as_str)
}

fn value(reply: &Value) -> Option<&Value> {
    reply.pointer("/value/value")
}

fn host_in(sandbox: &Sandbox) -> PhysicalHost {
    let mut host = PhysicalHost::new(sandbox.root.clone(), Vec::new());
    open_root(&mut host, "work", 1);
    host
}

#[test]
fn list_orders_names_by_code_point_without_dot_entries() -> Result<(), String> {
    let sandbox = Sandbox::new("list")?;
    for name in ["b", "a", "C", "á"] {
        std::fs::write(sandbox.work().join(name), "x").map_err(|error| error.to_string())?;
    }
    std::fs::create_dir(sandbox.work().join("s")).map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    let reply = perform(&mut host, "directory_list", 1, vec![text(".")]);
    assert_eq!(
        value(&reply),
        Some(&json!(["C", "a", "b", "s", "á"])),
        "{reply}"
    );
    Ok(())
}

#[test]
fn list_of_empty_absent_and_file_paths() -> Result<(), String> {
    let sandbox = Sandbox::new("list_edges")?;
    std::fs::create_dir(sandbox.work().join("empty")).map_err(|error| error.to_string())?;
    std::fs::write(sandbox.work().join("file"), "x").map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    let empty = perform(&mut host, "directory_list", 1, vec![text("empty")]);
    assert_eq!(value(&empty), Some(&json!([])));
    let absent = perform(&mut host, "directory_list", 1, vec![text("absent")]);
    assert_eq!(code(&absent), Some("no_encontrado"));
    let file = perform(&mut host, "directory_list", 1, vec![text("file")]);
    assert_eq!(code(&file), Some("ruta_invalida"));
    Ok(())
}

#[cfg(target_os = "linux")]
#[test]
fn list_rejects_names_that_are_not_utf8() -> Result<(), String> {
    use std::os::unix::ffi::OsStrExt;
    let sandbox = Sandbox::new("non_utf8")?;
    let name = std::ffi::OsStr::from_bytes(&[0x66, 0xff]);
    std::fs::write(sandbox.work().join(name), "x").map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    let reply = perform(&mut host, "directory_list", 1, vec![text(".")]);
    assert_eq!(code(&reply), Some("utf8_invalido"));
    Ok(())
}

#[test]
fn exists_and_is_directory_distinguish_files_directories_and_absent() -> Result<(), String> {
    let sandbox = Sandbox::new("exists")?;
    std::fs::create_dir(sandbox.work().join("d")).map_err(|error| error.to_string())?;
    std::fs::write(sandbox.work().join("f"), "x").map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    for (path, exists, directory) in [("d", true, true), ("f", true, false), ("z", false, false)] {
        let found = perform(&mut host, "directory_exists", 1, vec![text(path)]);
        assert_eq!(value(&found), Some(&json!(exists)), "{path}");
        let kind = perform(&mut host, "directory_is_directory", 1, vec![text(path)]);
        assert_eq!(value(&kind), Some(&json!(directory)), "{path}");
    }
    Ok(())
}

#[test]
fn create_makes_one_level_and_reports_existing_or_missing_parent() -> Result<(), String> {
    let sandbox = Sandbox::new("create")?;
    let mut host = host_in(&sandbox);
    let created = perform(&mut host, "directory_create", 1, vec![text("n")]);
    assert_eq!(value(&created), Some(&json!(true)));
    assert!(sandbox.work().join("n").is_dir());
    let again = perform(&mut host, "directory_create", 1, vec![text("n")]);
    assert_eq!(code(&again), Some("ya_existe"));
    let orphan = perform(&mut host, "directory_create", 1, vec![text("p/n")]);
    assert_eq!(code(&orphan), Some("no_encontrado"));
    assert!(!sandbox.work().join("p").exists());
    Ok(())
}

#[test]
fn delete_removes_files_and_empty_directories_but_never_recurses() -> Result<(), String> {
    let sandbox = Sandbox::new("delete")?;
    std::fs::create_dir(sandbox.work().join("empty")).map_err(|error| error.to_string())?;
    std::fs::create_dir(sandbox.work().join("full")).map_err(|error| error.to_string())?;
    std::fs::write(sandbox.work().join("full/x"), "x").map_err(|error| error.to_string())?;
    std::fs::write(sandbox.work().join("f"), "x").map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    assert_eq!(
        value(&perform(&mut host, "directory_delete", 1, vec![text("f")])),
        Some(&json!(true))
    );
    assert_eq!(
        value(&perform(
            &mut host,
            "directory_delete",
            1,
            vec![text("empty")]
        )),
        Some(&json!(true))
    );
    let full = perform(&mut host, "directory_delete", 1, vec![text("full")]);
    assert_eq!(code(&full), Some("peticion_invalida"));
    assert!(sandbox.work().join("full/x").exists());
    let absent = perform(&mut host, "directory_delete", 1, vec![text("absent")]);
    assert_eq!(code(&absent), Some("no_encontrado"));
    Ok(())
}

#[test]
fn rename_never_overwrites_and_reports_each_cause() -> Result<(), String> {
    let sandbox = Sandbox::new("rename")?;
    std::fs::write(sandbox.work().join("a"), "one").map_err(|error| error.to_string())?;
    std::fs::write(sandbox.work().join("b"), "two").map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    let clash = perform(&mut host, "directory_rename", 1, vec![text("a"), text("b")]);
    assert_eq!(code(&clash), Some("ya_existe"));
    assert_eq!(
        std::fs::read_to_string(sandbox.work().join("b")).map_err(|error| error.to_string())?,
        "two"
    );
    let absent = perform(
        &mut host,
        "directory_rename",
        1,
        vec![text("zz"), text("c")],
    );
    assert_eq!(code(&absent), Some("no_encontrado"));
    let moved = perform(&mut host, "directory_rename", 1, vec![text("a"), text("c")]);
    assert_eq!(value(&moved), Some(&json!(true)));
    assert_eq!(
        std::fs::read_to_string(sandbox.work().join("c")).map_err(|error| error.to_string())?,
        "one"
    );
    assert!(!sandbox.work().join("a").exists());
    Ok(())
}

#[test]
fn confined_capability_rejects_escaping_paths_in_every_operation() -> Result<(), String> {
    let sandbox = Sandbox::new("confined")?;
    std::fs::create_dir(sandbox.work().join("sub")).map_err(|error| error.to_string())?;
    std::fs::write(sandbox.work().join("outside"), "secret").map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    let derived = derive(&mut host, 1, "sub", "read_write", 2, 3);
    assert_eq!(
        derived.get("outcome"),
        Some(&json!("committed")),
        "{derived}"
    );
    let absolute = sandbox.work().join("outside").display().to_string();
    for path in [
        "../outside",
        "a/../../outside",
        absolute.as_str(),
        "",
        "C:x",
        "a\\b",
    ] {
        for operation in [
            "directory_exists",
            "directory_is_directory",
            "directory_list",
            "directory_delete",
            "directory_create",
        ] {
            let reply = perform(&mut host, operation, 2, vec![text(path)]);
            assert_eq!(
                code(&reply),
                Some("ruta_invalida"),
                "{operation} {path:?} {reply}"
            );
        }
        let rename = perform(
            &mut host,
            "directory_rename",
            2,
            vec![text("x"), text(path)],
        );
        assert_eq!(code(&rename), Some("ruta_invalida"), "{path:?}");
    }
    assert!(sandbox.work().join("outside").exists());
    Ok(())
}

#[test]
fn thousand_traversal_paths_never_escape_the_confinement() -> Result<(), String> {
    let sandbox = Sandbox::new("traversal")?;
    std::fs::create_dir(sandbox.work().join("sub")).map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    derive(&mut host, 1, "sub", "read_write", 2, 3);
    let mut seed = 0x2545_f491_4f6c_dd1d_u64;
    for index in 0..1000 {
        seed = seed
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        let depth = 1 + usize::try_from(seed >> 61).map_err(|error| error.to_string())?;
        let path = format!("{}escape{index}", "../".repeat(depth));
        let created = perform(&mut host, "directory_create", 2, vec![text(&path)]);
        assert_eq!(created.get("outcome"), Some(&json!("failed")), "{path}");
        let renamed = perform(
            &mut host,
            "directory_rename",
            2,
            vec![text("."), text(&path)],
        );
        assert_eq!(renamed.get("outcome"), Some(&json!("failed")), "{path}");
    }
    let leaked = std::fs::read_dir(&sandbox.root)
        .map_err(|error| error.to_string())?
        .count();
    assert_eq!(leaked, 1);
    let inside = std::fs::read_dir(sandbox.work())
        .map_err(|error| error.to_string())?
        .count();
    assert_eq!(inside, 1);
    Ok(())
}

#[cfg(unix)]
#[test]
fn symbolic_link_cannot_leave_the_confined_directory() -> Result<(), String> {
    let sandbox = Sandbox::new("symlink")?;
    std::fs::create_dir(sandbox.work().join("sub")).map_err(|error| error.to_string())?;
    std::fs::create_dir(sandbox.root.join("secret")).map_err(|error| error.to_string())?;
    std::fs::write(sandbox.root.join("secret/data"), "x").map_err(|error| error.to_string())?;
    std::os::unix::fs::symlink(sandbox.root.join("secret"), sandbox.work().join("sub/link"))
        .map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    derive(&mut host, 1, "sub", "read_write", 2, 3);
    for (operation, arguments) in [
        ("directory_list", vec![text("link")]),
        ("directory_exists", vec![text("link/data")]),
        ("directory_delete", vec![text("link/data")]),
        ("directory_create", vec![text("link/new")]),
    ] {
        let reply = perform(&mut host, operation, 2, arguments);
        assert_ne!(
            reply.get("outcome"),
            Some(&json!("committed")),
            "{operation} {reply}"
        );
    }
    assert!(sandbox.root.join("secret/data").exists());
    assert!(!sandbox.root.join("secret/new").exists());
    Ok(())
}

#[test]
fn read_only_derivation_cannot_mutate_and_write_only_cannot_query() -> Result<(), String> {
    let sandbox = Sandbox::new("rights")?;
    std::fs::create_dir(sandbox.work().join("sub")).map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    derive(&mut host, 1, "sub", "read", 2, 1);
    derive(&mut host, 1, "sub", "write", 3, 2);
    for operation in ["directory_create", "directory_delete"] {
        let reply = perform(&mut host, operation, 2, vec![text("n")]);
        assert_eq!(code(&reply), Some("permiso_denegado"), "{operation}");
    }
    let rename = perform(&mut host, "directory_rename", 2, vec![text("a"), text("b")]);
    assert_eq!(code(&rename), Some("permiso_denegado"));
    let query = perform(&mut host, "directory_exists", 3, vec![text("n")]);
    assert_eq!(code(&query), Some("permiso_denegado"));
    assert!(!sandbox.work().join("sub/n").exists());
    Ok(())
}

#[test]
fn closed_directory_capability_is_rejected() -> Result<(), String> {
    let sandbox = Sandbox::new("closed")?;
    let mut host = host_in(&sandbox);
    let closed = perform(&mut host, "directory_close", 1, Vec::new());
    assert_eq!(value(&closed), Some(&json!(true)));
    let reply = perform(&mut host, "directory_exists", 1, vec![text("a")]);
    assert_eq!(code(&reply), Some("capacidad_cerrada"));
    Ok(())
}

fn open_file(host: &mut PhysicalHost, name: &str, mode: &str, slot: u32, rights: u8) -> Value {
    host.perform(&json!({"effect_seq":1,"operation":"file_open",
        "arguments":[text(name), text(mode)],
        "receiver":capability(1, 3, 2),"result_capability":capability(slot, rights, 3)}))
}

fn file_operation(
    host: &mut PhysicalHost,
    operation: &str,
    slot: u32,
    rights: u8,
    arguments: Vec<Value>,
) -> Value {
    host.perform(
        &json!({"effect_seq":1,"operation":operation,"arguments":arguments,
        "receiver":capability(slot, rights, 3),"result_capability":null}),
    )
}

#[test]
fn append_adds_to_the_end_of_the_current_content() -> Result<(), String> {
    let sandbox = Sandbox::new("append")?;
    let mut host = host_in(&sandbox);
    open_file(&mut host, "n", "write", 2, 2);
    let written = file_operation(&mut host, "file_write_text", 2, 2, vec![text("x")]);
    assert_eq!(value(&written), Some(&json!(1)));
    let first = file_operation(&mut host, "file_append_text", 2, 2, vec![text("é")]);
    assert_eq!(value(&first), Some(&json!(2)));
    let second = file_operation(
        &mut host,
        "file_append_bytes",
        2,
        2,
        vec![json!({"kind":"bytes","value":[121]})],
    );
    assert_eq!(value(&second), Some(&json!(1)));
    let content = std::fs::read(sandbox.work().join("n")).map_err(|error| error.to_string())?;
    assert_eq!(content, "xéy".as_bytes());
    Ok(())
}

#[test]
fn append_requires_write_rights_and_a_live_file_capability() -> Result<(), String> {
    let sandbox = Sandbox::new("append_denied")?;
    std::fs::write(sandbox.work().join("a"), "x").map_err(|error| error.to_string())?;
    let mut host = host_in(&sandbox);
    open_file(&mut host, "a", "read", 2, 1);
    let denied = file_operation(&mut host, "file_append_text", 2, 1, vec![text("z")]);
    assert_eq!(code(&denied), Some("permiso_denegado"));
    assert_eq!(
        std::fs::read_to_string(sandbox.work().join("a")).map_err(|error| error.to_string())?,
        "x"
    );
    file_operation(&mut host, "file_close", 2, 1, Vec::new());
    let closed = file_operation(&mut host, "file_append_text", 2, 1, vec![text("z")]);
    assert_eq!(code(&closed), Some("capacidad_cerrada"));
    let wrong = file_operation(&mut host, "file_append_text", 9, 2, vec![text("z")]);
    assert_eq!(code(&wrong), Some("capacidad_cerrada"));
    Ok(())
}
