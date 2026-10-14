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
