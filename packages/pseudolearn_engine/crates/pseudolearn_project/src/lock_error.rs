use crate::manifest_error::{Location, ManifestError, ManifestErrorCode};

#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum LockErrorCode {
    AmbiguousOrigin,
    DanglingEdge,
    DependencyEdgeMismatch,
    DigestMismatch,
    DuplicateLockKey,
    FileMissing,
    FileNotLocked,
    InvalidLockPath,
    InvalidLockValue,
    KindMismatch,
    LockEmpty,
    LockSyntax,
    LockTooLarge,
    LockedPackageAbsent,
    MissingLockField,
    OriginMismatch,
    PackageNotLocked,
    UnknownLockField,
    UnsupportedLockSchema,
}

impl LockErrorCode {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::AmbiguousOrigin => "ambiguousOrigin",
            Self::DanglingEdge => "danglingEdge",
            Self::DependencyEdgeMismatch => "dependencyEdgeMismatch",
            Self::DigestMismatch => "digestMismatch",
            Self::DuplicateLockKey => "duplicateLockKey",
            Self::FileMissing => "fileMissing",
            Self::FileNotLocked => "fileNotLocked",
            Self::InvalidLockPath => "invalidLockPath",
            Self::InvalidLockValue => "invalidLockValue",
            Self::KindMismatch => "kindMismatch",
            Self::LockEmpty => "lockEmpty",
            Self::LockSyntax => "lockSyntax",
            Self::LockTooLarge => "lockTooLarge",
            Self::LockedPackageAbsent => "lockedPackageAbsent",
            Self::MissingLockField => "missingLockField",
            Self::OriginMismatch => "originMismatch",
            Self::PackageNotLocked => "packageNotLocked",
            Self::UnknownLockField => "unknownLockField",
            Self::UnsupportedLockSchema => "unsupportedLockSchema",
        }
    }
}

impl From<ManifestErrorCode> for LockErrorCode {
    fn from(code: ManifestErrorCode) -> Self {
        match code {
            ManifestErrorCode::DuplicateKey => Self::DuplicateLockKey,
            ManifestErrorCode::InvalidPath => Self::InvalidLockPath,
            ManifestErrorCode::ManifestEmpty => Self::LockEmpty,
            ManifestErrorCode::ManifestSyntax => Self::LockSyntax,
            ManifestErrorCode::ManifestTooLarge => Self::LockTooLarge,
            ManifestErrorCode::MissingField => Self::MissingLockField,
            ManifestErrorCode::UnknownField => Self::UnknownLockField,
            ManifestErrorCode::UnsupportedSchema => Self::UnsupportedLockSchema,
            ManifestErrorCode::InvalidValue
            | ManifestErrorCode::LimitNotGranted
            | ManifestErrorCode::UnknownPermission => Self::InvalidLockValue,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct LockError {
    pub code: LockErrorCode,
    pub field: String,
    pub position: Location,
}

impl LockError {
    pub fn new(code: LockErrorCode, field: &str, position: Location) -> Self {
        Self {
            code,
            field: field.to_owned(),
            position,
        }
    }

    pub(crate) fn from_manifest(error: ManifestError) -> Self {
        Self::new(error.code.into(), &error.field, error.position)
    }

    pub(crate) fn sort(errors: &mut [Self]) {
        errors.sort_by(|left, right| {
            left.position
                .cmp(&right.position)
                .then_with(|| left.code.cmp(&right.code))
                .then_with(|| left.field.cmp(&right.field))
        });
    }
}
