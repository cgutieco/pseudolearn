use crate::physical_host::PhysicalHost;
use cap_std::ambient_authority;
use cap_std::fs::Dir;
use serde_json::{Value, json};
use std::path::PathBuf;
use std::sync::atomic::{AtomicU64, Ordering};

static NEXT: AtomicU64 = AtomicU64::new(0);

struct Sandbox {
    base: PathBuf,
    granted: PathBuf,
}

impl Drop for Sandbox {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.base);
    }
}

fn sandbox() -> Result<Sandbox, String> {
    let base = std::env::temp_dir().join(format!(
        "pseudo-physical-{}-{}",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::SeqCst)
    ));
    let granted = base.join("granted");
    std::fs::create_dir_all(granted.join("sub")).map_err(|error| error.to_string())?;
    std::fs::write(granted.join("a.txt"), "hola").map_err(|error| error.to_string())?;
    std::fs::write(granted.join("sub/b.txt"), "dentro").map_err(|error| error.to_string())?;
    std::fs::write(base.join("secret.txt"), "afuera").map_err(|error| error.to_string())?;
    Ok(Sandbox { base, granted })
}

fn host(sandbox: &Sandbox, rights: u8) -> Result<PhysicalHost, String> {
    let directory = Dir::open_ambient_dir(&sandbox.granted, ambient_authority())
        .map_err(|error| error.to_string())?;
    Ok(PhysicalHost::new(Some((directory, rights))))
}

fn capability(slot: u32, rights: u8, kind: u32) -> Value {
    json!({"slot":slot,"generation":1,"rights":rights,"kind":kind})
}

fn text(value: &str) -> Value {
    json!({"kind":"text","value":value})
}

fn call(
    host: &mut PhysicalHost,
    operation: &str,
    receiver: Option<&Value>,
    (arguments, result): (Vec<Value>, Option<Value>),
) -> Value {
    host.perform(
        &json!({"effect_seq":1,"operation":operation,"receiver":receiver,
        "arguments":arguments,"result_capability":result,"source_node_id":1}),
    )
}

fn code(reply: &Value) -> Option<&str> {
    reply.pointer("/value/code").and_then(Value::as_str)
}

fn open_root(host: &mut PhysicalHost, rights: u8) -> Value {
    call(
        host,
        "request_directory",
        None,
        (vec![text("root")], Some(capability(0, rights, 2))),
    )
}

fn open_file(host: &mut PhysicalHost, path: &str, mode: &str, slot: u32) -> Value {
    call(
        host,
        "file_open",
        Some(&capability(0, 3, 2)),
        (vec![text(path), text(mode)], Some(capability(slot, 1, 3))),
    )
}

#[test]
fn reads_a_file_relative_to_the_granted_directory() -> Result<(), String> {
    let space = sandbox()?;
    let mut physical = host(&space, 3)?;
    assert_eq!(open_root(&mut physical, 3)["outcome"], "committed");
    assert_eq!(
        open_file(&mut physical, "a.txt", "read", 1)["outcome"],
        "committed"
    );
    let read = call(
        &mut physical,
        "file_read_text",
        Some(&capability(1, 1, 3)),
        (vec![], None),
    );
    assert_eq!(read.pointer("/value/value"), Some(&json!("hola")));
    Ok(())
}

#[test]
fn rejects_absolute_parent_and_nul_paths() -> Result<(), String> {
    let space = sandbox()?;
    let mut physical = host(&space, 3)?;
    open_root(&mut physical, 3);
    for path in [
        "/etc/passwd",
        "../secret.txt",
        "sub/../../secret.txt",
        "a\0b",
        "",
    ] {
        let reply = open_file(&mut physical, path, "read", 1);
        assert_eq!(code(&reply), Some("ruta_invalida"), "{path:?}");
    }
    Ok(())
}

