use std::path::PathBuf;
use std::process::{Command, Output};

fn acceptance_path(name: &str) -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("examples/language-constructs/acceptance")
        .join(name)
}

fn pseudo(arguments: &[&str]) -> std::io::Result<Output> {
    Command::new(env!("CARGO_BIN_EXE_pseudo"))
        .args(arguments)
        .output()
}

fn standard_output(output: &Output) -> String {
    String::from_utf8_lossy(&output.stdout).into_owned()
}

#[test]
fn single_file_constructs_print_the_values_derived_from_the_rules() -> std::io::Result<()> {
    let program = acceptance_path("constructs.es.pseudo");
    let output = pseudo(&["run", &program.to_string_lossy()])?;
    assert_eq!(
        standard_output(&output),
        "3:15\n7\n4:6\n12:0\n5050\n",
        "{output:?}"
    );
    assert_eq!(output.status.code(), Some(0));
    Ok(())
}

#[test]
fn imported_types_constants_and_templates_run_as_a_project() -> std::io::Result<()> {
    let project = acceptance_path("project");
    let output = pseudo(&[
        "run",
        "--project",
        &project.to_string_lossy(),
        "--entry",
        "app/main",
    ])?;
    assert_eq!(
        standard_output(&output),
        "8:Verde:8:14\n4:hola\n",
        "{output:?}"
    );
    assert_eq!(output.status.code(), Some(0));
    Ok(())
}

#[test]
fn block_objects_fit_in_the_cells_of_a_single_iteration() -> std::io::Result<()> {
    let program = acceptance_path("scope.es.pseudo");
    let fits = pseudo(&["run", "--celdas", "4", &program.to_string_lossy()])?;
    assert_eq!(standard_output(&fits), "1\n", "{fits:?}");
    assert_eq!(fits.status.code(), Some(0));
    let short = pseudo(&["run", "--celdas", "1", &program.to_string_lossy()])?;
    assert_eq!(standard_output(&short), "", "{short:?}");
    assert_ne!(short.status.code(), Some(0));
    Ok(())
}
