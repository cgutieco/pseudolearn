#[derive(Clone, Debug, Eq, PartialEq)]
pub enum ApiError {
    InvalidProtocol(String),
    UnsupportedVersion(String),
    SerializationFailure(String),
    InternalFault(String),
}

impl std::fmt::Display for ApiError {
    fn fmt(&self, formatter: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::InvalidProtocol(detail) => write!(formatter, "Invalid protocol: {detail}"),
            Self::UnsupportedVersion(detail) => write!(formatter, "Unsupported version: {detail}"),
            Self::SerializationFailure(detail) => {
                write!(formatter, "Serialization failure: {detail}")
            }
            Self::InternalFault(detail) => write!(formatter, "Internal fault: {detail}"),
        }
    }
}

impl std::error::Error for ApiError {}
