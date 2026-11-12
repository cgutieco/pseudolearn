#![forbid(unsafe_code)]

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum CliError {
    Usage(String),
    Operational(String),
}

impl CliError {
    pub fn exit_code(&self) -> u8 {
        match self {
            Self::Usage(_) => 2,
            Self::Operational(_) => 3,
        }
    }
}
