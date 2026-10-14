#![forbid(unsafe_code)]

fn main() -> std::process::ExitCode {
    let arguments: Vec<String> = std::env::args().skip(1).collect();
    match run(&arguments) {
        Ok(true) => std::process::ExitCode::SUCCESS,
        Ok(false) => std::process::ExitCode::from(1),
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::from(2)
        }
    }
}

fn run(arguments: &[String]) -> Result<bool, String> {
    if arguments.len() != 2 {
        return Err("Usage: rust-checks <all|layers|comments|names|limits|unsafe|attributes|toolchain> <member>".to_owned());
    }
    let command = arguments.first().ok_or("Missing verifier")?;
    let root = std::path::Path::new(arguments.get(1).ok_or("Missing member")?);
    if command == "toolchain" {
        pseudolearn_checks::toolchain::verify_versions(root)?;
        return Ok(true);
    }
    let violations = pseudolearn_checks::verify(command, root)?;
    for finding in &violations {
        println!(
            "{}:{} {} {}",
            finding.path, finding.line, finding.rule, finding.message
        );
    }
    Ok(violations.is_empty())
}
