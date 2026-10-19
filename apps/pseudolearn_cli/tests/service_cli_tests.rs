#![forbid(unsafe_code)]

use std::io::Write;
use std::process::{Command, Stdio};

#[test]
fn format_prints_canonical_source_to_stdout() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_format_stdout");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("unformatted.pseudo");
    std::fs::write(
        &target_file,
        "algoritmo Principal\ndefinir x como entero\nfinalgoritmo\n",
    )?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["format", target_file.to_str().unwrap_or("")])
        .output()?;

    assert_eq!(process_output.status.code(), Some(0));
    let stdout_content = String::from_utf8_lossy(&process_output.stdout);
    assert_eq!(
        stdout_content,
        "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n"
    );
    Ok(())
}

#[test]
fn format_check_returns_one_when_not_canonical() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_format_check");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("check_needed.pseudo");
    std::fs::write(
        &target_file,
        "algoritmo Principal\ndefinir x como entero\nfinalgoritmo\n",
    )?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args([
            "formatear",
            "--verificar",
            target_file.to_str().unwrap_or(""),
        ])
        .output()?;

    assert_eq!(process_output.status.code(), Some(1));
    let stderr_content = String::from_utf8_lossy(&process_output.stderr);
    assert!(stderr_content.contains("requiere formateo"));
    assert_eq!(process_output.stdout.as_slice(), &[]);
    Ok(())
}

#[test]
fn format_check_returns_zero_when_canonical() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_format_clean");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("clean.pseudo");
    std::fs::write(
        &target_file,
        "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n",
    )?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args([
            "formatear",
            "--verificar",
            target_file.to_str().unwrap_or(""),
        ])
        .output()?;

    assert_eq!(process_output.status.code(), Some(0));
    assert_eq!(process_output.stdout.as_slice(), &[]);
    assert_eq!(process_output.stderr.as_slice(), &[]);
    Ok(())
}

#[test]
fn format_write_updates_file_in_place() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_format_write");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("in_place.pseudo");
    std::fs::write(
        &target_file,
        "algoritmo Principal\ndefinir x como entero\nfinalgoritmo\n",
    )?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["format", "-w", target_file.to_str().unwrap_or("")])
        .output()?;

    assert_eq!(process_output.status.code(), Some(0));
    let file_content = std::fs::read_to_string(&target_file)?;
    assert_eq!(
        file_content,
        "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n"
    );
    Ok(())
}

#[test]
fn format_fails_on_syntax_error() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_format_syntax_error");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("syntax_error.pseudo");
    std::fs::write(&target_file, "Algoritmo Incompleto\n")?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["format", target_file.to_str().unwrap_or("")])
        .output()?;

    assert_eq!(process_output.status.code(), Some(1));
    assert_eq!(process_output.stdout.as_slice(), &[]);
    let stderr_content = String::from_utf8_lossy(&process_output.stderr);
    assert!(!stderr_content.is_empty());
    Ok(())
}

#[test]
fn translate_translates_between_profiles() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_translate");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("spanish.pseudo");
    std::fs::write(
        &target_file,
        "Algoritmo Principal\n  Escribir 1;\nFinAlgoritmo\n",
    )?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args([
            "traducir",
            "--hacia",
            "en",
            target_file.to_str().unwrap_or(""),
        ])
        .output()?;

    assert_eq!(process_output.status.code(), Some(0));
    let stdout_content = String::from_utf8_lossy(&process_output.stdout);
    assert_eq!(
        stdout_content,
        "Algorithm Principal\n  Write 1;\nEndAlgorithm\n"
    );
    Ok(())
}

#[test]
fn translate_fails_on_identifier_collision() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_translate_collision");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("collision.pseudo");
    std::fs::write(
        &target_file,
        "Algorithm Colision\n  Define fin As Integer;\nEndAlgorithm\n",
    )?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args([
            "translate",
            "--to",
            "es",
            target_file.to_str().unwrap_or(""),
        ])
        .output()?;

    assert_eq!(process_output.status.code(), Some(1));
    let stderr_content = String::from_utf8_lossy(&process_output.stderr);
    assert!(stderr_content.contains("reservedLexemeUsedAsName"));
    assert_eq!(process_output.stdout.as_slice(), &[]);
    Ok(())
}

#[test]
fn translate_fails_without_target_profile() -> Result<(), Box<dyn std::error::Error>> {
    let working_directory = std::env::temp_dir().join("pseudo_cli_translate_no_target");
    std::fs::create_dir_all(&working_directory)?;
    let target_file = working_directory.join("sample.pseudo");
    std::fs::write(&target_file, "Algoritmo P\nFinAlgoritmo\n")?;

    let process_output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["traducir", target_file.to_str().unwrap_or("")])
        .output()?;

    assert_eq!(process_output.status.code(), Some(2));
    let stderr_content = String::from_utf8_lossy(&process_output.stderr);
    assert!(stderr_content.contains("falta la opción requerida --hacia"));
    Ok(())
}

