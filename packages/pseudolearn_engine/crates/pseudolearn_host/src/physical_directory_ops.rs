use crate::physical_error::{HostError, committed};
use crate::physical_host::PhysicalHost;
use crate::physical_paths::DirectoryResource;
use crate::physical_request::{READ, Request, WRITE, checked_path};
use cap_std::fs::Dir;
use serde_json::{Value, json};
use std::io::ErrorKind;

impl PhysicalHost {
    pub(crate) fn directory_operation(&mut self, request: &Request) -> Result<Value, HostError> {
        let needed = if mutates_directory(&request.operation) {
            WRITE
        } else {
            READ
        };
        let (directory, rights) = crate::physical_files::directory_of(self.entry(request)?)?;
        if rights & needed == 0 {
            return Err(HostError::PERMISSION_DENIED);
        }
        match request.operation.as_str() {
            "directory_exists" => directory
                .exists(request.text(0)?)
                .map(|found| committed("boolean", json!(found))),
            "directory_is_directory" => directory
                .is_directory(request.text(0)?)
                .map(|found| committed("boolean", json!(found))),
            "directory_list" => directory
                .list(request.text(0)?)
                .map(|names| committed("text_list", json!(names))),
            "directory_delete" => directory
                .delete(request.text(0)?)
                .map(|()| committed("boolean", json!(true))),
            "directory_rename" => directory
                .rename(request.text(0)?, request.text(1)?)
                .map(|()| committed("boolean", json!(true))),
            "directory_create" => directory
                .create(request.text(0)?)
                .map(|()| committed("boolean", json!(true))),
            _ => Err(HostError::INTERRUPTED),
        }
    }
}

pub(crate) fn mutates_directory(operation: &str) -> bool {
    matches!(
        operation,
        "directory_delete" | "directory_rename" | "directory_create"
    )
}

impl DirectoryResource {
    fn confined_path<'path>(&self, path: &'path str) -> Result<&'path str, HostError> {
        match self {
            Self::Ambient(_) => Ok(path),
            Self::Confined(_) => checked_path(path),
        }
    }

    fn metadata(&self, path: &str) -> Result<Option<bool>, HostError> {
        let path = self.confined_path(path)?;
        let outcome = match self {
            Self::Ambient(directory) => {
                std::fs::metadata(directory.join(path)).map(|metadata| metadata.is_dir())
            }
            Self::Confined(directory) => directory.metadata(path).map(|metadata| metadata.is_dir()),
        };
        match outcome {
            Ok(is_directory) => Ok(Some(is_directory)),
            Err(error) if error.kind() == ErrorKind::NotFound => Ok(None),
            Err(error) => Err(HostError::from_io(&error)),
        }
    }

    fn entry_exists(&self, path: &str) -> Result<bool, HostError> {
        let outcome = match self {
            Self::Ambient(directory) => std::fs::symlink_metadata(directory.join(path)).map(drop),
            Self::Confined(directory) => directory.symlink_metadata(path).map(drop),
        };
        match outcome {
            Ok(()) => Ok(true),
            Err(error) if error.kind() == ErrorKind::NotFound => Ok(false),
            Err(error) => Err(HostError::from_io(&error)),
        }
    }

    pub(crate) fn exists(&self, path: &str) -> Result<bool, HostError> {
        Ok(self.metadata(path)?.is_some())
    }

    pub(crate) fn is_directory(&self, path: &str) -> Result<bool, HostError> {
        Ok(self.metadata(path)? == Some(true))
    }

    pub(crate) fn list(&self, path: &str) -> Result<Vec<String>, HostError> {
        let path = self.confined_path(path)?;
        let mut names = match self {
            Self::Ambient(directory) => names(std::fs::read_dir(directory.join(path))),
            Self::Confined(directory) => confined_names(directory, path),
        }?;
        names.sort();
        Ok(names)
    }

    pub(crate) fn delete(&self, path: &str) -> Result<(), HostError> {
        let is_directory = self.metadata(path)?.ok_or(HostError::NOT_FOUND)?;
        let outcome = match (self, is_directory) {
            (Self::Ambient(directory), true) => std::fs::remove_dir(directory.join(path)),
            (Self::Ambient(directory), false) => std::fs::remove_file(directory.join(path)),
            (Self::Confined(directory), true) => directory.remove_dir(path),
            (Self::Confined(directory), false) => directory.remove_file(path),
        };
        outcome.map_err(|error| HostError::from_io(&error))
    }

    pub(crate) fn rename(&self, source: &str, destination: &str) -> Result<(), HostError> {
        let source = self.confined_path(source)?;
        let destination = self.confined_path(destination)?;
        if !self.entry_exists(source)? {
            return Err(HostError::NOT_FOUND);
        }
        if self.entry_exists(destination)? {
            return Err(HostError::ALREADY_EXISTS);
        }
        let outcome = match self {
            Self::Ambient(directory) => {
                std::fs::rename(directory.join(source), directory.join(destination))
            }
            Self::Confined(directory) => directory.rename(source, directory, destination),
        };
        outcome.map_err(|error| HostError::from_io(&error))
    }

    pub(crate) fn create(&self, path: &str) -> Result<(), HostError> {
        let path = self.confined_path(path)?;
        let outcome = match self {
            Self::Ambient(directory) => std::fs::create_dir(directory.join(path)),
            Self::Confined(directory) => directory.create_dir(path),
        };
        outcome.map_err(|error| HostError::from_io(&error))
    }
}

fn confined_names(directory: &Dir, path: &str) -> Result<Vec<String>, HostError> {
    let entries = directory
        .read_dir(path)
        .map_err(|error| HostError::from_io(&error))?;
    entries
        .map(|entry| {
            let entry = entry.map_err(|error| HostError::from_io(&error))?;
            entry
                .file_name()
                .into_string()
                .map_err(|_| HostError::INVALID_UTF8)
        })
        .collect()
}

fn names(entries: std::io::Result<std::fs::ReadDir>) -> Result<Vec<String>, HostError> {
    let entries = entries.map_err(|error| HostError::from_io(&error))?;
    entries
        .map(|entry| {
            let entry = entry.map_err(|error| HostError::from_io(&error))?;
            entry
                .file_name()
                .into_string()
                .map_err(|_| HostError::INVALID_UTF8)
        })
        .collect()
}
