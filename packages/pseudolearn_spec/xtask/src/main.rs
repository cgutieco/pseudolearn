#![forbid(unsafe_code)]

mod documentation;
mod retirement;

fn main() -> std::process::ExitCode {
    match verify() {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::FAILURE
        }
    }
}

fn verify() -> Result<(), String> {
    if std::env::args().nth(1).as_deref() != Some("verify") {
        return Err("Usage: cargo xtask verify".to_owned());
    }
    export()?;
    retirement::check(std::path::Path::new("../.."))?;
    documentation::check(std::path::Path::new("../.."))?;
    for arguments in commands() {
        let status = std::process::Command::new("cargo")
            .args(&arguments)
            .status()
            .map_err(|error| error.to_string())?;
        if !status.success() {
            return Err(format!(
                "Verification failed: cargo {}",
                arguments.join(" ")
            ));
        }
    }
    Ok(())
}

fn export() -> Result<(), String> {
    let status = std::process::Command::new("cargo")
        .args([
            "run", "--locked", "-p", "see_cli", "--bin", "see", "--", "export", "--root", ".",
        ])
        .status()
        .map_err(|error| error.to_string())?;
    if !status.success() {
        return Err("Failed to generate the local corpus export".to_owned());
    }
    Ok(())
}

fn commands() -> Vec<Vec<&'static str>> {
    let mut commands = vec![
        vec!["fmt", "--all", "--check"],
        vec![
            "clippy",
            "--workspace",
            "--all-targets",
            "--",
            "-D",
            "warnings",
        ],
        vec!["test", "--workspace"],
        vec!["deny", "check"],
    ];
    for arguments in [vec!["all", "."], vec!["toolchain", "../.."]] {
        let mut invocation = vec![
            "run",
            "--manifest-path",
            "../pseudolearn_rust_checks/Cargo.toml",
            "-p",
            "pseudolearn_check_command",
            "--",
        ];
        invocation.extend(arguments);
        commands.push(invocation);
    }
    commands.push(engine_adapter_build());
    commands.extend(see_commands());
    commands
}

fn see_commands() -> Vec<Vec<&'static str>> {
    [
        vec!["validate"],
        vec!["export", "--check"],
        vec![
            "conform",
            "--subject",
            "engine",
            "--operation",
            "properties",
        ],
        vec!["conform", "--subject", "engine"],
    ]
    .into_iter()
    .map(|arguments| {
        let mut invocation = vec!["run", "-p", "see_cli", "--bin", "see", "--"];
        invocation.extend(arguments);
        invocation
    })
    .collect()
}

fn engine_adapter_build() -> Vec<&'static str> {
    vec![
        "build",
        "--release",
        "--locked",
        "--manifest-path",
        "../pseudolearn_engine/Cargo.toml",
        "-p",
        "pseudolearn_conformance",
        "--bin",
        "conformance_adapter",
    ]
}
