use object::read::archive::ArchiveFile;
use object::{Object, ObjectSymbol};
use std::collections::BTreeSet;
use std::io::{Error, Result};
use std::path::{Path, PathBuf};

const LIBRARIES: &[(&str, &[&str])] = &[
    (
        "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation",
        &["_CF", "_kCF", "___CF"],
    ),
    (
        "/System/Library/Frameworks/Security.framework/Versions/A/Security",
        &["_Sec", "_kSec"],
    ),
];
const SYSTEM_LIBRARY: &str = "/usr/lib/libSystem.B.dylib";
const STUB_BINDER: &str = "dyld_stub_binder";

pub(crate) fn write_stubs(
    (object_bytes, archive_bytes): (&[u8], &[u8]),
    architecture: &str,
    directory: &Path,
) -> Result<Vec<PathBuf>> {
    let undefined = undefined_symbols(object_bytes, archive_bytes)?;
    let mut paths = Vec::new();
    let mut remaining: BTreeSet<String> = undefined;
    remaining.insert(STUB_BINDER.to_owned());
    for (index, (install_name, prefixes)) in LIBRARIES.iter().enumerate() {
        let owned: BTreeSet<String> = remaining
            .iter()
            .filter(|symbol| prefixes.iter().any(|prefix| symbol.starts_with(prefix)))
            .cloned()
            .collect();
        remaining.retain(|symbol| !owned.contains(symbol));
        let path = directory.join(format!("framework{index}.tbd"));
        std::fs::write(&path, stub(install_name, architecture, &owned))?;
        paths.push(path);
    }
    let path = directory.join("system.tbd");
    std::fs::write(&path, stub(SYSTEM_LIBRARY, architecture, &remaining))?;
    paths.push(path);
    Ok(paths)
}

fn stub(install_name: &str, architecture: &str, symbols: &BTreeSet<String>) -> String {
    let listed: Vec<String> = symbols.iter().map(|symbol| format!("'{symbol}'")).collect();
    format!(
        "--- !tapi-tbd\ntbd-version: 4\ntargets: [ {architecture}-macos ]\ninstall-name: '{install_name}'\nexports:\n  - targets: [ {architecture}-macos ]\n    symbols: [ {} ]\n...\n",
        listed.join(", ")
    )
}

fn undefined_symbols(object_bytes: &[u8], archive_bytes: &[u8]) -> Result<BTreeSet<String>> {
    let mut defined = BTreeSet::new();
    let mut referenced = BTreeSet::new();
    collect(object_bytes, (&mut defined, &mut referenced))?;
    let archive = ArchiveFile::parse(archive_bytes).map_err(Error::other)?;
    for member in archive.members() {
        let member = member.map_err(Error::other)?;
        let bytes = member.data(archive_bytes).map_err(Error::other)?;
        if object::File::parse(bytes).is_ok() {
            collect(bytes, (&mut defined, &mut referenced))?;
        }
    }
    Ok(referenced.difference(&defined).cloned().collect())
}

fn collect(
    bytes: &[u8],
    (defined, referenced): (&mut BTreeSet<String>, &mut BTreeSet<String>),
) -> Result<()> {
    let file = object::File::parse(bytes).map_err(Error::other)?;
    for symbol in file.symbols() {
        let Ok(name) = symbol.name() else { continue };
        if symbol.is_undefined() {
            referenced.insert(name.to_owned());
        } else if symbol.is_global() {
            defined.insert(name.to_owned());
        }
    }
    Ok(())
}
