use crate::arguments::Arguments;
use see_model::properties::{PropertyBinding, PropertyExecutor};
use serde_json::{Value, json};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Output, Stdio};

struct Sandbox(PathBuf);
impl Drop for Sandbox {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.0);
    }
}

pub fn check(
    binding: &PropertyBinding,
    arguments: &Arguments,
    request: &Value,
    expected: &Value,
) -> Result<Value, String> {
    let sandbox = Sandbox(std::env::temp_dir().join(format!("see_native_{}", std::process::id())));
    std::fs::create_dir_all(sandbox.0.join("temporary")).map_err(|error| error.to_string())?;
    let executable = sandbox.0.join("program");
    let source = sandbox.0.join("program.pseudo");
    std::fs::write(
        &source,
        request["program"].as_str().ok_or("Missing program")?,
    )
    .map_err(|error| error.to_string())?;
    let pseudo = arguments
        .root
        .join("../../apps/pseudolearn_cli/target/debug/pseudo")
        .canonicalize()
        .map_err(|error| error.to_string())?;
    let build = compile(&pseudo, &sandbox.0, request)?;
    if !build.status.success() {
        return Ok(json!({"passed":false,"buildErrors":String::from_utf8_lossy(&build.stderr)}));
    }
    std::fs::remove_file(&source).map_err(|error| error.to_string())?;
    let first = run(&executable, request, true)?;
    let mut passed = first.stdout == expected["output"].as_str().unwrap_or("").as_bytes();
    passed &= verify(
        binding,
        request,
        expected,
        (&pseudo, &sandbox.0, &executable, &first),
    )?;
    passed &= clean(&sandbox.0.join("temporary"))? && clean_outputs(&sandbox.0)?;
    Ok(json!({"passed":passed}))
}

fn compile(pseudo: &Path, directory: &Path, request: &Value) -> Result<Output, String> {
    compiler(pseudo)
        .current_dir(directory)
        .env("TMPDIR", directory.join("temporary"))
        .args([
            "build",
            "program.pseudo",
            "-o",
            "program",
            "--vocabulary",
            request["profile"].as_str().unwrap_or("es"),
            "--strictness",
            request["strictness"].as_str().unwrap_or("strict"),
        ])
        .output()
        .map_err(|error| error.to_string())
}

fn run(executable: &Path, request: &Value, isolated: bool) -> Result<Output, String> {
    let mut command = Command::new(executable);
    if isolated {
        command.env_clear().current_dir(std::env::temp_dir());
    }
    let mut child = command
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|error| error.to_string())?;
    if let Some(mut input) = child.stdin.take() {
        for line in request["inputs"].as_array().into_iter().flatten() {
            writeln!(input, "{}", line.as_str().ok_or("Invalid input")?)
                .map_err(|error| error.to_string())?;
        }
    }
    child.wait_with_output().map_err(|error| error.to_string())
}

fn dependencies(executable: &Path) -> Result<bool, String> {
    let (program, flag) = if cfg!(target_os = "macos") {
        ("otool", "-L")
    } else {
        ("ldd", "")
    };
    let mut command = Command::new(program);
    if !flag.is_empty() {
        command.arg(flag);
    }
    let output = command
        .arg(executable)
        .output()
        .map_err(|error| error.to_string())?;
    let text = String::from_utf8_lossy(&output.stdout);
    Ok(output.status.success()
        && !text
            .lines()
            .skip(1)
            .any(|line| line.contains("pseudolearn")))
}

fn clean(directory: &Path) -> Result<bool, String> {
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let name = entry.map_err(|error| error.to_string())?.file_name();
        if name.to_string_lossy().starts_with("pseudo_") {
            return Ok(false);
        }
    }
    Ok(true)
}

fn cleanup_failure(pseudo: &Path, directory: &Path, request: &Value) -> Result<bool, String> {
    std::fs::write(
        directory.join("program.pseudo"),
        request["program"].as_str().ok_or("Missing program")?,
    )
    .map_err(|error| error.to_string())?;
    let before = std::fs::read(directory.join("program")).map_err(|error| error.to_string())?;
    let output = Command::new(pseudo)
        .current_dir(directory)
        .env("TMPDIR", directory.join("temporary"))
        .env("PATH", "")
        .args(["build", "program.pseudo", "-o", "program"])
        .output()
        .map_err(|error| error.to_string())?;
    Ok(output.status.code() == Some(3)
        && std::fs::read(directory.join("program")).map_err(|error| error.to_string())? == before)
}

#[cfg(unix)]
fn permissions(executable: &Path) -> Result<bool, String> {
    use std::os::unix::fs::PermissionsExt;
    Ok(std::fs::metadata(executable)
        .map_err(|error| error.to_string())?
        .permissions()
        .mode()
        & 0o177
        == 0o100)
}
#[cfg(not(unix))]
fn permissions(_executable: &Path) -> Result<bool, String> {
    Ok(true)
}

fn exit_code(expected: &Value) -> i32 {
    match expected
        .pointer("/termination/kind")
        .and_then(Value::as_str)
    {
        Some("completed") => 0,
        Some("awaiting_input" | "limit_reached") => 4,
        _ => 3,
    }
}

fn verify(
    binding: &PropertyBinding,
    request: &Value,
    expected: &Value,
    paths: (&Path, &Path, &Path, &Output),
) -> Result<bool, String> {
    let (pseudo, directory, executable, first) = paths;
    let mut passed = true;
    match binding.executor {
        PropertyExecutor::NativeLinking => passed &= dependencies(executable)?,
        PropertyExecutor::NativeCleanup => passed &= cleanup_failure(pseudo, directory, request)?,
        PropertyExecutor::NativePermissions => passed &= permissions(executable)?,
        PropertyExecutor::NativeExit => passed &= first.status.code() == Some(exit_code(expected)),
        PropertyExecutor::NativeEnvironment => {
            let second = run(executable, request, false)?;
            passed &= first.status.code() == second.status.code()
                && first.stdout == second.stdout
                && first.stderr == second.stderr;
        }
        _ => return Err("Unknown native artifact property".to_owned()),
    }
    Ok(passed)
}

#[cfg(unix)]
fn compiler(pseudo: &Path) -> Command {
    let mut command = Command::new("sh");
    command
        .args(["-c", "umask 077; exec \"$@\"", "native-build"])
        .arg(pseudo);
    command
}

#[cfg(not(unix))]
fn compiler(pseudo: &Path) -> Command {
    Command::new(pseudo)
}

fn clean_outputs(directory: &Path) -> Result<bool, String> {
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let name = entry.map_err(|error| error.to_string())?.file_name();
        if !["temporary", "program", "program.pseudo"].contains(&name.to_string_lossy().as_ref()) {
            return Ok(false);
        }
    }
    Ok(true)
}

pub(crate) fn supports(executor: PropertyExecutor) -> bool {
    [
        PropertyExecutor::NativeLinking,
        PropertyExecutor::NativeCleanup,
        PropertyExecutor::NativePermissions,
        PropertyExecutor::NativeExit,
        PropertyExecutor::NativeEnvironment,
    ]
    .contains(&executor)
}
