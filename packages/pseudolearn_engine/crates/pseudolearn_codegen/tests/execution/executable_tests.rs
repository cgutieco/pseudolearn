use crate::support::{Failure, extern_argument, failure, work_directory};
use pseudolearn_aot_rt::{AotLimits, BooleanWords, ExecutableSettings};
use pseudolearn_codegen::{CodegenError, TargetConfig, compile_module_to_executable_object};
use pseudolearn_ir::parse_module;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

const PRINT: &str = "module P es
func @main() -> unit {
b0() mass 0:
  %0 = const.i64 42
  out.write %0, newline @2:1-2:9
  return
}
";

const DIVIDE: &str = "module P es
func @main() -> unit {
b0() mass 0:
  %0 = const.i64 1
  %1 = const.i64 0
  out.write %0, newline @2:1-2:9
  %2 = int.div %0, %1 @3:5-3:9
  out.write %2, newline @4:1-4:9
  return
}
";

const DOUBLE_INPUT: &str = "module P es
func @main() -> unit {
b0() mass 0:
  %0 = in.read i64 @1:1-1:5
  %1 = const.i64 2
  %2 = int.mul %0, %1 @2:1-2:5
  out.write %2, newline @3:1-3:9
  return
}
";

const WITHOUT_MAIN: &str = "module P es
func @other() -> unit {
b0() mass 0:
  return
}
";

const THREE_STATEMENTS: &str = "module P es
func @main() -> unit {
b0() mass 3:
  stmt.enter @1:1-1:9
  %0 = const.i64 1
  out.write %0, newline @1:1-1:9
  stmt.enter @2:1-2:9
  %1 = const.i64 2
  out.write %1, newline @2:1-2:9
  stmt.enter @3:1-3:9
  %2 = const.i64 3
  out.write %2, newline @3:1-3:9
  return
}
";

fn settings() -> ExecutableSettings {
    ExecutableSettings {
        source_name: "p.pseudo".to_owned(),
        locale: "en".to_owned(),
        seed: 42,
        forced_collection: false,
        limits: AotLimits::default(),
        boolean_words: BooleanWords {
            truth: "true".to_owned(),
            falsity: "false".to_owned(),
        },
        error_template: "{path}:{line}:{column}: error: {message} [{code}]\n".to_owned(),
        warning_template: "{path}:{line}:{column}: warning: {message} [{code}]\n".to_owned(),
        information_template: "{path}:{line}:{column}: info: {message} [{code}]\n".to_owned(),
        exhausted_template: "{path}: input ended\n".to_owned(),
    }
}

fn link_executable(module_text: &str) -> Result<PathBuf, Failure> {
    link_with_settings(module_text, &settings())
}

fn link_with_settings(
    module_text: &str,
    configured: &ExecutableSettings,
) -> Result<PathBuf, Failure> {
    let module = parse_module(module_text).map_err(failure)?;
    let compiled = compile_module_to_executable_object(&module, &TargetConfig::host(), configured)
        .map_err(failure)?;
    let directory = work_directory()?;
    let object = directory.join("program.o");
    std::fs::write(&object, &compiled.bytes).map_err(failure)?;
    let source = directory.join("launcher.rs");
    std::fs::write(&source, "#![no_main]\nextern crate pseudolearn_aot_rt;\n").map_err(failure)?;
    let dependencies = std::env::current_exe()
        .map_err(failure)?
        .parent()
        .ok_or_else(|| "no deps directory".to_owned())?
        .to_path_buf();
    let executable = directory.join("program");
    let output = Command::new("rustc")
        .args(["--edition", "2024", "--crate-name", "launcher"])
        .arg(&source)
        .arg("-o")
        .arg(&executable)
        .arg("-L")
        .arg(format!("dependency={}", dependencies.display()))
        .arg("--extern")
        .arg(extern_argument(&dependencies, "pseudolearn_aot_rt")?)
        .arg("-C")
        .arg(format!("link-arg={}", object.display()))
        .output()
        .map_err(failure)?;
    if output.status.success() {
        Ok(executable)
    } else {
        Err(String::from_utf8_lossy(&output.stderr).into_owned())
    }
}

struct Run {
    code: Option<i32>,
    output: String,
    errors: String,
}

