use std::path::{Path, PathBuf};
use std::process::Command;

type BuildResult<Value> = Result<Value, Box<dyn std::error::Error>>;

pub struct RuntimeTarget {
    pub triple: String,
    pub required: bool,
    pub windows_imports: bool,
    pub native_strip: bool,
    library_name: &'static str,
    support_files: &'static [&'static str],
    environment: &'static [(&'static str, &'static str)],
}

struct TargetSpec {
    triple: &'static str,
    library_name: &'static str,
    support_files: &'static [&'static str],
    windows_imports: bool,
    strip_family: &'static str,
    environment: &'static [(&'static str, &'static str)],
}

const APPLE_ENVIRONMENT: &[(&str, &str)] = &[("MACOSX_DEPLOYMENT_TARGET", "11.0")];
const WINDOWS_ENVIRONMENT: &[(&str, &str)] = &[("CFLAGS_x86_64_pc_windows_msvc", "/GS-")];

const UNIX_LIBRARY: &str = "libpseudolearn_aot_rt.a";
const MUSL_SUPPORT: &[&str] = &[
    "crt1.o",
    "crti.o",
    "crtbegin.o",
    "crtend.o",
    "crtn.o",
    "libc.a",
    "libunwind.a",
];
const SPECS: &[TargetSpec] = &[
    TargetSpec {
        triple: "aarch64-apple-darwin",
        library_name: UNIX_LIBRARY,
        support_files: &[],
        windows_imports: false,
        strip_family: "macos",
        environment: APPLE_ENVIRONMENT,
    },
    TargetSpec {
        triple: "x86_64-apple-darwin",
        library_name: UNIX_LIBRARY,
        support_files: &[],
        windows_imports: false,
        strip_family: "macos",
        environment: APPLE_ENVIRONMENT,
    },
    TargetSpec {
        triple: "x86_64-unknown-linux-musl",
        library_name: UNIX_LIBRARY,
        support_files: MUSL_SUPPORT,
        windows_imports: false,
        strip_family: "linux",
        environment: &[],
    },
    TargetSpec {
        triple: "x86_64-pc-windows-msvc",
        library_name: "pseudolearn_aot_rt.lib",
        support_files: &[],
        windows_imports: true,
        strip_family: "windows",
        environment: WINDOWS_ENVIRONMENT,
    },
];
const DEFAULT_RUNTIME: &[(&str, &str)] = &[
    ("aarch64-apple-darwin", "aarch64-apple-darwin"),
    ("x86_64-apple-darwin", "x86_64-apple-darwin"),
    ("x86_64-unknown-linux-gnu", "x86_64-unknown-linux-musl"),
    ("x86_64-unknown-linux-musl", "x86_64-unknown-linux-musl"),
    ("x86_64-pc-windows-msvc", "x86_64-pc-windows-msvc"),
];

pub fn runtime_targets() -> BuildResult<Vec<RuntimeTarget>> {
    let compiling_for = std::env::var("TARGET")?;
    let build_host = std::env::var("HOST")?;
    let default = DEFAULT_RUNTIME
        .iter()
        .find(|(cargo_target, _)| *cargo_target == compiling_for)
        .map(|(_, runtime)| *runtime);
    let extra_allowed = std::env::var_os("CARGO_FEATURE_TEST_HOST").is_none();
    let sysroot = sysroot()?;
    let mut targets = Vec::new();
    for spec in SPECS {
        let required = default == Some(spec.triple);
        let installed = sysroot
            .join("lib/rustlib")
            .join(spec.triple)
            .join("lib")
            .is_dir();
        let buildable = !spec.windows_imports || build_host.contains("windows");
        if required || (extra_allowed && installed && buildable) {
            targets.push(target_of(spec, required, &build_host));
        }
    }
    if default.is_none() {
        targets.push(RuntimeTarget {
            triple: compiling_for,
            required: true,
            windows_imports: false,
            native_strip: true,
            library_name: UNIX_LIBRARY,
            support_files: &[],
            environment: &[],
        });
    }
    Ok(targets)
}

fn target_of(spec: &TargetSpec, required: bool, build_host: &str) -> RuntimeTarget {
    RuntimeTarget {
        triple: spec.triple.to_owned(),
        required,
        windows_imports: spec.windows_imports,
        native_strip: spec.strip_family == "linux" && build_host.contains("linux"),
        library_name: spec.library_name,
        support_files: spec.support_files,
        environment: spec.environment,
    }
}

fn sysroot() -> BuildResult<PathBuf> {
    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR")?);
    let output = Command::new("rustc")
        .current_dir(manifest.join("../../packages/pseudolearn_engine"))
        .args(["--print", "sysroot"])
        .output()?;
    if !output.status.success() {
        return Err("rustc --print sysroot failed".into());
    }
    Ok(PathBuf::from(String::from_utf8(output.stdout)?.trim()))
}

pub fn compile_static_library(
    engine: &Path,
    target_directory: &Path,
    target: &RuntimeTarget,
) -> BuildResult<PathBuf> {
    let cargo = std::env::var("CARGO").unwrap_or_else(|_| "cargo".to_owned());
    let mut command = Command::new(cargo);
    command
        .current_dir(engine)
        .env_remove("RUSTFLAGS")
        .env_remove("CARGO_ENCODED_RUSTFLAGS")
        .env("CARGO_TARGET_DIR", target_directory)
        .args(["rustc", "--release", "--locked", "--jobs", "1"])
        .args(["-p", "pseudolearn_aot_rt", "--lib"])
        .args(["--crate-type", "staticlib", "--target", &target.triple]);
    command.envs(target.environment.iter().copied());
    if std::env::var_os("CARGO_FEATURE_TEST_HOST").is_some() {
        command.args(["--features", "test-host"]);
    }
    if !command.status()?.success() {
        return Err(format!("cargo rustc failed for {}", target.triple).into());
    }
    Ok(target_directory
        .join(&target.triple)
        .join("release")
        .join(target.library_name))
}

pub fn copy_support_files(
    target: &RuntimeTarget,
    directory: &Path,
) -> BuildResult<Vec<(String, PathBuf)>> {
    if target.support_files.is_empty() {
        return Ok(Vec::new());
    }
    let source = sysroot()?
        .join("lib/rustlib")
        .join(&target.triple)
        .join("lib/self-contained");
    let mut copied = Vec::new();
    for name in target.support_files {
        let destination = directory.join(name);
        std::fs::copy(source.join(name), &destination)?;
        copied.push(((*name).to_owned(), destination));
    }
    Ok(copied)
}
