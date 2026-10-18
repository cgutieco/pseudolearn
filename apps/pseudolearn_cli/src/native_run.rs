use pseudolearn_api::NativeRunReport;
use std::io::{Result, Write};
use std::path::Path;
use std::process::{Command, Stdio};

pub fn run_executable(
    executable: &Path,
    working_directory: &Path,
    inputs: &[String],
) -> Result<NativeRunReport> {
    let mut child = Command::new(executable)
        .current_dir(working_directory)
        .env_clear()
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;
    if let Some(mut pipe) = child.stdin.take() {
        let text = inputs.iter().fold(String::new(), |mut accumulated, line| {
            accumulated.push_str(line);
            accumulated.push('\n');
            accumulated
        });
        let _written = pipe.write_all(text.as_bytes());
    }
    let output = child.wait_with_output()?;
    Ok(NativeRunReport {
        exit_code: output.status.code(),
        output: String::from_utf8_lossy(&output.stdout).into_owned(),
        errors: String::from_utf8_lossy(&output.stderr).into_owned(),
    })
}
