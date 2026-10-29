use crate::{
    CapabilityKind, CapabilityTable, CapabilityToken, HostEffectRequest, HostValue, IoError,
    RightsMask,
};
use pseudolearn_abi::{EffectOperation, EffectValueKind, IoErrorKind};
use std::collections::{BTreeMap, BTreeSet};

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub(crate) struct EffectAuthority {
    pub(crate) table: CapabilityTable,
    pub(crate) permissions: BTreeSet<String>,
    pub(crate) granted_network_origins: BTreeSet<String>,
    pub(crate) network_capabilities: BTreeMap<u32, BTreeSet<String>>,
    pub(crate) network_limits: crate::NetworkLimits,
}

pub fn effective_permissions(host: Option<&serde_json::Value>) -> BTreeSet<String> {
    let names = |key| {
        host.and_then(|host| host.get(key))
            .and_then(serde_json::Value::as_array)
            .into_iter()
            .flatten()
            .filter_map(serde_json::Value::as_str)
            .map(str::to_owned)
            .collect::<BTreeSet<_>>()
    };
    let granted = names("permissions");
    if host.is_some_and(|host| host.get("requested_permissions").is_some()) {
        granted
            .intersection(&names("requested_permissions"))
            .cloned()
            .collect()
    } else {
        granted
    }
}

pub(crate) fn prepare(
    authority: &mut EffectAuthority,
    operation: &EffectOperation,
    request: &mut HostEffectRequest,
) -> Result<(), IoError> {
    if operation.identity == "network_send" {
        let Some(HostValue::HttpRequest(http_request)) = request.arguments.first_mut() else {
            return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
        };
        crate::network_limits::prepare_request(http_request, authority.network_limits)?;
    }
    let receiver = request
        .receiver
        .as_ref()
        .map(|receiver| receiver.token())
        .transpose()?;
    let rights = match receiver {
        Some(token) => validate_receiver(authority, operation, token, &request.arguments)?,
        None => root_rights(&authority.permissions, operation.result)?,
    };
    if let Some(kind) = capability_kind(operation.result) {
        let network_origins = (kind == CapabilityKind::Network)
            .then(|| network_capability_origins(authority, operation, request))
            .transpose()?;
        let token = authority.table.allocate(kind, rights);
        if let Some(origins) = network_origins {
            authority.network_capabilities.insert(token.slot, origins);
        }
        request.result_capability = Some(token.into());
    }
    Ok(())
}

fn validate_receiver(
    authority: &EffectAuthority,
    operation: &EffectOperation,
    token: CapabilityToken,
    arguments: &[HostValue],
) -> Result<RightsMask, IoError> {
    authority
        .table
        .validate(&token)
        .map_err(|_| IoError::from_kind(IoErrorKind::ClosedCapability))?;
    if operation.receiver.and_then(capability_kind) != Some(token.kind) {
        return Err(IoError::permission_denied());
    }
    validate_network_receiver(authority, operation, token, arguments)?;
    let rights = match operation.identity {
        "file_open" | "directory_derive" => mode_rights(arguments.last())?,
        "file_read_bytes" | "file_read_text" => RightsMask::READ_ONLY,
        "file_write_bytes" | "file_write_text" => RightsMask {
            read: false,
            write: true,
            execute: false,
        },
        _ => RightsMask {
            read: false,
            write: false,
            execute: false,
        },
    };
    if !rights.is_subset_of(token.rights) {
        return Err(IoError::permission_denied());
    }
    Ok(
        if matches!(operation.identity, "file_open" | "directory_derive") {
            rights
        } else {
            token.rights
        },
    )
}

pub(crate) fn mode_rights(value: Option<&HostValue>) -> Result<RightsMask, IoError> {
    let Some(HostValue::Text(mode)) = value else {
        return Err(IoError::permission_denied());
    };
    match mode.as_str() {
        "read" | "lectura" => Ok(RightsMask::READ_ONLY),
        "write" | "escritura" => Ok(RightsMask {
            read: false,
            write: true,
            execute: false,
        }),
        "read_write" | "lectura_escritura" => Ok(RightsMask::READ_WRITE),
        _ => Err(IoError::from_kind(IoErrorKind::InvalidPath)),
    }
}

fn root_rights(
    permissions: &BTreeSet<String>,
    kind: EffectValueKind,
) -> Result<RightsMask, IoError> {
    let permission = match kind {
        EffectValueKind::Console => "consola",
        EffectValueKind::Arguments => "argumentos",
        EffectValueKind::Clock => "reloj",
        EffectValueKind::Timer => "temporizador",
        EffectValueKind::Network => "red",
        EffectValueKind::Directory => {
            let rights = RightsMask {
                read: permissions.contains("archivos_lectura"),
                write: permissions.contains("archivos_escritura"),
                execute: false,
            };
            return if rights.read || rights.write {
                Ok(rights)
            } else {
                Err(IoError::permission_denied())
            };
        }
        _ => return Err(IoError::permission_denied()),
    };
    if permissions.contains(permission) {
        Ok(RightsMask::EXECUTE_ONLY)
    } else {
        Err(IoError::permission_denied())
    }
}

pub(crate) fn capability_kind(kind: EffectValueKind) -> Option<CapabilityKind> {
    match kind {
        EffectValueKind::Console => Some(CapabilityKind::Console),
        EffectValueKind::Arguments => Some(CapabilityKind::Arguments),
        EffectValueKind::Directory => Some(CapabilityKind::Directory),
        EffectValueKind::File => Some(CapabilityKind::File),
        EffectValueKind::Clock => Some(CapabilityKind::Clock),
        EffectValueKind::Timer => Some(CapabilityKind::Timer),
        EffectValueKind::Network => Some(CapabilityKind::Network),
        _ => None,
    }
}

fn network_capability_origins(
    authority: &EffectAuthority,
    operation: &EffectOperation,
    request: &HostEffectRequest,
) -> Result<BTreeSet<String>, IoError> {
    match operation.identity {
        "request_network" => Ok(authority.granted_network_origins.clone()),
        "network_restrict" => {
            let origin = crate::network_url::parse_origin(text_argument(&request.arguments, 0)?)?;
            Ok(BTreeSet::from([origin]))
        }
        _ => Ok(BTreeSet::new()),
    }
}

fn validate_network_receiver(
    authority: &EffectAuthority,
    operation: &EffectOperation,
    token: CapabilityToken,
    arguments: &[HostValue],
) -> Result<(), IoError> {
    let origins = authority
        .network_capabilities
        .get(&token.slot)
        .ok_or_else(IoError::permission_denied)?;
    match operation.identity {
        "network_restrict" => {
            let origin = crate::network_url::parse_origin(text_argument(arguments, 0)?)?;
            if !origins.contains(&origin) {
                return Err(IoError::from_kind(IoErrorKind::DestinationDenied));
            }
        }
        "network_send" => {
            let request = crate::http_values::request_from_value(
                arguments.first().ok_or_else(IoError::permission_denied)?,
            )
            .map_err(|_| IoError::permission_denied())?;
            crate::network_policy::validate_request(request, origins)?;
        }
        _ => (),
    }
    Ok(())
}

fn text_argument(arguments: &[HostValue], index: usize) -> Result<&str, IoError> {
    match arguments.get(index) {
        Some(HostValue::Text(value)) => Ok(value),
        _ => Err(IoError::permission_denied()),
    }
}