#[cfg(unix)]
#[test]
fn rejects_outgoing_symbolic_links() -> Result<(), String> {
    let space = sandbox()?;
    std::os::unix::fs::symlink(space.base.join("secret.txt"), space.granted.join("escape"))
        .map_err(|error| error.to_string())?;
    let mut physical = host(&space, 3)?;
    open_root(&mut physical, 3);
    let reply = open_file(&mut physical, "escape", "read", 1);
    assert_eq!(code(&reply), Some("permiso_denegado"), "{reply}");
    Ok(())
}

#[test]
fn denies_amplification_beyond_the_granted_rights() -> Result<(), String> {
    let space = sandbox()?;
    let mut physical = host(&space, 1)?;
    assert_eq!(code(&open_root(&mut physical, 3)), Some("permiso_denegado"));
    assert_eq!(open_root(&mut physical, 1)["outcome"], "committed");
    let reply = call(
        &mut physical,
        "file_open",
        Some(&capability(0, 1, 2)),
        (
            vec![text("a.txt"), text("write")],
            Some(capability(1, 2, 3)),
        ),
    );
    assert_eq!(code(&reply), Some("permiso_denegado"));
    Ok(())
}

#[test]
fn attenuated_read_only_directory_cannot_write() -> Result<(), String> {
    let space = sandbox()?;
    let mut physical = host(&space, 3)?;
    open_root(&mut physical, 3);
    let derived = call(
        &mut physical,
        "directory_derive",
        Some(&capability(0, 3, 2)),
        (vec![text("sub"), text("read")], Some(capability(2, 1, 2))),
    );
    assert_eq!(derived["outcome"], "committed");
    let write = call(
        &mut physical,
        "file_open",
        Some(&capability(2, 1, 2)),
        (
            vec![text("b.txt"), text("write")],
            Some(capability(3, 2, 3)),
        ),
    );
    assert_eq!(code(&write), Some("permiso_denegado"));
    let read = call(
        &mut physical,
        "file_open",
        Some(&capability(2, 1, 2)),
        (vec![text("b.txt"), text("read")], Some(capability(3, 1, 3))),
    );
    assert_eq!(read["outcome"], "committed");
    Ok(())
}

#[test]
fn use_after_close_reports_a_closed_capability() -> Result<(), String> {
    let space = sandbox()?;
    let mut physical = host(&space, 3)?;
    open_root(&mut physical, 3);
    open_file(&mut physical, "a.txt", "read", 1);
    let closed = call(
        &mut physical,
        "file_close",
        Some(&capability(1, 1, 3)),
        (vec![], None),
    );
    assert_eq!(closed["outcome"], "committed");
    let read = call(
        &mut physical,
        "file_read_text",
        Some(&capability(1, 1, 3)),
        (vec![], None),
    );
    assert_eq!(code(&read), Some("capacidad_cerrada"));
    Ok(())
}

#[test]
fn write_replaces_content_on_disk_and_missing_file_is_not_found() -> Result<(), String> {
    let space = sandbox()?;
    let mut physical = host(&space, 3)?;
    open_root(&mut physical, 3);
    assert_eq!(
        open_file(&mut physical, "nuevo.txt", "write", 1)["outcome"],
        "committed"
    );
    let written = call(
        &mut physical,
        "file_write_text",
        Some(&capability(1, 2, 3)),
        (vec![text("contenido")], None),
    );
    assert_eq!(written.pointer("/value/value"), Some(&json!(9)));
    let on_disk = std::fs::read_to_string(space.granted.join("nuevo.txt"))
        .map_err(|error| error.to_string())?;
    assert_eq!(on_disk, "contenido");
    let missing = open_file(&mut physical, "falta.txt", "read", 2);
    assert_eq!(code(&missing), Some("no_encontrado"));
    Ok(())
}

#[test]
fn host_without_a_granted_directory_denies_the_root() {
    let mut physical = PhysicalHost::new(None);
    assert_eq!(code(&open_root(&mut physical, 1)), Some("permiso_denegado"));
}
