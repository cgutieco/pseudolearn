use crate::manifest_error::Location;
use crate::project_model::PackageKind;
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum Provenance {
    Manifest(Location),
    Default,
    Location,
    Host,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Field<Content> {
    pub value: Content,
    pub provenance: Provenance,
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum ProfileChoice {
    Spanish,
    English,
}

impl ProfileChoice {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Spanish => "es",
            Self::English => "en",
        }
    }

    pub(crate) fn from_name(name: &str) -> Option<Self> {
        match name {
            "es" => Some(Self::Spanish),
            "en" => Some(Self::English),
            _ => None,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ProfileException {
    pub path: String,
    pub profile: ProfileChoice,
    pub position: Location,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ManifestDependency {
    pub alias: String,
    pub package: String,
    pub position: Location,
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum PermissionName {
    Console,
    Arguments,
    FilesRead,
    FilesWrite,
    Clock,
    Timer,
}

impl PermissionName {
    pub const ALL: [Self; 6] = [
        Self::Console,
        Self::Arguments,
        Self::FilesRead,
        Self::FilesWrite,
        Self::Clock,
        Self::Timer,
    ];

    pub fn parse(text: &str) -> Option<Self> {
        match text {
            "consola" | "console" => Some(Self::Console),
            "argumentos" | "arguments" => Some(Self::Arguments),
            "archivos_lectura" | "files_read" => Some(Self::FilesRead),
            "archivos_escritura" | "files_write" => Some(Self::FilesWrite),
            "reloj" | "clock" => Some(Self::Clock),
            "temporizador" | "timer" => Some(Self::Timer),
            _ => None,
        }
    }

    pub fn as_str(self) -> &'static str {
        match self {
            Self::Console => "consola",
            Self::Arguments => "argumentos",
            Self::FilesRead => "archivos_lectura",
            Self::FilesWrite => "archivos_escritura",
            Self::Clock => "reloj",
            Self::Timer => "temporizador",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum LimitName {
    Cells,
    Depth,
    MicroSteps,
    Statements,
}

impl LimitName {
    pub const ALL: [Self; 4] = [Self::Cells, Self::Depth, Self::MicroSteps, Self::Statements];

    pub fn as_str(self) -> &'static str {
        match self {
            Self::Cells => "cells",
            Self::Depth => "depth",
            Self::MicroSteps => "micro_steps",
            Self::Statements => "statements",
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct LimitRequest {
    pub requested: u64,
    pub position: Location,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Manifest {
    pub name: Field<String>,
    pub kind: Field<PackageKind>,
    pub profile: Field<ProfileChoice>,
    pub entries: Field<Vec<String>>,
    pub profiles: Vec<ProfileException>,
    pub dependencies: Vec<ManifestDependency>,
    pub limits: BTreeMap<LimitName, LimitRequest>,
    pub permissions: Vec<Field<PermissionName>>,
}
