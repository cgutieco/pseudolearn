use serde_json::{Value, json};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub(crate) struct HostError {
    pub code: &'static str,
    pub uncertain: bool,
}

impl HostError {
    pub const NOT_FOUND: Self = Self::certain("no_encontrado");
    pub const PERMISSION_DENIED: Self = Self::certain("permiso_denegado");
    pub const ALREADY_EXISTS: Self = Self::certain("ya_existe");
    pub const INVALID_UTF8: Self = Self::certain("utf8_invalido");
    pub const INVALID_PATH: Self = Self::certain("ruta_invalida");
    pub const CLOSED: Self = Self::certain("capacidad_cerrada");
    pub const TIMED_OUT: Self = Self::certain("tiempo_agotado");
    pub const INTERRUPTED: Self = Self::certain("interrumpido");
    pub const CONNECTION_FAILED: Self = Self::certain("conexion_fallida");
    pub const CERTIFICATE_INVALID: Self = Self::certain("certificado_invalido");
    pub const UNCERTAIN_INTERRUPTED: Self = Self {
        code: "interrumpido",
        uncertain: true,
    };

    const fn certain(code: &'static str) -> Self {
        Self {
            code,
            uncertain: false,
        }
    }

    pub fn from_io(error: &std::io::Error) -> Self {
        match error.kind() {
            std::io::ErrorKind::NotFound => Self::NOT_FOUND,
            std::io::ErrorKind::PermissionDenied => Self::PERMISSION_DENIED,
            std::io::ErrorKind::AlreadyExists => Self::ALREADY_EXISTS,
            std::io::ErrorKind::InvalidInput => Self::INVALID_PATH,
            _ => Self::INTERRUPTED,
        }
    }

    pub fn reply(self) -> Value {
        let outcome = if self.uncertain {
            "uncertain"
        } else {
            "failed"
        };
        json!({"outcome":outcome,"value":{"code":self.code,"uncertain":self.uncertain}})
    }
}

pub(crate) fn committed(kind: &str, value: impl Into<Value>) -> Value {
    json!({"outcome":"committed","value":{"kind":kind,"value":value.into()}})
}
