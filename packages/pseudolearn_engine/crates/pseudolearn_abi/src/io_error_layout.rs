#![forbid(unsafe_code)]

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum IoErrorKind {
    NotFound,
    PermissionDenied,
    AlreadyExists,
    EndOfFile,
    InvalidUtf8,
    InvalidPath,
    ClosedCapability,
    TimedOut,
    Interrupted,
}

impl IoErrorKind {
    pub const ALL: [Self; 9] = [
        Self::NotFound,
        Self::PermissionDenied,
        Self::AlreadyExists,
        Self::EndOfFile,
        Self::InvalidUtf8,
        Self::InvalidPath,
        Self::ClosedCapability,
        Self::TimedOut,
        Self::Interrupted,
    ];

    pub fn code(self) -> &'static str {
        match self {
            Self::NotFound => "no_encontrado",
            Self::PermissionDenied => "permiso_denegado",
            Self::AlreadyExists => "ya_existe",
            Self::EndOfFile => "fin_de_archivo",
            Self::InvalidUtf8 => "utf8_invalido",
            Self::InvalidPath => "ruta_invalida",
            Self::ClosedCapability => "capacidad_cerrada",
            Self::TimedOut => "tiempo_agotado",
            Self::Interrupted => "interrumpido",
        }
    }

    pub fn from_tag(tag: u32) -> Option<Self> {
        match tag {
            0 => Some(Self::NotFound),
            1 => Some(Self::PermissionDenied),
            2 => Some(Self::AlreadyExists),
            3 => Some(Self::EndOfFile),
            4 => Some(Self::InvalidUtf8),
            5 => Some(Self::InvalidPath),
            6 => Some(Self::ClosedCapability),
            7 => Some(Self::TimedOut),
            8 => Some(Self::Interrupted),
            _ => None,
        }
    }

    pub fn to_tag(self) -> u32 {
        match self {
            Self::NotFound => 0,
            Self::PermissionDenied => 1,
            Self::AlreadyExists => 2,
            Self::EndOfFile => 3,
            Self::InvalidUtf8 => 4,
            Self::InvalidPath => 5,
            Self::ClosedCapability => 6,
            Self::TimedOut => 7,
            Self::Interrupted => 8,
        }
    }
}
