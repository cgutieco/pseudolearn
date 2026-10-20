#![forbid(unsafe_code)]

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
    for arguments in COMMANDS {
        let status = std::process::Command::new("cargo")
            .args(*arguments)
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
        .current_dir("../../pseudolearn_spec")
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

const COMMANDS: &[&[&str]] = &[
    &["fmt", "--all", "--check"],
    &[
        "clippy",
        "--workspace",
        "--all-targets",
        "--",
        "-D",
        "warnings",
    ],
    &["test", "--workspace"],
    &["deny", "check"],
    &[
        "run",
        "--manifest-path",
        "../../pseudolearn_rust_checks/Cargo.toml",
        "-p",
        "pseudolearn_check_command",
        "--",
        "all",
        ".",
    ],
    &[
        "run",
        "--manifest-path",
        "../../pseudolearn_rust_checks/Cargo.toml",
        "-p",
        "pseudolearn_check_command",
        "--",
        "toolchain",
        "../../..",
    ],
];
