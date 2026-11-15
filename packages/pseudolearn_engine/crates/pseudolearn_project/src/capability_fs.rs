use crate::logical_path::{normalize, segments};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct FileRights {
    pub read: bool,
    pub write: bool,
}

impl FileRights {
    pub const READ_ONLY: Self = Self {
        read: true,
        write: false,
    };
    pub const READ_WRITE: Self = Self {
        read: true,
        write: true,
    };

    pub fn attenuate(self, requested: Self) -> Result<Self, CapabilityFsError> {
        if requested.read && !self.read {
            return Err(CapabilityFsError::AmplificationDenied);
        }
        if requested.write && !self.write {
            return Err(CapabilityFsError::AmplificationDenied);
        }
        Ok(requested)
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum CapabilityFsError {
    InvalidPath,
    EscapeAttempt,
    AmplificationDenied,
    AccessDenied,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct ConfinedDirectory {
    pub root: String,
    pub rights: FileRights,
}

impl ConfinedDirectory {
    pub fn new(root: String, rights: FileRights) -> Option<Self> {
        let normalized = normalize(&root)?;
        Some(Self {
            root: normalized,
            rights,
        })
    }

    pub fn resolve_subpath(&self, subpath: &str) -> Result<String, CapabilityFsError> {
        if subpath
            .split('/')
            .any(|segment| segment == ".." || segment == ".")
        {
            return Err(CapabilityFsError::EscapeAttempt);
        }
        let parts = segments(subpath).ok_or(CapabilityFsError::InvalidPath)?;
        let joined = format!("{}/{}", self.root, parts.join("/"));
        normalize(&joined).ok_or(CapabilityFsError::InvalidPath)
    }

    pub fn derive_subdirectory(
        &self,
        subpath: &str,
        requested_rights: FileRights,
    ) -> Result<Self, CapabilityFsError> {
        let resolved = self.resolve_subpath(subpath)?;
        let attenuated = self.rights.attenuate(requested_rights)?;
        Ok(Self {
            root: resolved,
            rights: attenuated,
        })
    }
}
