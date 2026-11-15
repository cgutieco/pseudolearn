#[derive(Clone, Copy, Debug, Eq, Ord, PartialEq, PartialOrd)]
pub enum ManifestErrorCode {
    DuplicateKey,
    InvalidPath,
    InvalidValue,
    LimitNotGranted,
    ManifestEmpty,
    ManifestSyntax,
    ManifestTooLarge,
    MissingField,
    UnknownField,
    UnknownPermission,
    UnsupportedSchema,
}

impl ManifestErrorCode {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::DuplicateKey => "duplicateKey",
            Self::InvalidPath => "invalidPath",
            Self::InvalidValue => "invalidValue",
            Self::LimitNotGranted => "limitNotGranted",
            Self::ManifestEmpty => "manifestEmpty",
            Self::ManifestSyntax => "manifestSyntax",
            Self::ManifestTooLarge => "manifestTooLarge",
            Self::MissingField => "missingField",
            Self::UnknownField => "unknownField",
            Self::UnknownPermission => "unknownPermission",
            Self::UnsupportedSchema => "unsupportedSchema",
        }
    }
}

#[derive(Clone, Copy, Debug, Default, Eq, Ord, PartialEq, PartialOrd)]
pub struct Location {
    pub line: usize,
    pub column: usize,
}

impl Location {
    pub const START: Self = Self { line: 1, column: 1 };
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ManifestError {
    pub code: ManifestErrorCode,
    pub field: String,
    pub position: Location,
}

impl ManifestError {
    pub fn new(code: ManifestErrorCode, field: &str, position: Location) -> Self {
        Self {
            code,
            field: field.to_owned(),
            position,
        }
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
