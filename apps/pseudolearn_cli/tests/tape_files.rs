use std::path::Path;
use std::process::{Command, Output};

fn pseudo_run(source: &Path, flag: &str, tape: &Path) -> std::io::Result<Output> {
    Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(source)
        .arg(flag)
        .arg(tape)
        .output()
}

#[test]
fn cli_persists_and_replays_tape() -> Result<(), Box<dyn std::error::Error>> {
    let directory = std::env::temp_dir().join(format!("pseudo-tape-{}", std::process::id()));
    std::fs::create_dir_all(&directory)?;
    let source = directory.join("main.pseudo");
    let tape = directory.join("tape.json");
    std::fs::write(&source, "Algoritmo Main\nEscribir 42;\nFinAlgoritmo\n")?;
    let recorded = pseudo_run(&source, "--record-tape", &tape)?;
    assert!(recorded.status.success(), "{recorded:?}");
    let value: serde_json::Value = serde_json::from_slice(&std::fs::read(&tape)?)?;
    assert!(
        value
            .get("entries")
            .and_then(serde_json::Value::as_array)
            .is_some_and(|entries| !entries.is_empty())
    );
    let replayed = pseudo_run(&source, "--replay-tape", &tape)?;
    assert!(replayed.status.success(), "{replayed:?}");
    assert_eq!(recorded.stdout, replayed.stdout);
    let mut damaged = value;
    *damaged
        .pointer_mut("/entries/0/entry_hash")
        .ok_or("missing hash")? = serde_json::json!("corrupted");
    std::fs::write(&tape, serde_json::to_vec(&damaged)?)?;
    let rejected = pseudo_run(&source, "--replay-tape", &tape)?;
    assert!(!rejected.status.success());
    assert_eq!(rejected.stdout, Vec::<u8>::new());
    std::fs::remove_dir_all(directory)?;
    Ok(())
}

#[test]
fn cli_rejects_unreadable_replay_tape() -> Result<(), Box<dyn std::error::Error>> {
    let directory =
        std::env::temp_dir().join(format!("pseudo-missing-tape-{}", std::process::id()));
    std::fs::create_dir_all(&directory)?;
    let source = directory.join("main.pseudo");
    std::fs::write(&source, "Algoritmo Main\nFinAlgoritmo\n")?;
    let rejected = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .arg("run")
        .arg(&source)
        .arg("--replay-tape")
        .arg(directory.join("missing.json"))
        .output()?;
    assert_eq!(rejected.status.code(), Some(3));
    std::fs::remove_dir_all(directory)?;
    Ok(())
}
