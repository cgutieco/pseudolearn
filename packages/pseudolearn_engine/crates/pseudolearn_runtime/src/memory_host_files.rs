use crate::{HostEffectRequest, HostValue, IoError, MemoryHostProvider};
use pseudolearn_abi::IoErrorKind;

pub(crate) fn valid_path(path: &str) -> bool {
    !path.is_empty() && !path.contains('\0')
}

pub(crate) fn request_path(
    provider: &MemoryHostProvider,
    request: &HostEffectRequest,
) -> Result<String, IoError> {
    let token = request
        .receiver
        .as_ref()
        .ok_or_else(IoError::permission_denied)?;
    let parent = provider
        .resources
        .get(&token.slot)
        .ok_or_else(|| IoError::from_kind(IoErrorKind::ClosedCapability))?;
    if matches!(
        request.operation.as_str(),
        "file_open"
            | "directory_derive"
            | "directory_exists"
            | "directory_is_directory"
            | "directory_list"
            | "directory_delete"
            | "directory_rename"
            | "directory_create"
    ) {
        let path = crate::memory_host::text(request, 0)?;
        let root = provider
            .directory_roots
            .get(&token.slot)
            .map(String::as_str);
        crate::host_paths::join(parent, path, root)
    } else {
        Ok(parent.clone())
    }
}

pub(crate) fn register(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
    path: String,
) -> Result<HostValue, IoError> {
    let capability = request
        .result_capability
        .as_ref()
        .ok_or_else(IoError::permission_denied)?
        .clone();
    let parent_root = request
        .receiver
        .as_ref()
        .and_then(|token| provider.directory_roots.get(&token.slot))
        .cloned();
    if request.operation == "directory_derive" {
        provider
            .directory_roots
            .insert(capability.slot, path.clone());
    } else if let Some(root) = parent_root {
        provider.directory_roots.insert(capability.slot, root);
    }
    provider.resources.insert(capability.slot, path);
    Ok(HostValue::Capability(capability))
}

fn derive_directory(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
    path: String,
) -> Result<HostValue, IoError> {
    if !crate::memory_host_directories::is_directory(provider, &path) {
        return Err(IoError::not_found());
    }
    register(provider, request, path)
}

fn read_text(provider: &MemoryHostProvider, path: &str) -> Result<HostValue, IoError> {
    let bytes = provider.read(path).map_err(IoError::from_kind)?;
    std::str::from_utf8(bytes)
        .map(|text| HostValue::Text(text.to_owned()))
        .map_err(|_| IoError::from_kind(IoErrorKind::InvalidUtf8))
}

fn is_directory_operation(operation: &str) -> bool {
    matches!(
        operation,
        "directory_exists"
            | "directory_is_directory"
            | "directory_list"
            | "directory_delete"
            | "directory_rename"
            | "directory_create"
    )
}

pub(crate) fn perform(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
) -> Result<HostValue, IoError> {
    if is_directory_operation(&request.operation) {
        return crate::memory_host_directories::perform(provider, request);
    }
    let path = request_path(provider, request)?;
    match request.operation.as_str() {
        "file_append_bytes" | "file_append_text" => {
            crate::memory_host_directories::append(provider, request, path)
        }
        "file_open" => open(provider, request, path),
        "directory_derive" => derive_directory(provider, request, path),
        "file_read_bytes" => provider
            .read(&path)
            .map(|bytes| HostValue::Bytes(bytes.to_vec()))
            .map_err(IoError::from_kind),
        "file_read_text" => read_text(provider, &path),
        "file_write_bytes" | "file_write_text" => write(provider, request, path),
        "file_close" | "directory_close" => {
            provider.resources.remove(
                &request
                    .receiver
                    .as_ref()
                    .ok_or_else(IoError::permission_denied)?
                    .slot,
            );
            Ok(HostValue::Boolean(true))
        }
        _ => Err(IoError::from_kind(IoErrorKind::Interrupted)),
    }
}

fn open(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
    path: String,
) -> Result<HostValue, IoError> {
    let rights = crate::effect_authority::mode_rights(request.arguments.last())?;
    if rights.write {
        provider.files.insert(path.clone(), Vec::new());
    } else if !provider.files.contains_key(&path) {
        return Err(IoError::not_found());
    }
    register(provider, request, path)
}

fn write(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
    path: String,
) -> Result<HostValue, IoError> {
    let bytes = match request.arguments.first() {
        Some(HostValue::Text(text)) => text.as_bytes().to_vec(),
        Some(HostValue::Bytes(bytes)) => bytes.clone(),
        _ => return Err(IoError::from_kind(IoErrorKind::InvalidPath)),
    };
    let count =
        i64::try_from(bytes.len()).map_err(|_| IoError::from_kind(IoErrorKind::Interrupted))?;
    provider.files.insert(path, bytes);
    Ok(HostValue::Integer(count))
}
