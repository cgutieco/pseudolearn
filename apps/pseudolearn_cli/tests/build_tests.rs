#![forbid(unsafe_code)]

use std::path::{Path, PathBuf};
use std::process::{Command, Output, Stdio};
use std::sync::atomic::{AtomicU32, Ordering};

static COUNTER: AtomicU32 = AtomicU32::new(0);

const PRINT: &str = "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n";
const DOUBLE: &str =
    "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n";
const DIVIDE: &str = "Algoritmo P\nEscribir 1;\nEscribir 1 div 0;\nFinAlgoritmo\n";
const INVALID: &str = "Algoritmo P\nEscribir total;\nFinAlgoritmo\n";

struct Sandbox {
    root: PathBuf,
}

impl Sandbox {
    fn new() -> std::io::Result<Self> {
        let number = COUNTER.fetch_add(1, Ordering::SeqCst);
        let root = Path::new(env!("CARGO_TARGET_TMPDIR"))
            .join(format!("build-{}-{number}", std::process::id()));
        std::fs::create_dir_all(root.join("tmp"))?;
        std::fs::create_dir_all(root.join("work"))?;
        Ok(Self { root })
    }

    fn work(&self) -> PathBuf {
        self.root.join("work")
    }

    fn write(&self, name: &str, content: &str) -> std::io::Result<()> {
        std::fs::write(self.work().join(name), content)
    }

    fn pseudo(&self, arguments: &[&str], path: Option<&str>) -> std::io::Result<Output> {
        let mut command = Command::new(env!("CARGO_BIN_EXE_pseudo"));
        command
            .args(arguments)
            .current_dir(self.work())
            .env("TMPDIR", self.root.join("tmp"));
        if let Some(path) = path {
            command.env("PATH", path);
        }
        command.output()
    }

    fn leftovers(&self) -> std::io::Result<usize> {
        let mut leftover_count: usize = 0;
        for entry in std::fs::read_dir(self.root.join("tmp"))? {
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

    fn work_files(&self) -> std::io::Result<Vec<String>> {
        let mut names: Vec<String> = std::fs::read_dir(self.work())?
            .filter_map(Result::ok)
            .map(|entry| entry.file_name().to_string_lossy().into_owned())
            .collect();
        names.sort();
        Ok(names)
    }

    fn run_isolated(&self, name: &str, input: &str) -> std::io::Result<Output> {
        use std::io::Write;
        let mut child = Command::new(self.work().join(name))
            .env_clear()
            .current_dir(&self.root)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;
        if let Some(mut pipe) = child.stdin.take() {
            pipe.write_all(input.as_bytes())?;
        }
        child.wait_with_output()
    }
}

fn text(bytes: &[u8]) -> String {
    String::from_utf8_lossy(bytes).into_owned()
}

#[test]
fn builds_and_runs_an_executable_that_reads_standard_input() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", DOUBLE)?;
    let build = sandbox.pseudo(&["compilar", "-o", "salida", "p.pseudo"], None)?;
    assert_eq!(build.status.code(), Some(0));
    assert_eq!(text(&build.stdout), "pseudo: ejecutable generado: salida\n");
    assert_eq!(sandbox.leftovers()?, 0);
    let run = sandbox.run_isolated("salida", "21\n")?;
    assert_eq!(
        (run.status.code(), text(&run.stdout)),
        (Some(0), "42\n".to_owned())
    );
    Ok(())
}

#[test]
fn the_default_output_drops_the_source_extension() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", PRINT)?;
    let build = sandbox.pseudo(&["build", "p.pseudo"], None)?;
    assert_eq!(text(&build.stdout), "pseudo: ejecutable generado: p\n");
    assert_eq!(sandbox.work_files()?, ["p", "p.pseudo"]);
    Ok(())
}

#[test]
fn a_source_without_extension_never_overwrites_itself() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("programa", PRINT)?;
    let build = sandbox.pseudo(&["compilar", "programa"], None)?;
    assert_eq!(build.status.code(), Some(0));
    assert_eq!(
        std::fs::read_to_string(sandbox.work().join("programa"))?,
        PRINT
    );
    assert!(sandbox.work().join("programa.out").exists());
    Ok(())
}

#[cfg(unix)]
#[test]
fn the_output_is_executable_by_its_owner() -> std::io::Result<()> {
    use std::os::unix::fs::PermissionsExt;
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", PRINT)?;
    sandbox.pseudo(&["compilar", "p.pseudo"], None)?;
    let mode = std::fs::metadata(sandbox.work().join("p"))?
        .permissions()
        .mode();
    assert_eq!(mode & 0o100, 0o100);
    Ok(())
}

#[test]
fn a_runtime_fault_in_the_executable_exits_three_after_its_output() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", DIVIDE)?;
    sandbox.pseudo(&["compilar", "-o", "salida", "p.pseudo"], None)?;
    let run = sandbox.run_isolated("salida", "")?;
    assert_eq!(run.status.code(), Some(3));
    assert_eq!(text(&run.stdout), "1\n");
    assert!(text(&run.stderr).starts_with("p.pseudo:3:"));
    assert!(text(&run.stderr).contains("[divisionByZero]"));
    Ok(())
}

#[test]
fn an_invalid_program_reports_diagnostics_and_creates_nothing() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", INVALID)?;
    let build = sandbox.pseudo(&["compilar", "-o", "salida", "p.pseudo"], None)?;
    assert_eq!(build.status.code(), Some(1));
    assert_eq!(text(&build.stdout), "");
    assert!(text(&build.stderr).contains("[undeclaredVariable]"));
    assert_eq!(sandbox.work_files()?, ["p.pseudo"]);
    Ok(())
}

#[test]
fn a_missing_input_is_a_usage_error_and_an_unreadable_one_is_operational() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    let missing = sandbox.pseudo(&["compilar"], None)?;
    assert_eq!(missing.status.code(), Some(2));
    let unreadable = sandbox.pseudo(&["compilar", "falta.pseudo"], None)?;
    assert_eq!(unreadable.status.code(), Some(3));
    assert_eq!(
        text(&unreadable.stderr),
        "pseudo: no se puede leer falta.pseudo\n"
    );
    Ok(())
}

#[test]
fn an_output_option_without_a_value_is_a_usage_error() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", PRINT)?;
    let build = sandbox.pseudo(&["compilar", "p.pseudo", "-o"], None)?;
    assert_eq!(build.status.code(), Some(2));
    assert_eq!(sandbox.work_files()?, ["p.pseudo"]);
    Ok(())
}

#[test]
fn a_missing_linker_fails_without_output_or_leftovers() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", PRINT)?;
    let build = sandbox.pseudo(&["compilar", "-o", "salida", "p.pseudo"], Some(""))?;
    assert_eq!(build.status.code(), Some(3));
    assert_eq!(
        text(&build.stderr),
        "pseudo: el enlazador del sistema no está disponible o falló\n"
    );
    assert_eq!(sandbox.work_files()?, ["p.pseudo"]);
    assert_eq!(sandbox.leftovers()?, 0);
    Ok(())
}

#[test]
fn a_failed_build_does_not_replace_an_existing_output() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    sandbox.write("p.pseudo", PRINT)?;
    sandbox.write("salida", "previous")?;
    let build = sandbox.pseudo(&["compilar", "-o", "salida", "p.pseudo"], Some(""))?;
    assert_eq!(build.status.code(), Some(3));
    assert_eq!(
        std::fs::read_to_string(sandbox.work().join("salida"))?,
        "previous"
    );
    Ok(())
}
