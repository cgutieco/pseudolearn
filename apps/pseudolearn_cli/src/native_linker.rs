use crate::runtime_archive::RUNTIME_ARCHIVE;
use std::io::{Error, ErrorKind, Result};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

struct Workspace {
    directory: PathBuf,
}

impl Workspace {
    fn create() -> Result<Self> {
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

pub fn link_executable(object: &[u8], output: &Path) -> Result<()> {
    let workspace = Workspace::create()?;
    let object_path = workspace.directory.join("program.o");
    let archive_path = workspace.directory.join("runtime.a");
    let linked_path = workspace.directory.join("program");
    std::fs::write(&object_path, object)?;
    std::fs::write(&archive_path, RUNTIME_ARCHIVE)?;
    run_linker(&[&object_path, &archive_path], &linked_path)?;
    place_output(&linked_path, output)
}

fn run_linker(inputs: &[&Path], output: &Path) -> Result<()> {
    let status = Command::new("cc")
        .arg("-o")
        .arg(output)
        .args(inputs)
        .args(platform_arguments())
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()?;
    if status.success() {
        Ok(())
    } else {
        Err(Error::other("linker failed"))
    }
}

fn platform_arguments() -> &'static [&'static str] {
    if cfg!(target_os = "macos") {
        &["-Wl,-dead_strip", "-lm"]
    } else if cfg!(target_os = "linux") {
        &["-Wl,--gc-sections", "-lpthread", "-ldl", "-lm", "-lgcc_s"]
    } else {
        &[]
    }
}

fn place_output(linked: &Path, output: &Path) -> Result<()> {
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