fn run_isolated(executable: &Path, input: &str) -> Result<Run, Failure> {
    let scratch = work_directory()?;
    let mut child = Command::new(executable)
        .env_clear()
        .current_dir(scratch)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(failure)?;
    if let Some(mut pipe) = child.stdin.take() {
        pipe.write_all(input.as_bytes()).map_err(failure)?;
    }
    let result = child.wait_with_output().map_err(failure)?;
    Ok(Run {
        code: result.status.code(),
        output: String::from_utf8_lossy(&result.stdout).into_owned(),
        errors: String::from_utf8_lossy(&result.stderr).into_owned(),
    })
}

#[test]
fn a_linked_program_runs_alone_and_prints_its_output() -> Result<(), Failure> {
    let run = run_isolated(&link_executable(PRINT)?, "")?;
    if run.code == Some(0) && run.output == "42\n" && run.errors.is_empty() {
        Ok(())
    } else {
        Err(format!(
            "unexpected run: {:?} {:?} {:?}",
            run.code, run.output, run.errors
        ))
    }
}

#[test]
fn a_runtime_fault_keeps_prior_output_reports_the_site_and_exits_three() -> Result<(), Failure> {
    let run = run_isolated(&link_executable(DIVIDE)?, "")?;
    let reported = run.errors.starts_with("p.pseudo:3:5: error: ")
        && run.errors.ends_with(" [divisionByZero]\n");
    if run.code == Some(3) && run.output == "1\n" && reported {
        Ok(())
    } else {
        Err(format!(
            "unexpected run: {:?} {:?} {:?}",
            run.code, run.output, run.errors
        ))
    }
}

#[test]
fn standard_input_feeds_the_program() -> Result<(), Failure> {
    let run = run_isolated(&link_executable(DOUBLE_INPUT)?, "21\n")?;
    if run.code == Some(0) && run.output == "42\n" {
        Ok(())
    } else {
        Err(format!(
            "unexpected run: {:?} {:?} {:?}",
            run.code, run.output, run.errors
        ))
    }
}

#[test]
fn exhausted_input_exits_four_with_the_exhaustion_message() -> Result<(), Failure> {
    let run = run_isolated(&link_executable(DOUBLE_INPUT)?, "")?;
    if run.code == Some(4) && run.errors == "p.pseudo: input ended\n" {
        Ok(())
    } else {
        Err(format!(
            "unexpected run: {:?} {:?} {:?}",
            run.code, run.output, run.errors
        ))
    }
}

#[test]
fn a_module_without_a_main_function_cannot_become_an_executable() -> Result<(), Failure> {
    let module = parse_module(WITHOUT_MAIN).map_err(failure)?;
    match compile_module_to_executable_object(&module, &TargetConfig::host(), &settings()) {
        Err(CodegenError::InvalidModule(_)) => Ok(()),
        other => Err(format!("expected an invalid module, got {other:?}")),
    }
}

fn with_statement_budget(units: u64) -> ExecutableSettings {
    let mut configured = settings();
    configured.limits.instruction_units = Some(units);
    configured
}

#[test]
fn a_configured_statement_budget_stops_exactly_at_the_statement_that_exceeds_it()
-> Result<(), Failure> {
    let executable = link_with_settings(THREE_STATEMENTS, &with_statement_budget(2))?;
    let run = run_isolated(&executable, "")?;
    let reported = run.errors.starts_with("p.pseudo:3:1: info: ")
        && run.errors.ends_with(" [statementBudgetExhausted]\n");
    if run.code == Some(4) && run.output == "1\n2\n" && reported {
        Ok(())
    } else {
        Err(format!(
            "unexpected run: {:?} {:?} {:?}",
            run.code, run.output, run.errors
        ))
    }
}

#[test]
fn a_statement_budget_that_covers_the_program_lets_it_complete() -> Result<(), Failure> {
    let executable = link_with_settings(THREE_STATEMENTS, &with_statement_budget(3))?;
    let run = run_isolated(&executable, "")?;
    if run.code == Some(0) && run.output == "1\n2\n3\n" && run.errors.is_empty() {
        Ok(())
    } else {
        Err(format!(
            "unexpected run: {:?} {:?} {:?}",
            run.code, run.output, run.errors
        ))
    }
}
