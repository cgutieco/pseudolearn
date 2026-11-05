use std::path::PathBuf;
use std::process::{Command, Output};

fn acceptance_program(name: &str) -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("examples/general-purpose/acceptance")
        .join(name)
}

fn run_in_fresh_directory(name: &str) -> std::io::Result<(Output, Vec<String>)> {
    let directory = std::env::temp_dir().join(format!(
        "pseudo-acceptance-{}-{}",
        name.replace('.', "-"),
        std::process::id()
    ));
    std::fs::create_dir_all(&directory)?;
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .current_dir(&directory)
        .arg("run")
        .arg(acceptance_program(name))
        .output()?;
    let leftovers = std::fs::read_dir(&directory)?
        .filter_map(Result::ok)
        .map(|entry| entry.file_name().to_string_lossy().into_owned())
        .collect();
    std::fs::remove_dir_all(directory)?;
    Ok((output, leftovers))
}

fn standard_output(output: &Output) -> String {
    String::from_utf8_lossy(&output.stdout).into_owned()
}

#[test]
fn pure_library_program_prints_the_values_derived_from_the_rules() -> std::io::Result<()> {
    let (output, _) = run_in_fresh_directory("pure-library.es.pseudo")?;
    let expected = "STRASSE:école\n3:2.5:-1:0\n0.0:0.0:0.0:0.0:3.0:-1.0\n0.13:7.00:-3\n007:ab..\n-1:2:3\n3:-1\nVerdadero\n0\nbb:aa\n1970-01-01T00:00:00Z\n";
    assert_eq!(standard_output(&output), expected, "{output:?}");
    assert_eq!(output.status.code(), Some(0));
    Ok(())
}

#[test]
fn files_program_leaves_the_working_directory_empty() -> std::io::Result<()> {
    let (output, leftovers) = run_in_fresh_directory("files.es.pseudo")?;
    assert_eq!(standard_output(&output), "1:b.txt:3:4\n1\n0\n0\n", "{output:?}");
    assert_eq!(output.status.code(), Some(0));
    assert!(leftovers.is_empty(), "{leftovers:?}");
    Ok(())
}

#[test]
fn console_program_separates_the_error_stream_and_applies_the_exit_code() -> std::io::Result<()> {
    let (output, _) = run_in_fresh_directory("console-environment.es.pseudo")?;
    assert_eq!(standard_output(&output), "none\n0\n11\n7\n0\n", "{output:?}");
    assert_eq!(String::from_utf8_lossy(&output.stderr), "diagnostic\n");
    assert_eq!(output.status.code(), Some(7));
    Ok(())
}

#[test]
fn a_program_that_does_not_exist_fails_with_a_nonzero_code() -> std::io::Result<()> {
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(acceptance_program("missing.es.pseudo"))
        .output()?;
    assert_ne!(output.status.code(), Some(0));
    Ok(())
}
