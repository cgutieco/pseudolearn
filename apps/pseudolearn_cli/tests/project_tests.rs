#![forbid(unsafe_code)]

use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::sync::atomic::{AtomicU32, Ordering};

static COUNTER: AtomicU32 = AtomicU32::new(0);

const MAIN: &str = "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n";
const REPORT: &str = "public subroutine Informe()\nwrite 7;\nendSubroutine\n";
const LIBRARY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n";
const FAULTY: &str =
    "Publico SubProceso Doble(n Como Entero) Como Real\nRetornar n / 0;\nFinSubProceso\n";
const BROKEN: &str =
    "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar total;\nFinSubProceso\n";
const APP_MANIFEST: &str = "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n";
const GEO_MANIFEST: &str = "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n";
const RUN_OUTPUT: &str = "42\n7\n";

struct Sandbox {
    root: PathBuf,
}

impl Sandbox {
    fn new() -> std::io::Result<Self> {
        let number = COUNTER.fetch_add(1, Ordering::SeqCst);
        let root = Path::new(env!("CARGO_TARGET_TMPDIR"))
            .join(format!("project-{}-{number}", std::process::id()));
        std::fs::create_dir_all(root.join("tmp"))?;
        std::fs::create_dir_all(root.join("elsewhere"))?;
        Ok(Self { root })
    }

    fn project(&self, name: &str, library: &str) -> std::io::Result<PathBuf> {
        let base = self.root.join(name);
        for (path, text) in [
            ("app/pseudolearn.toml", APP_MANIFEST),
            ("geo/pseudolearn.toml", GEO_MANIFEST),
            ("app/main.pseudo", MAIN),
            ("app/informe.pseudo", REPORT),
            ("geo/vectores.pseudo", library),
        ] {
            let target = base.join(path);
            if let Some(parent) = target.parent() {
                std::fs::create_dir_all(parent)?;
            }
            std::fs::write(target, text)?;
        }
        Ok(base)
    }

    fn pseudo(&self, arguments: &[&str], path: Option<&str>) -> std::io::Result<Output> {
        let mut command = Command::new(env!("CARGO_BIN_EXE_pseudo"));
        command
            .args(arguments)
            .current_dir(self.root.join("elsewhere"))
            .env_clear()
            .env("TMPDIR", self.root.join("tmp"))
            .env(
                "PATH",
                path.unwrap_or(&std::env::var("PATH").unwrap_or_default()),
            );
        command.output()
    }

    fn leftovers(&self) -> std::io::Result<usize> {
        Ok(std::fs::read_dir(self.root.join("tmp"))?.count())
    }
}

fn text(bytes: &[u8]) -> String {
    String::from_utf8_lossy(bytes).into_owned()
}

fn directory(path: &Path) -> String {
    path.display().to_string()
}

#[test]
fn a_relocated_project_runs_the_same_from_a_foreign_directory() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    let first = directory(&sandbox.project("first", LIBRARY)?);
    let second = directory(&sandbox.project("moved/second", LIBRARY)?);
    for project in [&first, &second] {
        let run = sandbox.pseudo(
            &["ejecutar", "--proyecto", project, "--entrada", "app/main"],
            None,
        )?;
        assert_eq!(run.status.code(), Some(0));
        assert_eq!(text(&run.stdout), RUN_OUTPUT);
        assert_eq!(text(&run.stderr), "");
    }
    Ok(())
}

#[test]
fn the_standalone_binary_matches_the_vm_result() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    let project = directory(&sandbox.project("p", LIBRARY)?);
    let output = directory(&sandbox.root.join("elsewhere").join("salida"));
    let arguments = [
        "compilar",
        "--proyecto",
        &project,
        "--entrada",
        "app/main",
        "-o",
        &output,
    ];
    let build = sandbox.pseudo(&arguments, None)?;
    assert_eq!(build.status.code(), Some(0));
    let native = Command::new(&output)
        .env_clear()
        .current_dir(&sandbox.root)
        .output()?;
    let vm = sandbox.pseudo(
        &["ejecutar", "--proyecto", &project, "--entrada", "app/main"],
        None,
    )?;
    assert_eq!(text(&native.stdout), text(&vm.stdout));
    assert_eq!(native.status.code(), vm.status.code());
    assert_eq!(sandbox.leftovers()?, 0);
    Ok(())
}

