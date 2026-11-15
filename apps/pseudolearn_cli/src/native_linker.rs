use crate::linker_assets::{BUNDLED_LINKER_NAME, LINKER_VERSION, host_asset};
use crate::linker_download::{LinkerUnavailable, NetworkFetcher, installed_linker};
use crate::native_link_targets::{LinkFormat, LinkInputs, LinkTarget, host_target, lld_arguments};
use crate::native_link_workspace::{Workspace, place_output};
use crate::runtime_archive::{RuntimeArchive, archive_for};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::sync::OnceLock;

#[derive(Debug)]
pub(crate) enum LinkFailure {
    RuntimeMissing(String),
    Unavailable(LinkerUnavailable),
    Failed(String),
}

impl From<std::io::Error> for LinkFailure {
    fn from(error: std::io::Error) -> Self {
        Self::Failed(error.to_string())
    }
}

pub(crate) fn link_executable(object: &[u8], output: &Path) -> Result<(), LinkFailure> {
    link_for_target(host_target(), object, output)
}

pub(crate) fn link_for_target(
    target: Option<&'static LinkTarget>,
    object: &[u8],
    output: &Path,
) -> Result<(), LinkFailure> {
    let workspace = Workspace::create()?;
    let linked = if let Some(target) = target {
        let runtime = archive_for(target.triple)
            .ok_or_else(|| LinkFailure::RuntimeMissing(target.triple.to_owned()))?;
        match located_linker()? {
            Some(linker) => link_with_lld(&linker, (target, runtime), object, &workspace)?,
            None => link_with_driver(object, runtime, &workspace)?,
        }
    } else {
        let runtime = crate::runtime_archive::RUNTIME_ARCHIVES
            .first()
            .ok_or_else(|| LinkFailure::RuntimeMissing(String::new()))?;
        link_with_driver(object, runtime, &workspace)?
    };
    place_output(&linked, output)?;
    Ok(())
}

fn located_linker() -> Result<Option<PathBuf>, LinkFailure> {
    static LOCATED: OnceLock<Option<PathBuf>> = OnceLock::new();
    if let Some(located) = LOCATED.get() {
        return Ok(located.clone());
    }
    let located = locate_linker().map_err(LinkFailure::Unavailable)?;
    Ok(LOCATED.get_or_init(|| located).clone())
}

fn locate_linker() -> Result<Option<PathBuf>, LinkerUnavailable> {
    if let Some(bundled) = beside_pseudo(BUNDLED_LINKER_NAME) {
        return Ok(Some(bundled));
    }
    let Some(asset) = host_asset() else {
        return Ok(beside_pseudo("rust-lld"));
    };
    let directory = crate::linker_cache::host_linker_directory(LINKER_VERSION)
        .ok_or(LinkerUnavailable::CacheUnavailable)?;
    installed_linker(asset, &directory, &NetworkFetcher).map(Some)
}

fn beside_pseudo(name: &str) -> Option<PathBuf> {
    let executable = std::env::current_exe().ok()?;
    let candidate = executable
        .parent()?
        .join(format!("{name}{}", std::env::consts::EXE_SUFFIX));
    candidate.is_file().then_some(candidate)
}

fn link_with_lld(
    linker: &Path,
    (target, runtime): (&LinkTarget, &RuntimeArchive),
    object: &[u8],
    workspace: &Workspace,
) -> Result<PathBuf, LinkFailure> {
    let directory = &workspace.directory;
    let object_path = directory.join(target.object_name);
    let archive_path = directory.join(target.archive_name);
    let executable_path = directory.join(format!("program{}", target.executable_suffix));
    std::fs::write(&object_path, object)?;
    std::fs::write(&archive_path, runtime.archive)?;
    let support = support_files(linker, (target, runtime), object, directory)?;
    let inputs = LinkInputs {
        object: &object_path,
        archive: &archive_path,
        support: &support,
        output: &executable_path,
    };
    let finished = Command::new(linker)
        .args(lld_arguments(target, &inputs))
        .stdin(Stdio::null())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()?;
    if !finished.status.success() {
        let mut report = String::from_utf8_lossy(&finished.stderr).into_owned();
        report.push_str(&String::from_utf8_lossy(&finished.stdout));
        return Err(LinkFailure::Failed(report));
    }
    Ok(executable_path)
}

fn support_files(
    linker: &Path,
    (target, runtime): (&LinkTarget, &RuntimeArchive),
    object: &[u8],
    directory: &Path,
) -> Result<Vec<PathBuf>, LinkFailure> {
    match target.format {
        LinkFormat::MachO => Ok(crate::native_link_stubs::write_stubs(
            (object, runtime.archive),
            target.architecture,
            directory,
        )?),
        LinkFormat::Elf => {
            let mut written = Vec::new();
            for (name, bytes) in runtime.support {
                let path = directory.join(name);
                std::fs::write(&path, bytes)?;
                written.push(path);
            }
            Ok(written)
        }
        LinkFormat::Coff => Ok(crate::native_link_imports::write_import_libraries(
            linker,
            (runtime.imports, target.architecture),
            directory,
        )?),
    }
}

fn link_with_driver(
    object: &[u8],
    runtime: &RuntimeArchive,
    workspace: &Workspace,
) -> Result<PathBuf, LinkFailure> {
    let object_path = workspace.directory.join("program.o");
    let archive_path = workspace.directory.join("runtime.a");
    let linked = workspace.directory.join("program");
    std::fs::write(&object_path, object)?;
    std::fs::write(&archive_path, runtime.archive)?;
    crate::native_link_system::link_with_system_driver(&[&object_path, &archive_path], &linked)?;
    Ok(linked)
}
