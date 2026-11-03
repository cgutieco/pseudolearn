use std::process::{Command, Output};
use std::time::Instant;

const ARGUMENTS: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir values Como Argumentos <- Propagar SolicitarArgumentos();\nDefinir list Como Vector<Cadena> <- Propagar values.Valores();\nRetornar Exito(\"[\" + list[0] + \"][\" + list[1] + \"]\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const CLOCK: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nDefinir first Como Entero <- Propagar clock.Ahora();\nDefinir waited Como Entero <- Propagar timer.Esperar(1000000000);\nRetornar Exito(waited - first);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

fn run(name: &str, program: &str, extra: &[&str]) -> std::io::Result<Output> {
    let directory =
        std::env::temp_dir().join(format!("pseudo-authority-{name}-{}", std::process::id()));
    std::fs::create_dir_all(&directory)?;
    let source = directory.join("main.pseudo");
    std::fs::write(&source, program)?;
    let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .current_dir(&directory)
        .arg("run")
        .arg(&source)
        .args(extra)
        .output();
    std::fs::remove_dir_all(directory)?;
    output
}

fn text(output: &Output) -> String {
    String::from_utf8_lossy(&output.stdout).into_owned()
}

#[test]
fn program_arguments_after_the_separator_reach_the_program() -> std::io::Result<()> {
    let output = run("arguments", ARGUMENTS, &["--", "uno", "λ dos"])?;
    assert_eq!(text(&output), "[uno][λ dos]\n", "{output:?}");
    Ok(())
}

#[test]
fn a_real_wait_advances_the_system_clock_by_at_least_the_requested_time() -> std::io::Result<()> {
    let started = Instant::now();
    let output = run("clock", CLOCK, &[])?;
    let elapsed_nanos: i64 = text(&output)
        .trim()
        .parse()
        .map_err(std::io::Error::other)?;
    assert!(elapsed_nanos >= 1_000_000_000, "{output:?}");
    assert!(started.elapsed().as_millis() >= 1000);
    Ok(())
}

#[test]
fn retired_authority_options_are_usage_errors_that_explain_why() -> std::io::Result<()> {
    for flag in [
        "--grant",
        "--conceder",
        "--files",
        "--archivos",
        "--origin",
        "--origen",
        "--local-origin",
        "--origen-local",
    ] {
        let output = run("retired", ARGUMENTS, &[flag, "x"])?;
        assert_eq!(output.status.code(), Some(2), "{flag}: {output:?}");
        let message = String::from_utf8_lossy(&output.stderr);
        assert!(message.contains(flag), "{flag}: {message}");
        assert!(message.contains("autoridad plena") || message.contains("full authority"));
    }
    Ok(())
}

#[test]
fn a_program_without_arguments_receives_an_empty_list() -> std::io::Result<()> {
    let program = ARGUMENTS.replace("\"[\" + list[0] + \"][\" + list[1] + \"]\"", "\"none\"");
    let output = run("empty", &program, &[])?;
    assert_eq!(text(&output), "none\n", "{output:?}");
    Ok(())
}
