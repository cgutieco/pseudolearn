#![forbid(unsafe_code)]

#[cfg(test)]
mod main_tests;

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
    for (directory, arguments) in commands() {
        let status = std::process::Command::new("cargo")
            .current_dir(directory)
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

fn commands() -> Vec<(&'static str, Vec<&'static str>)> {
    let mut commands = vec![(
        "../pseudolearn_spec",
        vec![
            "run", "--locked", "-p", "see_cli", "--bin", "see", "--", "export", "--root", ".",
        ],
    )];
    commands.extend(
        [
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
        ]
        .into_iter()
        .map(|arguments| (".", arguments)),
    );
    commands.extend(rule_checks());
    commands.push((
        ".",
        vec!["run", "--locked", "-p", "reference_cli", "--", "check"],
    ));
    commands
}

fn rule_checks() -> Vec<(&'static str, Vec<&'static str>)> {
    [vec!["all", "."], vec!["toolchain", "../.."]]
        .into_iter()
        .map(|arguments| {
            let mut invocation = vec![
                "run",
                "--manifest-path",
                "../pseudolearn_rust_checks/Cargo.toml",
                "-p",
                "pseudolearn_check_command",
                "--",
            ];
            invocation.extend(arguments);
            (".", invocation)
        })
        .collect()
}
