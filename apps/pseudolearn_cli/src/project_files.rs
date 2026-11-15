use crate::error::CliError;
use crate::messages::unreadable_input;
use cap_std::ambient_authority;
use cap_std::fs::Dir;
use pseudolearn_api::{logical_path_key, normalize_logical_path};
use std::collections::BTreeSet;
use std::io::Read;
use std::path::{Path, PathBuf};

pub(crate) const MANIFEST_NAME: &str = "pseudolearn.toml";
pub(crate) const LOCK_NAME: &str = "pseudolearn.lock";
const SOURCE_EXTENSION: &str = ".pseudo";

pub(crate) struct ManifestFile {
    pub location: String,
    pub text: String,
}

pub(crate) struct SourceFile {
    pub path: String,
    pub display: String,
    pub source_id: u32,
    pub text: String,
}

pub(crate) struct ProjectSnapshot {
    pub label: String,
    pub manifests: Vec<ManifestFile>,
    pub sources: Vec<SourceFile>,
    pub lock: Option<String>,
}

struct Scanner<'scan> {
    root: Dir,
    label: &'scan str,
    locale: &'scan str,
    active: BTreeSet<PathBuf>,
    seen: BTreeSet<String>,
    manifests: Vec<ManifestFile>,
    sources: Vec<(String, SourceFile)>,
    lock: Option<String>,
}

pub(crate) fn load(directory: &str, locale: &str) -> Result<ProjectSnapshot, CliError> {
    let root = Dir::open_ambient_dir(Path::new(directory), ambient_authority())
        .map_err(|_| unreadable(locale, directory))?;
    let mut scanner = Scanner {
        root,
        label: directory,
        locale,
        active: BTreeSet::new(),
        seen: BTreeSet::new(),
        manifests: Vec::new(),
        sources: Vec::new(),
        lock: None,
    };
    scanner.scan_directory("")?;
    Ok(scanner.finish())
}

impl Scanner<'_> {
    fn finish(mut self) -> ProjectSnapshot {
        self.sources.sort_by(|first, second| first.0.cmp(&second.0));
        self.manifests
            .sort_by(|first, second| first.location.cmp(&second.location));
        let mut identifier = 0_u32;
        let sources = self
            .sources
            .into_iter()
            .map(|(_, mut source)| {
                identifier = identifier.saturating_add(1);
                source.source_id = identifier;
                source
            })
            .collect();
        ProjectSnapshot {
            label: self.label.to_owned(),
            manifests: self.manifests,
            sources,
            lock: self.lock,
        }
    }

    fn failure(&self, path: &str) -> CliError {
        if path == self.label {
            return unreadable(self.locale, path);
        }
        let shown = format!("{}/{path}", self.label.trim_end_matches('/'));
        unreadable(self.locale, &shown)
    }

    fn scan_directory(&mut self, relative: &str) -> Result<(), CliError> {
        let target = if relative.is_empty() { "." } else { relative };
        let canonical = self
            .root
            .canonicalize(target)
            .map_err(|_| self.failure(self.label))?;
        if !self.active.insert(canonical.clone()) {
            return Err(self.failure(self.label));
        }
        let entries = self
            .root
            .read_dir(target)
            .map_err(|_| self.failure(self.label))?;
        for entry in entries {
            let entry = entry.map_err(|_| self.failure(self.label))?;
            let name = entry.file_name();
            let name = name.to_str().ok_or_else(|| self.failure(self.label))?;
            self.scan_entry(relative, name)?;
        }
        self.active.remove(&canonical);
        Ok(())
    }

    fn scan_entry(&mut self, parent: &str, name: &str) -> Result<(), CliError> {
        let relative = join(parent, name);
        let normalized =
            normalize_logical_path(&relative).ok_or_else(|| self.failure(&relative))?;
        let key = logical_path_key(&normalized).ok_or_else(|| self.failure(&relative))?;
        if !self.seen.insert(key.clone()) {
            return Err(self.failure(&relative));
        }
        let metadata = self
            .root
            .metadata(&relative)
            .map_err(|_| self.failure(&relative))?;
        if metadata.is_dir() {
            return self.scan_directory(&relative);
        }
        if metadata.is_file() {
            self.take_file(parent, name, (&normalized, key))?;
        }
        Ok(())
    }

    fn take_file(
        &mut self,
        parent: &str,
        name: &str,
        logical: (&str, String),
    ) -> Result<(), CliError> {
        let relative = join(parent, name);
        if name == MANIFEST_NAME {
            if parent.is_empty() {
                return Err(self.failure(&relative));
            }
            let text = self.read(&relative)?;
            self.manifests.push(ManifestFile {
                location: parent.to_owned(),
                text,
            });
        } else if name == LOCK_NAME && parent.is_empty() {
            self.lock = Some(self.read(&relative)?);
        } else if let Some(module) = logical.0.strip_suffix(SOURCE_EXTENSION) {
            let text = self.read(&relative)?;
            let display = format!("{}/{relative}", self.label.trim_end_matches('/'));
            self.sources.push((
                logical.1,
                SourceFile {
                    path: module.to_owned(),
                    display,
                    source_id: 0,
                    text,
                },
            ));
        }
        Ok(())
    }

    fn read(&self, relative: &str) -> Result<String, CliError> {
        let mut file = self
            .root
            .open(relative)
            .map_err(|_| self.failure(relative))?;
        let mut text = String::new();
        file.read_to_string(&mut text)
            .map_err(|_| self.failure(relative))?;
        Ok(text)
    }
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
