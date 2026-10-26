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

    pub(crate) const fn already_exists() -> Self {
        Self::new(IoErrorKind::AlreadyExists, false)
    }

    pub const fn end_of_file() -> Self {
        Self::new(IoErrorKind::EndOfFile, false)
    }

    pub(crate) const fn invalid_utf8() -> Self {
        Self::new(IoErrorKind::InvalidUtf8, false)
    }

    pub(crate) const fn invalid_path() -> Self {
        Self::new(IoErrorKind::InvalidPath, false)
    }

    pub(crate) const fn closed_capability() -> Self {
        Self::new(IoErrorKind::ClosedCapability, false)
    }

    pub(crate) const fn timed_out() -> Self {
        Self::new(IoErrorKind::TimedOut, false)
    }

    pub(crate) const fn interrupted() -> Self {
        Self::new(IoErrorKind::Interrupted, false)
    }

    pub fn code(self) -> &'static str {
        self.kind.code()
    }
}
