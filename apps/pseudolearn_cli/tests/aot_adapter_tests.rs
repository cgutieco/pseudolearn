#![forbid(unsafe_code)]

use serde_json::{Value, json};
use std::io::Write;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use std::sync::atomic::{AtomicU32, Ordering};

static COUNTER: AtomicU32 = AtomicU32::new(0);

const DOUBLE: &str =
    "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n";
const DIVIDE: &str = "Algoritmo P\nEscribir 1;\nEscribir 1 div 0;\nFinAlgoritmo\n";
const THREE: &str = "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n";
const INVALID: &str = "Algoritmo P\nEscribir total;\nFinAlgoritmo\n";

struct Temporary(PathBuf);

impl Temporary {
    fn new() -> std::io::Result<Self> {
        let number = COUNTER.fetch_add(1, Ordering::SeqCst);
        let root = PathBuf::from(env!("CARGO_TARGET_TMPDIR"))
            .join(format!("aot-adapter-{}-{number}", std::process::id()));
        std::fs::create_dir_all(&root)?;
        Ok(Self(root))
    }

    fn leftovers(&self) -> std::io::Result<usize> {
        let mut leftover_count: usize = 0;
        for entry in std::fs::read_dir(&self.0)? {
            let file_name = entry?.file_name();
            let belongs_to_cli = file_name.to_str().is_some_and(|name| {
                name.starts_with("pseudo_aot_") || name.starts_with("pseudo_link_")
            });
            if belongs_to_cli {
                leftover_count = leftover_count.saturating_add(1);
            }
        }
        Ok(leftover_count)
    }
}

fn execute(program: &str, inputs: &[&str]) -> Value {
    json!({"kind":"execute","program":program,"profile":"es","strictness":"strict",
        "inputs":inputs,"seed":42,"observe":"none","limits":{"micro_steps":100_000}})
}

fn converse(temporary: &Temporary, requests: &[Value], close: bool) -> std::io::Result<Vec<Value>> {
    let mut child = Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(["--see-adapter", "aot"])
        .env("TMPDIR", &temporary.0)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn()?;
    if let Some(mut pipe) = child.stdin.take() {
        for request in requests {
            writeln!(pipe, "{request}")?;
        }
        if close {
            writeln!(pipe, "{}", json!({"kind":"shutdown"}))?;
        }
    }
    let output = child.wait_with_output()?;
    Ok(String::from_utf8_lossy(&output.stdout)
        .lines()
        .filter_map(|line| serde_json::from_str(line).ok())
        .collect())
}

#[test]
fn the_adapter_announces_the_aot_subject_and_only_the_capabilities_it_implements()
-> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let replies = converse(&temporary, &[json!({"kind":"hello"})], true)?;
    let hello = replies.first().cloned().unwrap_or(Value::Null);
    assert_eq!(hello["subject"], json!("aot"));
    assert_eq!(hello["capabilities"], json!(["execute", "gc_stress"]));
    assert_eq!(replies.get(1), Some(&json!({"kind":"shutdown"})));
    Ok(())
}

#[test]
fn a_program_runs_as_a_real_executable_with_inputs() -> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let replies = converse(&temporary, &[execute(DOUBLE, &["21"])], true)?;
    let reply = replies.first().cloned().unwrap_or(Value::Null);
    assert_eq!(reply["output"], json!("42\n"));
    assert_eq!(reply["termination"], json!({"kind":"completed"}));
    Ok(())
}

#[test]
fn a_runtime_failure_keeps_prior_output_and_reports_code_and_span() -> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let replies = converse(&temporary, &[execute(DIVIDE, &[])], true)?;
    let reply = replies.first().cloned().unwrap_or(Value::Null);
    assert_eq!(reply["output"], json!("1\n"));
    assert_eq!(
        reply["termination"],
        json!({"kind":"failed","code":"divisionByZero"})
    );
    assert_eq!(
        reply["diagnostics"][0]["span"]["start"],
        json!({"line":3,"column":12})
    );
    Ok(())
}

#[test]
fn exhausted_input_and_a_statement_budget_have_their_own_terminations() -> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let mut limited = execute(THREE, &[]);
    limited["limits"] = json!({"statements":2});
    let replies = converse(&temporary, &[execute(DOUBLE, &[]), limited], true)?;
    assert_eq!(replies[0]["termination"], json!({"kind":"awaiting_input"}));
    assert_eq!(
        replies[1]["termination"],
        json!({"kind":"limit_reached","limit":"statements"})
    );
    assert_eq!(replies[1]["output"], json!("1\n2\n"));
    Ok(())
}

#[test]
fn a_rejected_program_reports_its_diagnostics_without_running() -> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let replies = converse(&temporary, &[execute(INVALID, &[])], true)?;
    assert_eq!(
        replies[0]["termination"],
        json!({"kind":"failed","code":"analysisFailed"})
    );
    assert_eq!(
        replies[0]["diagnostics"][0]["code"],
        json!("undeclaredVariable")
    );
    Ok(())
}

#[test]
fn unsupported_requests_are_answered_with_an_error() -> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let replies = converse(&temporary, &[json!({"kind":"analyze"})], true)?;
    assert_eq!(replies[0]["kind"], json!("error"));
    Ok(())
}

#[test]
fn repeated_programs_reuse_one_executable_and_nothing_is_left_behind() -> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let request = execute(DOUBLE, &["4"]);
    let replies = converse(
        &temporary,
        &[request.clone(), request.clone(), request],
        true,
    )?;
    let executions: Vec<&Value> = replies
        .iter()
        .filter(|reply| reply["kind"] == json!("execute"))
        .collect();
    assert_eq!(executions.len(), 3);
    assert!(
        executions
            .iter()
            .all(|reply| reply["output"] == json!("8\n"))
    );
    assert_eq!(temporary.leftovers()?, 0);
    Ok(())
}

#[test]
fn closing_the_input_without_a_shutdown_also_cleans_up() -> std::io::Result<()> {
    let temporary = Temporary::new()?;
    let replies = converse(&temporary, &[execute(DOUBLE, &["1"])], false)?;
    assert_eq!(replies.len(), 1);
    assert_eq!(temporary.leftovers()?, 0);
    Ok(())
}
