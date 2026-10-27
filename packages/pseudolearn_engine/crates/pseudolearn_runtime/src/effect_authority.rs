use crate::{
    CapabilityKind, CapabilityTable, CapabilityToken, HostEffectRequest, HostValue, IoError,
    RightsMask,
};
use pseudolearn_abi::{EffectOperation, EffectValueKind, IoErrorKind};
use std::collections::BTreeSet;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub(crate) struct EffectAuthority {
    pub(crate) table: CapabilityTable,
    pub(crate) permissions: BTreeSet<String>,
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
        request.result_capability = Some(authority.table.allocate(kind, rights).into());
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
        _ => None,
    }
}
