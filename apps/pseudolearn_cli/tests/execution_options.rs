use std::process::Command;

#[test]
fn execution_limits_accept_valid_values_and_bilingual_aliases() -> Result<(), String> {
    for arguments in [
        vec![
            "run",
            "--seed",
            "-7",
            "--depth",
            "9",
            "--statements",
            "12",
            "--cells",
            "50",
            "--tasks",
            "8",
            "--help",
        ],
        vec![
            "ejecutar",
            "--semilla",
            "-7",
            "--profundidad",
            "9",
            "--sentencias",
            "12",
            "--celdas",
            "50",
            "--tareas",
            "8",
            "--ayuda",
        ],
    ] {
        let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
            .args(arguments)
            .output()
            .map_err(|error| error.to_string())?;
        assert!(output.status.success());
        assert_eq!(output.stderr, Vec::<u8>::new());
    }
    Ok(())
}

#[test]
fn execution_limits_reject_missing_malformed_and_overflowing_values() -> Result<(), String> {
    for arguments in [
        vec!["run", "--seed"],
        vec!["run", "--depth", "-1"],
        vec!["run", "--statements", "text"],
        vec!["run", "--cells", "18446744073709551616"],
        vec!["run", "--tasks", "-1"],
        vec!["run", "--tareas"],
        vec!["run", "--seed", "9223372036854775808"],
    ] {
        let output = Command::new(env!("CARGO_BIN_EXE_pseudo"))
            .args(arguments)
            .output()
            .map_err(|error| error.to_string())?;
        assert_eq!(output.status.code(), Some(2));
        assert_ne!(output.stderr, Vec::<u8>::new());
    }
    Ok(())
}
