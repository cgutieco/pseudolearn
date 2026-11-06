use std::io::{Error, ErrorKind, Result};
use std::path::{Path, PathBuf};

pub(crate) struct Workspace {
    pub(crate) directory: PathBuf,
}

impl Workspace {
    pub(crate) fn create() -> Result<Self> {
        let nanos = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_or(0, |duration| duration.as_nanos());
        let directory =
            std::env::temp_dir().join(format!("pseudo_link_{}_{nanos}", std::process::id()));
        std::fs::create_dir_all(&directory)?;
        Ok(Self { directory })
    }
}

impl Drop for Workspace {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.directory);
    }
}

struct StagedFile {
    path: PathBuf,
}

impl Drop for StagedFile {
    fn drop(&mut self) {
        let _removed = std::fs::remove_file(&self.path);
    }
}

pub(crate) fn place_output(linked: &Path, output: &Path) -> Result<()> {
    let name = output
        .file_name()
        .ok_or_else(|| Error::new(ErrorKind::InvalidInput, "output without a file name"))?;
    let mut staged_name = std::ffi::OsString::from(".");
    staged_name.push(name);
    staged_name.push(".partial");
    let staged = StagedFile {
        path: output.with_file_name(staged_name),
    };
    std::fs::copy(linked, &staged.path)?;
    std::fs::rename(&staged.path, output)
}
