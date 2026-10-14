#![forbid(unsafe_code)]

mod documentation;

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
    for arguments in [
        vec!["validate"],
        vec!["lock", "--check"],
        vec!["export", "--check"],
        vec!["conform", "--subject", "reference"],
    ] {
        let mut invocation = vec!["run", "-p", "see_cli", "--bin", "see", "--"];
        invocation.extend(arguments);
        commands.push(invocation);
    }
    commands
}
