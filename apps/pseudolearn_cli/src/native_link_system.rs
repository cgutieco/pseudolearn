use std::io::{Error, Result};
use std::path::Path;
use std::process::{Command, Stdio};

pub(crate) fn link_with_system_driver(inputs: &[&Path], output: &Path) -> Result<()> {
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
        &[
            "-Wl,-dead_strip",
            "-lm",
            "-framework",
            "Security",
            "-framework",
            "CoreFoundation",
        ]
    } else if cfg!(target_os = "linux") {
        &["-Wl,--gc-sections", "-lpthread", "-ldl", "-lm", "-lgcc_s"]
    } else {
        &[]
    }
}
