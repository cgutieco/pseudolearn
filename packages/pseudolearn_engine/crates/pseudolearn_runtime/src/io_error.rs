#![forbid(unsafe_code)]

use pseudolearn_abi::IoErrorKind;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct IoError {
    pub kind: IoErrorKind,
    pub uncertain: bool,
}

impl IoError {
    pub const fn new(kind: IoErrorKind, uncertain: bool) -> Self {
        Self { kind, uncertain }
    }

    pub const fn from_kind(kind: IoErrorKind) -> Self {
        Self::new(kind, false)
    }

    pub const fn not_found() -> Self {
        Self::new(IoErrorKind::NotFound, false)
    }

    pub const fn permission_denied() -> Self {
        Self::new(IoErrorKind::PermissionDenied, false)
    }

    pub const fn end_of_file() -> Self {
        Self::new(IoErrorKind::EndOfFile, false)
    }

    pub fn code(self) -> &'static str {
        self.kind.code()
    }
}
