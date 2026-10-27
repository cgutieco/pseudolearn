use std::path::{Path, PathBuf};
use std::process::{Command, Output};

const READER: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a.txt\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const ESCAPER: &str = "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"../secret.txt\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

const WRITER: &str = "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"salida.txt\", \"escritura\");\nRetornar file.EscribirTexto(\"guardado\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n";

struct Space {
    base: PathBuf,
    granted: PathBuf,
}

fn space(name: &str) -> Result<Space, Box<dyn std::error::Error>> {
    let base = std::env::temp_dir().join(format!("pseudo-physical-{name}-{}", std::process::id()));
    let granted = base.join("granted");
    std::fs::create_dir_all(&granted)?;
    std::fs::write(granted.join("a.txt"), "hola")?;
    std::fs::write(base.join("secret.txt"), "afuera")?;
    Ok(Space { base, granted })
}

fn run(space: &Space, program: &str, extra: &[&str]) -> std::io::Result<Output> {
    let source = space.base.join("main.pseudo");
    std::fs::write(&source, program)?;
    Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(&source)
        .args(extra)
        .output()
}

fn granted(space: &Space) -> &Path {
    &space.granted
}

fn text(output: &Output) -> String {
    String::from_utf8_lossy(&output.stdout).into_owned()
}

#[test]
fn physical_read_records_a_tape_that_replays_without_the_disk() -> Result<(), Box<dyn std::error::Error>> {
    let space = space("read")?;
    let tape = space.base.join("tape.json");
    let directory = granted(&space).to_string_lossy().into_owned();
    let tape_path = tape.to_string_lossy().into_owned();
    let live = run(&space, READER, &["--grant", "archivos_lectura", "--files", &directory, "--record-tape", &tape_path])?;
    assert!(live.status.success(), "{live:?}");
    assert_eq!(text(&live), "hola\n");
    std::fs::remove_file(space.granted.join("a.txt"))?;
    let replayed = run(&space, READER, &["--grant", "archivos_lectura", "--replay-tape", &tape_path])?;
    assert!(replayed.status.success(), "{replayed:?}");
    assert_eq!(text(&replayed), "hola\n");
    std::fs::remove_dir_all(space.base)?;
    Ok(())
}

#[test]
fn parent_escape_is_denied_and_the_outside_file_is_never_read() -> Result<(), Box<dyn std::error::Error>> {
    let space = space("escape")?;
    let directory = granted(&space).to_string_lossy().into_owned();
    let output = run(&space, ESCAPER, &["--grant", "archivos_lectura", "--files", &directory])?;
    assert_eq!(text(&output), "ruta_invalida\n", "{output:?}");
    std::fs::remove_dir_all(space.base)?;
    Ok(())
}

#[test]
fn read_only_grant_denies_writing() -> Result<(), Box<dyn std::error::Error>> {
    let space = space("readonly")?;
    let directory = granted(&space).to_string_lossy().into_owned();
    let denied = run(&space, WRITER, &["--grant", "archivos_lectura", "--files", &directory])?;
    assert_eq!(text(&denied), "permiso_denegado\n", "{denied:?}");
    assert!(!space.granted.join("salida.txt").exists());
    std::fs::remove_dir_all(space.base)?;
    Ok(())
}

#[test]
fn write_grant_persists_the_file_inside_the_granted_directory() -> Result<(), Box<dyn std::error::Error>> {
    let space = space("write")?;
    let directory = granted(&space).to_string_lossy().into_owned();
    let output = run(&space, WRITER, &["--grant", "archivos_escritura", "--files", &directory])?;
    assert_eq!(text(&output), "8\n", "{output:?}");
    assert_eq!(std::fs::read_to_string(space.granted.join("salida.txt"))?, "guardado");
    std::fs::remove_dir_all(space.base)?;
    Ok(())
}

#[test]
fn unknown_grant_is_a_usage_error() -> Result<(), Box<dyn std::error::Error>> {
    let space = space("unknown")?;
    let output = run(&space, READER, &["--grant", "red_http"])?;
    assert_eq!(output.status.code(), Some(2));
    std::fs::remove_dir_all(space.base)?;
    Ok(())
}