#[test]
fn lsp_initializes_and_shuts_down() -> Result<(), Box<dyn std::error::Error>> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("lsp")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    let mut stdin_stream = child.stdin.take().ok_or("Missing child stdin")?;

    let initialize_payload =
        r#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}"#;
    let initialize_message = format!(
        "Content-Length: {}\r\n\r\n{}",
        initialize_payload.len(),
        initialize_payload
    );
    stdin_stream.write_all(initialize_message.as_bytes())?;

    let shutdown_payload = r#"{"jsonrpc":"2.0","id":2,"method":"shutdown","params":null}"#;
    let shutdown_message = format!(
        "Content-Length: {}\r\n\r\n{}",
        shutdown_payload.len(),
        shutdown_payload
    );
    stdin_stream.write_all(shutdown_message.as_bytes())?;

    let exit_payload = r#"{"jsonrpc":"2.0","method":"exit","params":null}"#;
    let exit_message = format!(
        "Content-Length: {}\r\n\r\n{}",
        exit_payload.len(),
        exit_payload
    );
    stdin_stream.write_all(exit_message.as_bytes())?;
    drop(stdin_stream);

    let output = child.wait_with_output()?;
    assert_eq!(output.status.code(), Some(0));
    let stdout_content = String::from_utf8_lossy(&output.stdout);
    assert!(stdout_content.contains("capabilities"));
    Ok(())
}

fn lsp_frames(messages: &[&str]) -> Vec<u8> {
    messages
        .iter()
        .flat_map(|payload| {
            format!("Content-Length: {}\r\n\r\n{payload}", payload.len()).into_bytes()
        })
        .collect()
}

fn run_lsp(messages: &[&str]) -> Result<(Option<i32>, String), Box<dyn std::error::Error>> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("lsp")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;
    let mut input = child.stdin.take().ok_or("Missing child stdin")?;
    input.write_all(&lsp_frames(messages))?;
    drop(input);
    let output = child.wait_with_output()?;
    Ok((
        output.status.code(),
        String::from_utf8_lossy(&output.stdout).into_owned(),
    ))
}

#[test]
fn translate_reports_the_collision_position_and_writes_nothing()
-> Result<(), Box<dyn std::error::Error>> {
    let directory = std::env::temp_dir().join("pseudo_cli_translate_position");
    std::fs::create_dir_all(&directory)?;
    let source = directory.join("collision.pseudo");
    std::fs::write(
        &source,
        "Algorithm Colision\n  Define fin As Integer;\nEndAlgorithm\n",
    )?;
    let destination = directory.join("never.pseudo");
    let _ = std::fs::remove_file(&destination);

    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args([
            "translate",
            "--to",
            "es",
            "--output",
            destination.to_str().unwrap_or(""),
            source.to_str().unwrap_or(""),
        ])
        .output()?;

    assert_eq!(output.status.code(), Some(1));
    assert!(String::from_utf8_lossy(&output.stderr).contains(":2:10"));
    assert!(!destination.exists());
    Ok(())
}

#[test]
fn translate_writes_the_translation_to_the_output_file() -> Result<(), Box<dyn std::error::Error>> {
    let directory = std::env::temp_dir().join("pseudo_cli_translate_output");
    std::fs::create_dir_all(&directory)?;
    let source = directory.join("input.pseudo");
    std::fs::write(&source, "Algoritmo Hola\n  Escribir 1;\nFinAlgoritmo\n")?;
    let destination = directory.join("output.pseudo");

    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args([
            "traducir",
            "--hacia",
            "en",
            "-o",
            destination.to_str().unwrap_or(""),
            source.to_str().unwrap_or(""),
        ])
        .output()?;

    assert_eq!(output.status.code(), Some(0));
    assert_eq!(output.stdout.as_slice(), &[]);
    assert_eq!(
        std::fs::read_to_string(&destination)?,
        "Algorithm Hola\n  Write 1;\nEndAlgorithm\n"
    );
    Ok(())
}

#[test]
fn format_check_on_a_broken_file_fails_without_touching_it()
-> Result<(), Box<dyn std::error::Error>> {
    let directory = std::env::temp_dir().join("pseudo_cli_format_check_broken");
    std::fs::create_dir_all(&directory)?;
    let target = directory.join("broken.pseudo");
    let broken = "Algoritmo P\n  Si x >\nFinAlgoritmo\n";
    std::fs::write(&target, broken)?;

    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["formatear", "--verificar", target.to_str().unwrap_or("")])
        .output()?;

    assert_eq!(output.status.code(), Some(1));
    assert_eq!(std::fs::read_to_string(&target)?, broken);
    Ok(())
}

#[test]
fn lsp_serves_diagnostics_and_completion_over_the_wire() -> Result<(), Box<dyn std::error::Error>> {
    let open = r#"{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///a.pseudo","languageId":"pseudolearn","version":1,"text":"Algoritmo Año\n  Definir ñandú Como Entero;\n  ñan\nFinAlgoritmo\n"}}}"#;
    let complete = r#"{"jsonrpc":"2.0","id":2,"method":"textDocument/completion","params":{"textDocument":{"uri":"file:///a.pseudo"},"position":{"line":2,"character":5}}}"#;
    let (code, stdout) = run_lsp(&[
        r#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es"}}"#,
        open,
        complete,
        r#"{"jsonrpc":"2.0","id":3,"method":"shutdown"}"#,
        r#"{"jsonrpc":"2.0","method":"exit"}"#,
    ])?;
    assert_eq!(code, Some(0));
    assert!(stdout.contains("publishDiagnostics"));
    assert!(stdout.contains("\"label\":\"ñandú\""));
    Ok(())
}

#[test]
fn lsp_exits_with_failure_when_the_client_never_shuts_it_down()
-> Result<(), Box<dyn std::error::Error>> {
    let (code, _) = run_lsp(&[
        r#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}"#,
        r#"{"jsonrpc":"2.0","method":"exit"}"#,
    ])?;
    assert_eq!(code, Some(1));
    let (closed, _) = run_lsp(&[r#"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}"#])?;
    assert_eq!(closed, Some(1));
    Ok(())
}
