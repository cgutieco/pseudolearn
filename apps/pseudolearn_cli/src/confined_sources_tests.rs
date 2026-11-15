use crate::confined_sources::{collect, open_file, register_route, utf8_component};
use cap_std::ambient_authority;
use cap_std::fs::Dir;
use pseudolearn_api::logical_path_key;
use std::collections::BTreeSet;
use std::io::Read;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicU64, Ordering};

static NEXT_DIRECTORY: AtomicU64 = AtomicU64::new(0);

fn directory() -> Result<PathBuf, std::io::Error> {
    let sequence = NEXT_DIRECTORY.fetch_add(1, Ordering::Relaxed);
    let path = std::env::temp_dir().join(format!("pseudo-check-{}-{sequence}", std::process::id()));
    std::fs::create_dir_all(&path)?;
    Ok(path)
}

fn remove(path: &Path) {
    let _ = std::fs::remove_dir_all(path);
}

#[test]
fn reads_all_source_bytes_and_sorts_by_portable_relative_path() -> Result<(), String> {
    let root = directory().map_err(|error| error.to_string())?;
    std::fs::write(root.join("Z.pseudo"), "Algoritmo Z\nFinAlgoritmo\n")
        .map_err(|error| error.to_string())?;
    std::fs::write(root.join("a.pseudo"), "Algoritmo A\nFinAlgoritmo\n")
        .map_err(|error| error.to_string())?;
    let target = root
        .to_str()
        .ok_or("temporary path is not UTF-8")?
        .to_owned();
    let sources =
        collect(std::slice::from_ref(&target), "es").map_err(|error| format!("{error:?}"))?;
    assert!(sources[0].path.ends_with("/a.pseudo"));
    assert!(sources[1].path.ends_with("/Z.pseudo"));
    assert!(sources[0].text.starts_with("Algoritmo A"));
    remove(&root);
    Ok(())
}

#[cfg(unix)]
#[test]
fn rejects_external_symlinks_before_returning_any_sources() -> Result<(), String> {
    use std::os::unix::fs::symlink;

    let root = directory().map_err(|error| error.to_string())?;
    let outside = directory().map_err(|error| error.to_string())?;
    std::fs::write(root.join("safe.pseudo"), "Algoritmo S\nFinAlgoritmo\n")
        .map_err(|error| error.to_string())?;
    std::fs::write(outside.join("outside.pseudo"), "secret").map_err(|error| error.to_string())?;
    symlink(outside.join("outside.pseudo"), root.join("escape.pseudo"))
        .map_err(|error| error.to_string())?;
    symlink(&outside, root.join("escape_directory")).map_err(|error| error.to_string())?;
    let target = root
        .to_str()
        .ok_or("temporary path is not UTF-8")?
        .to_owned();
    assert!(collect(std::slice::from_ref(&target), "es").is_err());
    let outside_target = outside
        .to_str()
        .ok_or("temporary path is not UTF-8")?
        .to_owned();
    assert!(collect(&[target.clone(), outside_target.clone()], "es").is_err());
    let separately_granted = collect(std::slice::from_ref(&outside_target), "es")
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(separately_granted.len(), 1);
    remove(&root);
    remove(&outside);
    Ok(())
}

#[cfg(unix)]
#[test]
fn permits_in_root_file_symlinks_and_rejects_directory_cycles() -> Result<(), String> {
    use std::os::unix::fs::symlink;

    let root = directory().map_err(|error| error.to_string())?;
    std::fs::write(root.join("real.pseudo"), "Algoritmo R\nFinAlgoritmo\n")
        .map_err(|error| error.to_string())?;
    std::fs::create_dir(root.join("nested")).map_err(|error| error.to_string())?;
    std::fs::write(
        root.join("nested/inside.pseudo"),
        "Algoritmo I\nFinAlgoritmo\n",
    )
    .map_err(|error| error.to_string())?;
    symlink("../real.pseudo", root.join("nested/parent_alias.pseudo"))
        .map_err(|error| error.to_string())?;
    symlink("real.pseudo", root.join("alias.pseudo")).map_err(|error| error.to_string())?;
    symlink("nested", root.join("nested_alias")).map_err(|error| error.to_string())?;
    let target = root
        .to_str()
        .ok_or("temporary path is not UTF-8")?
        .to_owned();
    let sources =
        collect(std::slice::from_ref(&target), "es").map_err(|error| format!("{error:?}"))?;
    assert_eq!(sources.len(), 6);

    symlink(".", root.join("cycle")).map_err(|error| error.to_string())?;
    assert!(collect(&[target], "es").is_err());
    remove(&root);
    Ok(())
}

#[cfg(unix)]
#[test]
fn reads_the_open_descriptor_after_its_symlink_is_replaced() -> Result<(), String> {
    use std::os::unix::fs::symlink;

    let root = directory().map_err(|error| error.to_string())?;
    std::fs::write(root.join("first"), "first bytes").map_err(|error| error.to_string())?;
    std::fs::write(root.join("second"), "second bytes").map_err(|error| error.to_string())?;
    symlink("first", root.join("source")).map_err(|error| error.to_string())?;
    let opened =
        Dir::open_ambient_dir(&root, ambient_authority()).map_err(|error| error.to_string())?;
    let mut descriptor = open_file(&opened, "source").map_err(|error| error.to_string())?;
    std::fs::remove_file(root.join("source")).map_err(|error| error.to_string())?;
    symlink("second", root.join("source")).map_err(|error| error.to_string())?;
    let mut content = String::new();
    descriptor
        .read_to_string(&mut content)
        .map_err(|error| error.to_string())?;
    assert_eq!(content, "first bytes");
    remove(&root);
    Ok(())
}

#[cfg(unix)]
#[test]
fn rejects_external_target_when_symlink_changes_before_open() -> Result<(), String> {
    use std::os::unix::fs::symlink;

    let root = directory().map_err(|error| error.to_string())?;
    let outside = directory().map_err(|error| error.to_string())?;
    std::fs::write(root.join("first"), "first bytes").map_err(|error| error.to_string())?;
    std::fs::write(outside.join("secret"), "secret bytes").map_err(|error| error.to_string())?;
    symlink("first", root.join("source")).map_err(|error| error.to_string())?;
    let opened =
        Dir::open_ambient_dir(&root, ambient_authority()).map_err(|error| error.to_string())?;
    std::fs::remove_file(root.join("source")).map_err(|error| error.to_string())?;
    symlink(outside.join("secret"), root.join("source")).map_err(|error| error.to_string())?;
    assert!(open_file(&opened, "source").is_err());
    remove(&root);
    remove(&outside);
    Ok(())
}

#[cfg(unix)]
#[test]
fn rejects_non_utf8_names_without_lossy_conversion() {
    use std::os::unix::ffi::OsStringExt;

    let name =
        std::ffi::OsString::from_vec(vec![0x66, 0x80, 0x2e, 0x70, 0x73, 0x65, 0x75, 0x64, 0x6f]);
    assert_eq!(utf8_component(&name), None);
}

#[test]
fn rejects_portable_collisions_for_case_and_unicode_normalization() -> Result<(), String> {
    let mut routes = BTreeSet::new();
    let first_key = logical_path_key("src/Café.pseudo").ok_or("first route is invalid")?;
    let second_key = logical_path_key("SRC/cafe\u{301}.PSEUDO").ok_or("second route is invalid")?;
    assert_eq!(first_key, second_key);
    assert!(register_route(&mut routes, first_key.clone(),));
    assert!(!register_route(&mut routes, second_key,));
    Ok(())
}
