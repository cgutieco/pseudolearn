use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Output, Stdio};

const PROGRAM: &str = "Algoritmo Main\nEscribir 42;\nEscribir \"hola\";\nFinAlgoritmo\n";

struct Workspace {
    directory: PathBuf,
    source: PathBuf,
}

fn workspace(name: &str, program: &str) -> Result<Workspace, Box<dyn std::error::Error>> {
    let directory = std::env::temp_dir().join(format!("pseudo-{name}-{}", std::process::id()));
    std::fs::create_dir_all(&directory)?;
    let source = directory.join("main.pseudo");
    std::fs::write(&source, program)?;
    Ok(Workspace { directory, source })
}

fn run(source: &Path, flags: &[&str], tape: &Path, stdin: &str) -> std::io::Result<Output> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(source)
        .args(flags)
        .arg(tape)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;
    if let Some(mut pipe) = child.stdin.take() {
        pipe.write_all(stdin.as_bytes())?;
    }
    child.wait_with_output()
}

fn flags(native: bool, tape_flag: &str) -> Vec<&str> {
    let mut chosen = vec![tape_flag];
    if native {
        chosen.insert(0, "--native");
    }
    chosen
}

#[test]
fn vm_tape_replays_natively_and_native_tape_replays_in_vm() -> Result<(), Box<dyn std::error::Error>> {
    let space = workspace("tape-parity", PROGRAM)?;
    let vm_tape = space.directory.join("vm.json");
    let native_tape = space.directory.join("native.json");
    let vm = run(&space.source, &flags(false, "--record-tape"), &vm_tape, "")?;
    let native = run(&space.source, &flags(true, "--record-tape"), &native_tape, "")?;
    assert!(vm.status.success(), "{vm:?}");
    assert!(native.status.success(), "{native:?}");
    assert_eq!(vm.stdout, native.stdout);
    let vm_replayed_natively = run(&space.source, &flags(true, "--replay-tape"), &vm_tape, "")?;
    let native_replayed_in_vm = run(&space.source, &flags(false, "--replay-tape"), &native_tape, "")?;
    assert!(vm_replayed_natively.status.success(), "{vm_replayed_natively:?}");
    assert!(native_replayed_in_vm.status.success(), "{native_replayed_in_vm:?}");
    assert_eq!(vm_replayed_natively.stdout, vm.stdout);
    assert_eq!(native_replayed_in_vm.stdout, vm.stdout);
    std::fs::remove_dir_all(space.directory)?;
    Ok(())
}

#[test]
fn native_replay_rejects_a_corrupted_tape() -> Result<(), Box<dyn std::error::Error>> {
    let space = workspace("tape-corrupt", PROGRAM)?;
    let tape = space.directory.join("vm.json");
    let vm = run(&space.source, &flags(false, "--record-tape"), &tape, "")?;
    assert!(vm.status.success(), "{vm:?}");
    let mut document: serde_json::Value = serde_json::from_slice(&std::fs::read(&tape)?)?;
    *document
        .pointer_mut("/entries/0/entry_hash")
        .ok_or("missing hash")? = serde_json::json!("corrupted");
    std::fs::write(&tape, serde_json::to_vec(&document)?)?;
    let rejected = run(&space.source, &flags(true, "--replay-tape"), &tape, "")?;
    assert!(!rejected.status.success());
    assert!(rejected.stdout.is_empty(), "{rejected:?}");
    std::fs::remove_dir_all(space.directory)?;
    Ok(())
}

#[test]
fn native_run_rejects_observation() -> Result<(), Box<dyn std::error::Error>> {
    let space = workspace("tape-observe", PROGRAM)?;
    let tape = space.directory.join("out.json");
    let rejected = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["run", "--native", "--trace"])
        .arg(&space.source)
        .args(["--record-tape"])
        .arg(&tape)
        .output()?;
    assert_eq!(rejected.status.code(), Some(2), "{rejected:?}");
    assert!(!tape.exists());
    std::fs::remove_dir_all(space.directory)?;
    Ok(())
}

const READER: &str = "Algoritmo Main\nDefinir Mutable name Como Cadena <- \"\";\nLeer name;\nEscribir name;\nFinAlgoritmo\n";

#[test]
fn replay_reads_input_from_the_tape_without_standard_input() -> Result<(), Box<dyn std::error::Error>> {
    let space = workspace("tape-read", READER)?;
    let vm_tape = space.directory.join("vm.json");
    let native_tape = space.directory.join("native.json");
    let vm = run(&space.source, &flags(false, "--record-tape"), &vm_tape, "mundo\n")?;
    let native = run(&space.source, &flags(true, "--record-tape"), &native_tape, "mundo\n")?;
    assert_eq!(vm.stdout, b"mundo\n");
    assert_eq!(native.stdout, b"mundo\n");
    for (native_replay, tape) in [(false, &vm_tape), (true, &vm_tape), (false, &native_tape), (true, &native_tape)] {
        let replayed = run(&space.source, &flags(native_replay, "--replay-tape"), tape, "")?;
        assert!(replayed.status.success(), "{replayed:?}");
        assert_eq!(replayed.stdout, b"mundo\n");
    }
    std::fs::remove_dir_all(space.directory)?;
    Ok(())
}
