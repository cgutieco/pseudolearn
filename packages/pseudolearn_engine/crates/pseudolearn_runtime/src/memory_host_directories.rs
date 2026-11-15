use crate::{HostEffectRequest, HostValue, IoError, MemoryHostProvider};
use pseudolearn_abi::IoErrorKind;
use std::collections::BTreeSet;

pub(crate) fn is_directory(provider: &MemoryHostProvider, path: &str) -> bool {
    path.is_empty() || provider.directories.contains(path) || has_descendant(provider, path)
}

fn has_descendant(provider: &MemoryHostProvider, path: &str) -> bool {
    let prefix = format!("{path}/");
    provider.files.keys().any(|file| file.starts_with(&prefix))
        || provider
            .directories
            .iter()
            .any(|directory| directory.starts_with(&prefix))
}

fn exists(provider: &MemoryHostProvider, path: &str) -> bool {
    provider.files.contains_key(path) || is_directory(provider, path)
}

fn invalid_path() -> IoError {
    IoError::from_kind(IoErrorKind::InvalidPath)
}

fn parent_of(path: &str) -> &str {
    path.rsplit_once('/').map_or("", |(parent, _)| parent)
}

fn require_parent_directory(provider: &MemoryHostProvider, path: &str) -> Result<(), IoError> {
    let parent = parent_of(path);
    if is_directory(provider, parent) {
        Ok(())
    } else if provider.files.contains_key(parent) {
        Err(invalid_path())
    } else {
        Err(IoError::not_found())
    }
}

fn list(provider: &MemoryHostProvider, path: &str) -> Result<HostValue, IoError> {
    if !is_directory(provider, path) {
        return Err(if provider.files.contains_key(path) {
            invalid_path()
        } else {
            IoError::not_found()
        });
    }
    let prefix = if path.is_empty() {
        String::new()
    } else {
        format!("{path}/")
    };
    let names: BTreeSet<String> = provider
        .files
        .keys()
        .chain(provider.directories.iter())
        .filter_map(|entry| entry.strip_prefix(&prefix))
        .filter_map(|rest| rest.split('/').next())
        .filter(|name| !name.is_empty())
        .map(str::to_owned)
        .collect();
    Ok(HostValue::TextList(names.into_iter().collect()))
}

fn delete(provider: &mut MemoryHostProvider, path: &str) -> Result<HostValue, IoError> {
    if path.is_empty() {
        return Err(invalid_path());
    }
    if provider.files.remove(path).is_some() {
        return Ok(HostValue::Boolean(true));
    }
    if !is_directory(provider, path) {
        return Err(IoError::not_found());
    }
    if has_descendant(provider, path) {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    }
    provider.directories.remove(path);
    Ok(HostValue::Boolean(true))
}

fn create(provider: &mut MemoryHostProvider, path: &str) -> Result<HostValue, IoError> {
    if exists(provider, path) {
        return Err(IoError::from_kind(IoErrorKind::AlreadyExists));
    }
    require_parent_directory(provider, path)?;
    provider.directories.insert(path.to_owned());
    Ok(HostValue::Boolean(true))
}

fn rename(
    provider: &mut MemoryHostProvider,
    source: &str,
    destination: &str,
) -> Result<HostValue, IoError> {
    if source.is_empty() || destination.is_empty() {
        return Err(invalid_path());
    }
    if !exists(provider, source) {
        return Err(IoError::not_found());
    }
    if exists(provider, destination) {
        return Err(IoError::from_kind(IoErrorKind::AlreadyExists));
    }
    require_parent_directory(provider, destination)?;
    if let Some(content) = provider.files.remove(source) {
        provider.files.insert(destination.to_owned(), content);
        return Ok(HostValue::Boolean(true));
    }
    if destination.starts_with(&format!("{source}/")) {
        return Err(invalid_path());
    }
    move_directory(provider, source, destination);
    Ok(HostValue::Boolean(true))
}

fn move_directory(provider: &mut MemoryHostProvider, source: &str, destination: &str) {
    let prefix = format!("{source}/");
    let moved_files: Vec<String> = provider
        .files
        .keys()
        .filter(|file| file.starts_with(&prefix))
        .cloned()
        .collect();
    for file in moved_files {
        if let Some(content) = provider.files.remove(&file) {
            provider
                .files
                .insert(format!("{destination}/{}", &file[prefix.len()..]), content);
        }
    }
    let moved_directories: Vec<String> = provider
        .directories
        .iter()
        .filter(|directory| directory.as_str() == source || directory.starts_with(&prefix))
        .cloned()
        .collect();
    for directory in moved_directories {
        provider.directories.remove(&directory);
        provider
            .directories
            .insert(format!("{destination}{}", &directory[source.len()..]));
    }
    provider.directories.insert(destination.to_owned());
}

pub(crate) fn join_argument(
    provider: &MemoryHostProvider,
    request: &HostEffectRequest,
    index: usize,
) -> Result<String, IoError> {
    let token = request
        .receiver
        .as_ref()
        .ok_or_else(IoError::permission_denied)?;
    let parent = provider
        .resources
        .get(&token.slot)
        .ok_or_else(|| IoError::from_kind(IoErrorKind::ClosedCapability))?;
    let root = provider
        .directory_roots
        .get(&token.slot)
        .map(String::as_str);
    crate::host_paths::join(parent, crate::memory_host::text(request, index)?, root)
}

pub(crate) fn perform(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
) -> Result<HostValue, IoError> {
    let path = join_argument(provider, request, 0)?;
    match request.operation.as_str() {
        "directory_exists" => Ok(HostValue::Boolean(exists(provider, &path))),
        "directory_is_directory" => Ok(HostValue::Boolean(is_directory(provider, &path))),
        "directory_list" => list(provider, &path),
        "directory_delete" => delete(provider, &path),
        "directory_create" => create(provider, &path),
        "directory_rename" => {
            let target = join_argument(provider, request, 1)?;
            rename(provider, &path, &target)
        }
        _ => Err(IoError::from_kind(IoErrorKind::Interrupted)),
    }
}

pub(crate) fn append(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
    path: String,
) -> Result<HostValue, IoError> {
    let bytes = match request.arguments.first() {
        Some(HostValue::Text(text)) => text.as_bytes().to_vec(),
        Some(HostValue::Bytes(bytes)) => bytes.clone(),
        _ => return Err(invalid_path()),
    };
    let count =
        i64::try_from(bytes.len()).map_err(|_| IoError::from_kind(IoErrorKind::Interrupted))?;
    provider.files.entry(path).or_default().extend(bytes);
    Ok(HostValue::Integer(count))
}
