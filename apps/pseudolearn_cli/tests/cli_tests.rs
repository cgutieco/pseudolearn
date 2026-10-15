#![forbid(unsafe_code)]

use std::process::Command;

#[test]
fn prints_spanish_help_by_default() -> Result<(), Box<dyn std::error::Error>> {
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("--ayuda")
        .output()?;
    assert_eq!(output.status.code(), Some(0));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.starts_with("Uso: pseudo <orden>"));
    Ok(())
}

#[test]
fn prints_english_help_when_requested() -> Result<(), Box<dyn std::error::Error>> {
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["--help", "--language", "en"])
        .output()?;
    assert_eq!(output.status.code(), Some(0));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.starts_with("Usage: pseudo <command>"));
    Ok(())
}

#[test]
fn fails_on_unknown_option_with_usage_error() -> Result<(), Box<dyn std::error::Error>> {
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["comprobar", "--desconocida"])
        .output()?;
    assert_eq!(output.status.code(), Some(2));
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("opción desconocida"));
    Ok(())
}

#[test]
fn reports_missing_input_file() -> Result<(), Box<dyn std::error::Error>> {
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("comprobar")
        .output()?;
    assert_eq!(output.status.code(), Some(2));
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("falta el archivo de entrada"));
    Ok(())
}
