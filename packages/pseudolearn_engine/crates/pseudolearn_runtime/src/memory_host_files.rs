use crate::{HostEffectRequest, HostValue, IoError, MemoryHostProvider};
use pseudolearn_abi::IoErrorKind;

pub(crate) fn valid_path(path: &str) -> bool {
    !path.is_empty()
        && !path.starts_with('/')
        && !path.contains(['\\', ':', '\0'])
        && path.split('/').all(|part| !["", ".", ".."].contains(&part))
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
    if matches!(request.operation.as_str(), "file_open" | "directory_derive") {
        let path = crate::memory_host::text(request, 0)?;
        if !valid_path(path) {
            return Err(IoError::from_kind(IoErrorKind::InvalidPath));
        }
        Ok(if parent.is_empty() {
            path.to_owned()
        } else {
            format!("{parent}/{path}")
        })
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
    provider.resources.insert(capability.slot, path);
    Ok(HostValue::Capability(capability))
}

fn derive_directory(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
    path: String,
) -> Result<HostValue, IoError> {
    let prefix = format!("{path}/");
    if !provider.files.keys().any(|file| file.starts_with(&prefix)) {
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

pub(crate) fn perform(
    provider: &mut MemoryHostProvider,
    request: &HostEffectRequest,
) -> Result<HostValue, IoError> {
    let path = request_path(provider, request)?;
    match request.operation.as_str() {
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
