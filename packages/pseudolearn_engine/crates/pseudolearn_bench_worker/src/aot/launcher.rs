use crate::corpus::CorpusCase;
use pseudolearn_api::BenchmarkObject;
use std::path::{Path, PathBuf};
use std::process::Command;

pub struct Launcher {
    pub name: String,
    pub executable: PathBuf,
    pub metadata: PathBuf,
    pub expected: String,
    pub input: PathBuf,
}

pub fn prepare(
    case: &CorpusCase,
    object: &BenchmarkObject,
    (directory, archive): (&Path, &Path),
) -> Result<Launcher, String> {
    let folder = directory.join(&case.name);
    std::fs::create_dir_all(&folder).map_err(|error| error.to_string())?;
    let launcher = Launcher {
        name: case.name.clone(),
        executable: folder.join("launcher"),
        metadata: folder.join("metadata.bin"),
        expected: case.expected_output.clone(),
        input: folder.join("input.txt"),
    };
    let inputs: String = case.inputs.iter().map(|line| format!("{line}\n")).collect();
    std::fs::write(&launcher.input, inputs).map_err(|error| error.to_string())?;
    let object_path = folder.join("program.o");
    let source_path = folder.join("launcher.c");
    let source =
        include_str!("launcher.c.template").replace("@@ENTRY_SYMBOL@@", &object.entry_symbol);
    for (path, content) in [
        (&object_path, object.bytes.as_slice()),
        (&launcher.metadata, object.metadata.as_slice()),
        (&source_path, source.as_bytes()),
    ] {
        std::fs::write(path, content).map_err(|error| error.to_string())?;
    }
    link(&[&source_path, &object_path, archive], &launcher.executable)?;
    Ok(launcher)
}

fn platform_arguments() -> &'static [&'static str] {
    if cfg!(target_os = "macos") {
        &["-Wl,-dead_strip", "-lm"]
    } else {
        &["-Wl,--gc-sections", "-lpthread", "-ldl", "-lm", "-lgcc_s"]
    }
}

fn link(inputs: &[&Path], executable: &Path) -> Result<(), String> {
    let output = Command::new("cc")
        .arg("-O2")
        .arg("-o")
        .arg(executable)
        .args(inputs)
        .args(platform_arguments())
        .output()
        .map_err(|error| error.to_string())?;
    if output.status.success() {
        Ok(())
    } else {
        Err(format!(
            "Launcher link failed: {}",
            String::from_utf8_lossy(&output.stderr)
        ))
    }
}
