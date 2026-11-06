use std::collections::BTreeMap;
use std::io::{Error, Result};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

pub(crate) fn definitions(imports: &str) -> BTreeMap<String, String> {
    let mut grouped: BTreeMap<String, Vec<&str>> = BTreeMap::new();
    for line in imports.lines() {
        if let Some((library, symbol)) = line.split_once('\t') {
            grouped
                .entry(library.to_ascii_lowercase())
                .or_default()
                .push(symbol);
        }
    }
    grouped
        .into_iter()
        .map(|(library, symbols)| {
            let mut text = format!("LIBRARY {library}\nEXPORTS\n");
            for symbol in symbols {
                text.push_str("  ");
                text.push_str(symbol);
                text.push('\n');
            }
            (library, text)
        })
        .collect()
}

pub(crate) fn write_import_libraries(
    linker: &Path,
    (imports, architecture): (&str, &str),
    directory: &Path,
) -> Result<Vec<PathBuf>> {
    let mut libraries = Vec::new();
    for (library, text) in definitions(imports) {
        let stem = library.trim_end_matches(".dll");
        let definition = directory.join(format!("{stem}.def"));
        let output = directory.join(format!("{stem}.lib"));
        std::fs::write(&definition, text)?;
        let mut out_flag = std::ffi::OsString::from("/out:");
        out_flag.push(&output);
        let mut def_flag = std::ffi::OsString::from("/def:");
        def_flag.push(&definition);
        let status = Command::new(linker)
            .args(["-flavor", "link", "/lib"])
            .arg(def_flag)
            .arg(format!("/machine:{architecture}"))
            .arg(out_flag)
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()?;
        if !status.success() {
            return Err(Error::other(format!("import library for {library} failed")));
        }
        libraries.push(output);
    }
    Ok(libraries)
}

#[cfg(test)]
#[path = "native_link_imports_tests.rs"]
mod native_link_imports_tests;
