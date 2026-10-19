use pseudolearn_api::{ExecuteRequest, ExecuteResponse, NativeRunReport};
use std::path::{Path, PathBuf};
use std::process::Command;

pub fn compare(source: &str) -> Result<(), String> {
    let request = ExecuteRequest {
        program: source.to_owned(),
        gc_stress: true,
        ..Default::default()
    };
    let expected = pseudolearn_api::execute_program(&request);
    let actual = native(&request)?;
    assert_eq!(actual.output, expected.output, "{source}");
    assert_eq!(actual.termination, expected.termination, "{source}");
    assert_eq!(actual.diagnostics, expected.diagnostics, "{source}");
    Ok(())
}

fn native(request: &ExecuteRequest) -> Result<ExecuteResponse, String> {
    let object =
        pseudolearn_api::build_native_object(&pseudolearn_api::conformance_build_request(request))
            .map_err(|error| format!("{error:?}"))?;
    run_object(request, object)
}

pub fn run_object(
    request: &ExecuteRequest,
    object: pseudolearn_api::NativeObject,
) -> Result<ExecuteResponse, String> {
    let directory = Scratch::new()?;
    let path = directory.0.join("program.o");
    std::fs::write(&path, object.bytes).map_err(|error| error.to_string())?;
    let executable = link(&directory.0, &path)?;
    let output = Command::new(executable)
        .output()
        .map_err(|error| error.to_string())?;
    Ok(pseudolearn_api::native_execute_response(
        request,
        object.warnings,
        &NativeRunReport {
            exit_code: output.status.code(),
            output: String::from_utf8(output.stdout).map_err(|error| error.to_string())?,
            errors: String::from_utf8(output.stderr).map_err(|error| error.to_string())?,
        },
    ))
}

fn link(directory: &Path, object: &Path) -> Result<PathBuf, String> {
    let dependencies = std::env::current_exe()
        .map_err(|error| error.to_string())?
        .parent()
        .ok_or("Missing dependencies")?
        .to_path_buf();
    let runtime = std::fs::read_dir(&dependencies)
        .map_err(|error| error.to_string())?
        .filter_map(Result::ok)
        .map(|entry| entry.path())
        .filter(|path| {
            path.file_name()
                .and_then(|name| name.to_str())
                .is_some_and(|name| {
                    name.starts_with("libpseudolearn_aot_rt-") && name.ends_with(".rlib")
                })
        })
        .max_by_key(|path| {
            std::fs::metadata(path)
                .and_then(|metadata| metadata.modified())
                .ok()
        })
        .ok_or("Missing runtime")?;
    let source = directory.join("launcher.rs");
    std::fs::write(&source, "#![no_main]\nextern crate pseudolearn_aot_rt;\n")
        .map_err(|error| error.to_string())?;
    let executable = directory.join("program");
    let mut command = Command::new("rustc");
    command
        .args(["--edition", "2024", "--crate-name", "access_launcher"])
        .arg(source)
        .arg("-L")
        .arg(format!("dependency={}", dependencies.display()))
        .arg("--extern")
        .arg(format!("pseudolearn_aot_rt={}", runtime.display()))
        .arg("-C")
        .arg(format!("link-arg={}", object.display()))
        .arg("-o")
        .arg(&executable);
    if !cfg!(debug_assertions) {
        command.args(["-C", "lto=thin"]);
    }
    let output = command.output().map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    Ok(executable)
}

struct Scratch(PathBuf);

impl Scratch {
    fn new() -> Result<Self, String> {
        static SEQUENCE: std::sync::atomic::AtomicU32 = std::sync::atomic::AtomicU32::new(0);
        let sequence = SEQUENCE.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
        let path = Path::new(env!("CARGO_TARGET_TMPDIR"))
            .join(format!("native-access-{}-{sequence}", std::process::id()));
        std::fs::create_dir_all(&path).map_err(|error| error.to_string())?;
        Ok(Self(path))
    }
}

impl Drop for Scratch {
    fn drop(&mut self) {
        let _removed = std::fs::remove_dir_all(&self.0);
    }
}
