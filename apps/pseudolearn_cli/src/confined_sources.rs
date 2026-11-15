use crate::error::CliError;
use crate::messages::unreadable_input;
use cap_std::ambient_authority;
use cap_std::fs::{Dir, File};
use pseudolearn_api::{logical_path_key, normalize_logical_path};
use std::collections::BTreeSet;
use std::io::Read;
use std::path::{Path, PathBuf};

pub(crate) struct CheckSource {
    pub path: String,
    pub text: String,
}

struct PendingSource {
    path: String,
    order: String,
    text: String,
}

struct ScanContext<'context> {
    target: &'context str,
    locale: &'context str,
    active_directories: BTreeSet<PathBuf>,
    seen_routes: BTreeSet<String>,
    output: Vec<PendingSource>,
}

pub(crate) fn collect(paths: &[String], locale: &str) -> Result<Vec<CheckSource>, CliError> {
    let mut pending = Vec::new();
    for target in paths {
        collect_target(target, locale, &mut pending)?;
    }
    pending.sort_by(|first, second| {
        first
            .order
            .cmp(&second.order)
            .then_with(|| first.path.cmp(&second.path))
    });
    Ok(pending
        .into_iter()
        .map(|source| CheckSource {
            path: source.path,
            text: source.text,
        })
        .collect())
}

fn collect_target(
    target: &str,
    locale: &str,
    output: &mut Vec<PendingSource>,
) -> Result<(), CliError> {
    let path = Path::new(target);
    if let Ok(root) = Dir::open_ambient_dir(path, ambient_authority()) {
        let mut scan = ScanContext {
            target,
            locale,
            active_directories: BTreeSet::new(),
            seen_routes: BTreeSet::new(),
            output: Vec::new(),
        };
        scan.scan_directory(&root, "")?;
        output.extend(scan.output);
        return Ok(());
    }
    collect_file(path, target, locale, output)
}

fn collect_file(
    path: &Path,
    target: &str,
    locale: &str,
    output: &mut Vec<PendingSource>,
) -> Result<(), CliError> {
    let parent = path
        .parent()
        .filter(|parent| !parent.as_os_str().is_empty())
        .unwrap_or_else(|| Path::new("."));
    let Some(name) = path.file_name().and_then(|name| name.to_str()) else {
        return Err(unreadable(locale, target));
    };
    let root = Dir::open_ambient_dir(parent, ambient_authority())
        .map_err(|_| unreadable(locale, target))?;
    let content = read_open_file(&root, name).map_err(|_| unreadable(locale, target))?;
    let order = logical_path_key(name).ok_or_else(|| unreadable(locale, target))?;
    output.push(PendingSource {
        path: target.to_owned(),
        order,
        text: content,
    });
    Ok(())
}

impl ScanContext<'_> {
    fn scan_directory(&mut self, root: &Dir, relative: &str) -> Result<(), CliError> {
        let canonical = root
            .canonicalize(if relative.is_empty() { "." } else { relative })
            .map_err(|_| unreadable(self.locale, self.target))?;
        if !self.active_directories.insert(canonical.clone()) {
            return Err(unreadable(self.locale, self.target));
        }
        let entries = if relative.is_empty() {
            root.entries()
        } else {
            root.read_dir(relative)
        }
        .map_err(|_| unreadable(self.locale, self.target))?;
        for entry in entries {
            let entry = entry.map_err(|_| unreadable(self.locale, self.target))?;
            self.scan_entry(root, relative, &entry.file_name())?;
        }
        self.active_directories.remove(&canonical);
        Ok(())
    }

    fn scan_entry(
        &mut self,
        root: &Dir,
        parent: &str,
        name: &std::ffi::OsStr,
    ) -> Result<(), CliError> {
        let Some(name) = utf8_component(name) else {
            return Err(unreadable(self.locale, self.target));
        };
        let relative = join(parent, name);
        let normalized = normalize_logical_path(&relative)
            .ok_or_else(|| unreadable(self.locale, self.target))?;
        let route_key =
            logical_path_key(&normalized).ok_or_else(|| unreadable(self.locale, self.target))?;
        if !register_route(&mut self.seen_routes, route_key.clone()) {
            return Err(unreadable(self.locale, self.target));
        }
        let metadata = root
            .metadata(&relative)
            .map_err(|_| unreadable(self.locale, self.target))?;
        if metadata.is_dir() {
            return self.scan_directory(root, &relative);
        }
        if metadata.is_file()
            && Path::new(name)
                .extension()
                .is_some_and(|extension| extension == "pseudo")
        {
            let text = read_open_file(root, &relative)
                .map_err(|_| unreadable(self.locale, self.target))?;
            self.output.push(PendingSource {
                path: format!("{}/{relative}", self.target),
                order: route_key,
                text,
            });
        }
        Ok(())
    }
}

pub(super) fn register_route(seen_routes: &mut BTreeSet<String>, key: String) -> bool {
    seen_routes.insert(key)
}

pub(super) fn utf8_component(name: &std::ffi::OsStr) -> Option<&str> {
    name.to_str()
}

fn read_open_file(root: &Dir, relative: &str) -> Result<String, std::io::Error> {
    let mut file = open_file(root, relative)?;
    let mut text = String::new();
    file.read_to_string(&mut text)?;
    Ok(text)
}

pub(super) fn open_file(root: &Dir, relative: &str) -> Result<File, std::io::Error> {
    root.open(relative)
}

fn join(parent: &str, name: &str) -> String {
    if parent.is_empty() {
        name.to_owned()
    } else {
        format!("{parent}/{name}")
    }
}

fn unreadable(locale: &str, path: &str) -> CliError {
    CliError::Operational(unreadable_input(locale, path))
}