#[test]
fn a_fault_in_an_imported_module_names_its_logical_source() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    let project = directory(&sandbox.project("p", FAULTY)?);
    let run = sandbox.pseudo(
        &["ejecutar", "--proyecto", &project, "--entrada", "app/main"],
        None,
    )?;
    assert_eq!(run.status.code(), Some(1));
    let expected =
        format!("{project}/geo/vectores.pseudo:2:12: error: División por cero [divisionByZero]\n");
    assert_eq!(text(&run.stderr), expected);
    let output = directory(&sandbox.root.join("elsewhere").join("salida"));
    let arguments = [
        "compilar",
        "--proyecto",
        &project,
        "--entrada",
        "app/main",
        "-o",
        &output,
    ];
    assert_eq!(sandbox.pseudo(&arguments, None)?.status.code(), Some(0));
    let native = Command::new(&output).env_clear().output()?;
    assert_eq!(native.status.code(), Some(3));
    assert_eq!(text(&native.stderr), expected);
    Ok(())
}

#[test]
fn a_written_lock_is_verified_and_a_tampered_one_blocks_every_command() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    let project = directory(&sandbox.project("p", LIBRARY)?);
    let lock = sandbox.pseudo(&["bloquear", "--proyecto", &project], None)?;
    assert_eq!(lock.status.code(), Some(0));
    let lock_path = Path::new(&project).join("pseudolearn.lock");
    let canonical = std::fs::read_to_string(&lock_path)?;
    assert!(canonical.starts_with("schema = 1\n"));
    let arguments = ["ejecutar", "--proyecto", &project, "--entrada", "app/main"];
    assert_eq!(text(&sandbox.pseudo(&arguments, None)?.stdout), RUN_OUTPUT);
    std::fs::write(
        &lock_path,
        canonical.replace("origin = \"geo\"", "origin = \"gex\""),
    )?;
    for command in ["comprobar", "ejecutar", "compilar"] {
        let run = sandbox.pseudo(
            &[command, "--proyecto", &project, "--entrada", "app/main"],
            None,
        )?;
        assert_eq!(run.status.code(), Some(3));
        assert_eq!(text(&run.stdout), "");
    }
    Ok(())
}

#[test]
fn a_denied_lock_write_keeps_the_previous_lock_and_leaves_no_temporary() -> std::io::Result<()> {
    use std::os::unix::fs::PermissionsExt;
    let sandbox = Sandbox::new()?;
    let project = sandbox.project("p", LIBRARY)?;
    std::fs::write(project.join("pseudolearn.lock"), "previous")?;
    std::fs::set_permissions(&project, std::fs::Permissions::from_mode(0o555))?;
    let lock = sandbox.pseudo(&["bloquear", "--proyecto", &directory(&project)], None)?;
    std::fs::set_permissions(&project, std::fs::Permissions::from_mode(0o755))?;
    assert_eq!(lock.status.code(), Some(3));
    assert!(text(&lock.stderr).starts_with("pseudo: no se puede escribir"));
    assert_eq!(
        std::fs::read_to_string(project.join("pseudolearn.lock"))?,
        "previous"
    );
    assert!(!project.join(".pseudolearn.lock.partial").exists());
    Ok(())
}

#[test]
fn failed_project_builds_protect_the_previous_output_and_leave_nothing_behind()
-> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    let good = directory(&sandbox.project("good", LIBRARY)?);
    let bad = directory(&sandbox.project("bad", BROKEN)?);
    let output = sandbox.root.join("elsewhere").join("salida");
    std::fs::write(&output, "previous")?;
    let target = directory(&output);
    let broken = [
        "compilar",
        "--proyecto",
        &bad,
        "--entrada",
        "app/main",
        "-o",
        &target,
    ];
    assert_eq!(sandbox.pseudo(&broken, None)?.status.code(), Some(1));
    let no_linker = [
        "compilar",
        "--proyecto",
        &good,
        "--entrada",
        "app/main",
        "-o",
        &target,
    ];
    assert_eq!(sandbox.pseudo(&no_linker, Some(""))?.status.code(), Some(3));
    assert_eq!(std::fs::read_to_string(&output)?, "previous");
    assert_eq!(sandbox.leftovers()?, 0);
    Ok(())
}

#[test]
fn entry_and_option_errors_use_the_documented_exit_codes() -> std::io::Result<()> {
    let sandbox = Sandbox::new()?;
    let project = directory(&sandbox.project("p", LIBRARY)?);
    let missing = sandbox.pseudo(&["ejecutar", "--proyecto", &project], None)?;
    assert_eq!(missing.status.code(), Some(2));
    let unknown = sandbox.pseudo(
        &["ejecutar", "--proyecto", &project, "--entrada", "app/nada"],
        None,
    )?;
    assert_eq!(unknown.status.code(), Some(1));
    let absent = sandbox.pseudo(&["comprobar", "--proyecto", "no-existe"], None)?;
    assert_eq!(absent.status.code(), Some(3));
    Ok(())
}
