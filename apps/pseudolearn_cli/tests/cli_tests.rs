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

#[test]
fn executes_ri_command_successfully() -> Result<(), Box<dyn std::error::Error>> {
    let unique_directory = std::env::temp_dir().join("pseudo_cli_test_ri");
    std::fs::create_dir_all(&unique_directory)?;
    let source_file_path = unique_directory.join("program.pseudo");
    std::fs::write(
        &source_file_path,
        "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    )?;

    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["ri", source_file_path.to_str().unwrap_or("")])
        .output()?;
    assert_eq!(output.status.code(), Some(0));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("module P es"));
    assert!(stdout.contains("func @main() -> unit"));
    assert!(stdout.contains("out.write"));

    let _removed = std::fs::remove_dir_all(&unique_directory);
    Ok(())
}

#[test]
fn reports_error_on_invalid_program_in_ir_command() -> Result<(), Box<dyn std::error::Error>> {
    let unique_directory = std::env::temp_dir().join("pseudo_cli_test_ir_err");
    std::fs::create_dir_all(&unique_directory)?;
    let source_file_path = unique_directory.join("invalid.pseudo");
    std::fs::write(
        &source_file_path,
        "Algoritmo P\nEscribir total;\nFinAlgoritmo\n",
    )?;

    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["ir", source_file_path.to_str().unwrap_or("")])
        .output()?;
    assert_eq!(output.status.code(), Some(1));
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("undeclaredVariable"));

    let _removed = std::fs::remove_dir_all(&unique_directory);
    Ok(())
}
