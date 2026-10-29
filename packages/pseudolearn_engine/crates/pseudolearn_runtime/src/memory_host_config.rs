use crate::{HttpMethod, HttpResponseValue, IoError, MemoryHostProvider};
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
    http: BTreeMap<String, HttpScriptConfiguration>,
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
    #[serde(rename = "cancel_on_awaiting_effect")]
    _cancel_on_awaiting_effect: Option<u64>,
    #[serde(rename = "orden_entrega")]
    _delivery_order: Vec<u64>,
    #[serde(rename = "alterar_cinta")]
    _tape_alteration: Option<String>,
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
struct HttpScriptConfiguration {
    estado: Option<u16>,
    #[serde(default)]
    cabeceras: Vec<(String, String)>,
    cuerpo: Option<String>,
    cuerpo_bytes: Option<Vec<u8>>,
    fallo: Option<String>,
    #[serde(default)]
    incierto: bool,
}

#[derive(Deserialize)]
#[serde(deny_unknown_fields)]
struct SecretConfiguration {
    #[serde(rename = "key_id")]
    _key_id: String,
    #[serde(rename = "value")]
    _value: String,
}

const KNOWN_PERMISSIONS: [&str; 7] = [
    "consola",
    "argumentos",
    "archivos_lectura",
    "archivos_escritura",
    "reloj",
    "temporizador",
    "red",
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
    let http_scripts = parse_http_scripts(config.http)?;
    let mut provider = MemoryHostProvider {
        arguments: config.arguments,
        clocks: config.clock.into(),
        http_scripts,
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

fn parse_http_scripts(
    configurations: BTreeMap<String, HttpScriptConfiguration>,
) -> Result<BTreeMap<String, crate::memory_host::HttpScript>, IoError> {
    configurations
        .into_iter()
        .map(|(key, configuration)| {
            let script = parse_http_script(&key, configuration)?;
            Ok((key, script))
        })
        .collect()
}

fn parse_http_script(
    key: &str,
    configuration: HttpScriptConfiguration,
) -> Result<crate::memory_host::HttpScript, IoError> {
    let (method, url) = key.split_once(' ').ok_or_else(invalid)?;
    let method = HttpMethod::parse(method).ok_or_else(invalid)?;
    let parsed = crate::network_url::parse_url(url)?;
    let body = script_body(configuration.cuerpo, configuration.cuerpo_bytes)?;
    let failure = configuration
        .fallo
        .map(|code| failure(code, configuration.incierto, method))
        .transpose()?;
    let response = if failure.is_some() {
        if configuration.estado.is_some() || !configuration.cabeceras.is_empty() || !body.is_empty()
        {
            return Err(invalid());
        }
        None
    } else {
        let status = configuration.estado.ok_or_else(invalid)?;
        let response = HttpResponseValue {
            status,
            headers: configuration.cabeceras,
            body,
            final_url: parsed.without_fragment,
        };
        Some(response)
    };
    Ok(crate::memory_host::HttpScript { response, failure })
}

fn script_body(text: Option<String>, bytes: Option<Vec<u8>>) -> Result<Vec<u8>, IoError> {
    match (text, bytes) {
        (Some(value), None) => Ok(value.into_bytes()),
        (None, Some(value)) => Ok(value),
        (None, None) => Ok(Vec::new()),
        (Some(_), Some(_)) => Err(invalid()),
    }
}

fn failure(code: String, uncertain: bool, method: HttpMethod) -> Result<IoError, IoError> {
    let kind = IoErrorKind::ALL
        .into_iter()
        .find(|kind| kind.code() == code)
        .ok_or_else(invalid)?;
    if uncertain && matches!(method, HttpMethod::Get | HttpMethod::Head) {
        return Err(invalid());
    }
    Ok(IoError::new(kind, uncertain))
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
