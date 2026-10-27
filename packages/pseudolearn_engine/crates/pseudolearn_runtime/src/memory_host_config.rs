use crate::{IoError, MemoryHostProvider};
use pseudolearn_abi::IoErrorKind;
use serde::Deserialize;
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Default, Deserialize)]
#[serde(default, deny_unknown_fields)]
struct Configuration {
    files: BTreeMap<String, Value>,
    #[serde(rename = "args")]
    arguments: Vec<String>,
    clock: Vec<u64>,
    permissions: Vec<String>,
    requested_permissions: Option<Vec<String>>,
    faults: Vec<FaultConfiguration>,
    #[serde(rename = "secrets")]
    _secrets: BTreeMap<String, SecretConfiguration>,
    #[serde(rename = "secret_keys")]
    _secret_keys: BTreeMap<String, String>,
    #[serde(rename = "grabar_y_reproducir")]
    _record_and_replay: bool,
    #[serde(rename = "max_tape_bytes")]
    _max_tape_bytes: Option<usize>,
    #[serde(rename = "detached")]
    _detached: bool,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct FaultConfiguration {
    operation: String,
    path: Option<String>,
    code: String,
    #[serde(default)]
    uncertain: bool,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct SecretConfiguration {
    #[serde(rename = "key_id")]
    _key_id: String,
    #[serde(rename = "value")]
    _value: String,
}

const KNOWN_PERMISSIONS: [&str; 6] = [
    "consola",
    "argumentos",
    "archivos_lectura",
    "archivos_escritura",
    "reloj",
    "temporizador",
];

pub(crate) fn parse(value: &Value) -> Result<MemoryHostProvider, IoError> {
    let config: Configuration = serde_json::from_value(value.clone()).map_err(|_| invalid())?;
    let mut permissions = config
        .permissions
        .iter()
        .chain(config.requested_permissions.iter().flatten());
    if permissions.any(|permission| !KNOWN_PERMISSIONS.contains(&permission.as_str())) {
        return Err(invalid());
    }
    crate::secret_policy::SecretPolicy::from_host(Some(value))?;
    let mut provider = MemoryHostProvider {
        arguments: config.arguments,
        clocks: config.clock.into(),
        ..Default::default()
    };
    for (path, value) in config.files {
        provider
            .write(path, bytes(&value)?)
            .map_err(IoError::from_kind)?;
    }
    for fault in config.faults {
        provider.faults.push(memory_fault(fault)?);
    }
    Ok(provider)
}

fn memory_fault(fault: FaultConfiguration) -> Result<crate::memory_host::MemoryFault, IoError> {
    let kind = IoErrorKind::ALL
        .into_iter()
        .find(|kind| kind.code() == fault.code)
        .ok_or_else(invalid)?;
    let valid_path = fault
        .path
        .as_deref()
        .is_none_or(crate::memory_host_files::valid_path);
    if !valid_path {
        return Err(invalid());
    }
    Ok(crate::memory_host::MemoryFault {
        operation: fault.operation,
        path: fault.path,
        error: IoError::new(kind, fault.uncertain),
    })
}

fn bytes(value: &Value) -> Result<Vec<u8>, IoError> {
    if let Some(text) = value.as_str() {
        return Ok(text.as_bytes().to_vec());
    }
    value
        .as_array()
        .ok_or_else(invalid)?
        .iter()
        .map(|byte| {
            byte.as_u64()
                .and_then(|byte| u8::try_from(byte).ok())
                .ok_or_else(invalid)
        })
        .collect()
}

fn invalid() -> IoError {
    IoError::from_kind(IoErrorKind::InvalidPath)
}
