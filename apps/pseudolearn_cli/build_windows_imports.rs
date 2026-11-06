use object::read::archive::ArchiveFile;
use object::read::pe::PeFile64;
use object::{Object, ObjectSymbol};
use std::collections::BTreeSet;
use std::fmt::Write;
use std::path::PathBuf;

type BuildResult<Value> = Result<Value, Box<dyn std::error::Error>>;

const IMPORT_PREFIX: &str = "__imp_";
const PROVIDED_AT_LINK: &[&str] = &[
    "main",
    "mainCRTStartup",
    "_tls_used",
    "_tls_index",
    "_fltused",
    "__ImageBase",
];
const SYSTEM_LIBRARIES: &[&str] = &[
    "kernel32.dll",
    "kernelbase.dll",
    "ntdll.dll",
    "advapi32.dll",
    "ws2_32.dll",
    "bcrypt.dll",
    "bcryptprimitives.dll",
    "userenv.dll",
    "crypt32.dll",
    "secur32.dll",
    "ncrypt.dll",
    "ole32.dll",
    "oleaut32.dll",
    "shell32.dll",
    "msvcrt.dll",
    "ucrtbase.dll",
];

pub fn resolve_imports(archive: &[u8]) -> BuildResult<String> {
    let libraries = system_exports()?;
    let mut resolved = BTreeSet::new();
    let mut unresolved = Vec::new();
    for symbol in undefined_symbols(archive)? {
        let name = symbol.strip_prefix(IMPORT_PREFIX).unwrap_or(&symbol);
        if PROVIDED_AT_LINK.contains(&name) {
            continue;
        }
        match libraries.iter().find(|(_, exports)| exports.contains(name)) {
            Some((library, _)) => {
                resolved.insert(((*library).to_owned(), name.to_owned()));
            }
            None => unresolved.push(name.to_owned()),
        }
    }
    if !unresolved.is_empty() {
        return Err(format!("unresolved Windows imports: {}", unresolved.join(", ")).into());
    }
    let mut lines = String::new();
    for (library, name) in resolved {
        writeln!(lines, "{library}\t{name}")?;
    }
    Ok(lines)
}

fn system_exports() -> BuildResult<Vec<(&'static str, BTreeSet<String>)>> {
    let root = std::env::var_os("SystemRoot").ok_or("SystemRoot is not set")?;
    let system = PathBuf::from(root).join("System32");
    let mut libraries = Vec::new();
    for library in SYSTEM_LIBRARIES {
        let Ok(bytes) = std::fs::read(system.join(library)) else {
            continue;
        };
        libraries.push((*library, export_names(&bytes)?));
    }
    Ok(libraries)
}

fn export_names(bytes: &[u8]) -> BuildResult<BTreeSet<String>> {
    let file = PeFile64::parse(bytes)?;
    let mut names = BTreeSet::new();
    if let Some(table) = file.export_table()? {
        for (pointer, _) in table.name_iter() {
            names.insert(String::from_utf8_lossy(table.name_from_pointer(pointer)?).into_owned());
        }
    }
    Ok(names)
}

fn undefined_symbols(archive: &[u8]) -> BuildResult<BTreeSet<String>> {
    let mut defined = BTreeSet::new();
    let mut referenced = BTreeSet::new();
    let parsed = ArchiveFile::parse(archive)?;
    for member in parsed.members() {
        let bytes = member?.data(archive)?;
        let Ok(file) = object::File::parse(bytes) else {
            continue;
        };
        for symbol in file.symbols() {
            let Ok(name) = symbol.name() else { continue };
            if symbol.is_undefined() {
                referenced.insert(name.to_owned());
            } else if symbol.is_global() {
                defined.insert(name.to_owned());
            }
        }
    }
    Ok(referenced.difference(&defined).cloned().collect())
}
