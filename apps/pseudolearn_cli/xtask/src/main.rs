#![forbid(unsafe_code)]

mod http_test_server;
mod http_test_server_certificates;
mod http_test_server_listener;
mod http_test_server_routes;

fn main() -> std::process::ExitCode {
    let mut arguments = std::env::args().skip(1);
    let result = match arguments.next().as_deref() {
        Some("verify") if arguments.next().is_none() => verify(),
        Some("http-test-server") => {
            let task_arguments = arguments.collect::<Vec<_>>();
            http_test_server::run(&task_arguments)
        }
        _ => Err("Usage: cargo xtask verify | http-test-server [options]".to_owned()),
    };
    match result {
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
        .current_dir("../../packages/pseudolearn_spec")
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
    vec![
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
        vec![
            "run",
            "--manifest-path",
            "../../packages/pseudolearn_rust_checks/Cargo.toml",
            "-p",
            "pseudolearn_check_command",
            "--bin",
            "rust-checks",
            "--",
            "all",
            ".",
        ],
        vec![
            "run",
            "--manifest-path",
            "../../packages/pseudolearn_rust_checks/Cargo.toml",
            "-p",
            "pseudolearn_check_command",
            "--bin",
            "rust-checks",
            "--",
            "toolchain",
            "../..",
        ],
        vec!["deny", "check"],
    ]
}
