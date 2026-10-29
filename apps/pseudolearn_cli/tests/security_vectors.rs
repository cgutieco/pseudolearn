use std::path::{Path, PathBuf};
use std::process::{Command, Output};

const CANARY: &str = "CANARY-FUERA-DE-LA-RAIZ";

fn program(open: &str, tail: &str) -> String {
    format!(
        "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir({open});\n{tail}FinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
    )
}

struct Arena {
    base: PathBuf,
    granted: PathBuf,
}

fn arena(name: &str) -> Result<Arena, Box<dyn std::error::Error>> {
    let base = std::env::temp_dir().join(format!("pseudo-vectors-{name}-{}", std::process::id()));
    let granted = base.join("granted");
    std::fs::create_dir_all(&granted)?;
    std::fs::write(granted.join("a.txt"), "dentro")?;
    std::fs::write(base.join("secret.txt"), CANARY)?;
    Ok(Arena { base, granted })
}

fn run(arena: &Arena, source: &str, extra: &[&str]) -> std::io::Result<Output> {
    let path = arena.base.join("main.pseudo");
    std::fs::write(&path, source)?;
    Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(&path)
        .args(extra)
        .output()
}

fn granted_flags(arena: &Arena, grant: &str) -> Vec<String> {
    vec![
        "--grant".to_owned(),
        grant.to_owned(),
        "--files".to_owned(),
        arena.granted.to_string_lossy().into_owned(),
    ]
}

fn blocked(
    arena: &Arena,
    source: &str,
    grant: &str,
    code: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let flags = granted_flags(arena, grant);
    let refs: Vec<&str> = flags.iter().map(String::as_str).collect();
    let output = run(arena, source, &refs)?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert_eq!(stdout, format!("{code}\n"), "{output:?}");
    assert!(!stdout.contains(CANARY));
    assert_eq!(
        std::fs::read_to_string(arena.base.join("secret.txt"))?,
        CANARY
    );
    Ok(())
}

fn finish(arena: Arena) -> Result<(), Box<dyn std::error::Error>> {
    std::fs::remove_dir_all(arena.base)?;
    Ok(())
}

#[test]
fn parent_directory_escape_is_blocked() -> Result<(), Box<dyn std::error::Error>> {
    let arena = arena("parent")?;
    blocked(
        &arena,
        &program(
            "\"../secret.txt\", \"lectura\"",
            "Retornar file.LeerTexto();\n",
        ),
        "archivos_lectura",
        "ruta_invalida",
    )?;
    finish(arena)
}

#[test]
fn absolute_path_is_blocked() -> Result<(), Box<dyn std::error::Error>> {
    let arena = arena("absolute")?;
    let absolute = arena.base.join("secret.txt").to_string_lossy().into_owned();
    blocked(
        &arena,
        &program(
            &format!("\"{absolute}\", \"lectura\""),
            "Retornar file.LeerTexto();\n",
        ),
        "archivos_lectura",
        "ruta_invalida",
    )?;
    finish(arena)
}

#[cfg(unix)]
#[test]
fn outgoing_symbolic_link_is_blocked() -> Result<(), Box<dyn std::error::Error>> {
    let arena = arena("symlink")?;
    std::os::unix::fs::symlink(arena.base.join("secret.txt"), arena.granted.join("escape"))?;
    blocked(
        &arena,
        &program("\"escape\", \"lectura\"", "Retornar file.LeerTexto();\n"),
        "archivos_lectura",
        "permiso_denegado",
    )?;
    finish(arena)
}

#[test]
fn write_amplification_from_a_read_only_grant_is_blocked() -> Result<(), Box<dyn std::error::Error>>
{
    let arena = arena("amplify")?;
    blocked(
        &arena,
        &program("\"a.txt\", \"escritura\"", "Retornar file.LeerTexto();\n"),
        "archivos_lectura",
        "permiso_denegado",
    )?;
    assert_eq!(
        std::fs::read_to_string(arena.granted.join("a.txt"))?,
        "dentro"
    );
    finish(arena)
}

#[test]
fn use_after_close_is_blocked() -> Result<(), Box<dyn std::error::Error>> {
    let arena = arena("closed")?;
    blocked(
        &arena,
        &program(
            "\"a.txt\", \"lectura\"",
            "Descartar file.Cerrar();\nRetornar file.LeerTexto();\n",
        ),
        "archivos_lectura",
        "capacidad_cerrada",
    )?;
    finish(arena)
}

fn record(arena: &Arena) -> Result<(PathBuf, String), Box<dyn std::error::Error>> {
    let tape = arena.base.join("tape.json");
    let flags = granted_flags(arena, "archivos_lectura");
    let mut arguments: Vec<&str> = flags.iter().map(String::as_str).collect();
    let tape_text = tape.to_string_lossy().into_owned();
    arguments.extend(["--record-tape", &tape_text]);
    let source = program("\"a.txt\", \"lectura\"", "Retornar file.LeerTexto();\n");
    let output = run(arena, &source, &arguments)?;
    assert_eq!(
        String::from_utf8_lossy(&output.stdout),
        "dentro\n",
        "{output:?}"
    );
    Ok((tape, source))
}

fn replay_rejected(
    arena: &Arena,
    tape: &Path,
    source: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    let tape_text = tape.to_string_lossy().into_owned();
    let output = run(
        arena,
        source,
        &["--grant", "archivos_lectura", "--replay-tape", &tape_text],
    )?;
    assert!(!output.status.success(), "{output:?}");
    assert!(output.stdout.is_empty(), "{output:?}");
    Ok(())
}

#[test]
fn single_bit_flip_in_the_tape_is_rejected() -> Result<(), Box<dyn std::error::Error>> {
    let arena = arena("bitflip")?;
    let (tape, source) = record(&arena)?;
    let mut document: serde_json::Value = serde_json::from_slice(&std::fs::read(&tape)?)?;
    let first = document
        .pointer_mut("/entries/0/payload_bytes/0")
        .ok_or("missing payload")?;
    let flipped = first.as_u64().ok_or("payload is not a byte")? ^ 1;
    *first = serde_json::json!(flipped);
    std::fs::write(&tape, serde_json::to_vec(&document)?)?;
    replay_rejected(&arena, &tape, &source)?;
    finish(arena)
}

#[test]
fn truncated_tape_is_rejected() -> Result<(), Box<dyn std::error::Error>> {
    let arena = arena("truncated")?;
    let (tape, source) = record(&arena)?;
    let mut document: serde_json::Value = serde_json::from_slice(&std::fs::read(&tape)?)?;
    document
        .pointer_mut("/entries")
        .and_then(serde_json::Value::as_array_mut)
        .ok_or("missing entries")?
        .pop();
    std::fs::write(&tape, serde_json::to_vec(&document)?)?;
    replay_rejected(&arena, &tape, &source)?;
    finish(arena)
}
