use crate::arguments::Arguments;
use see_model::{Corpus, evidence::Conformance};
use std::path::Path;
use std::process::Command;

struct AdapterLaunch {
    directory: &'static str,
    program: &'static str,
    arguments: &'static [&'static str],
}

const CLI_DIRECTORY: &str = "../../apps/pseudolearn_cli";
const REFERENCE_ARGUMENTS: &[&str] = &["run", "tool/conformance_adapter.dart"];
const ENGINE_ARGUMENTS: &[&str] = &[
    "run",
    "-p",
    "pseudolearn_conformance",
    "--bin",
    "conformance_adapter",
    "--quiet",
];
const CLI_ARGUMENTS: &[&str] = &["run", "--bin", "pseudo", "--quiet", "--", "--see-adapter"];
const AOT_ARGUMENTS: &[&str] = &[
    "run",
    "--bin",
    "pseudo",
    "--quiet",
    "--",
    "--see-adapter",
    "aot",
];
const SERVICE_ARGUMENTS: &[&str] = &[
    "run",
    "-p",
    "pseudolearn_conformance",
    "--bin",
    "conformance_adapter",
    "--quiet",
    "--",
    "--subject",
    "service",
];

fn launch_of(subject: &str) -> Option<AdapterLaunch> {
    let (directory, program, arguments) = match subject {
        "reference" => ("../pseudolearn_core", "dart", REFERENCE_ARGUMENTS),
        "engine" => ("../pseudolearn_engine", "cargo", ENGINE_ARGUMENTS),
        "cli" => (CLI_DIRECTORY, "cargo", CLI_ARGUMENTS),
        "aot" => (CLI_DIRECTORY, "cargo", AOT_ARGUMENTS),
        "service" => ("../pseudolearn_engine", "cargo", SERVICE_ARGUMENTS),
        _ => return None,
    };
    Some(AdapterLaunch {
        directory,
        program,
        arguments,
    })
}

pub(crate) fn load_bindings(manifest: &Path) -> Result<Conformance, String> {
    let text = std::fs::read_to_string(manifest).map_err(|error| error.to_string())?;
    serde_saphyr::from_str(&text).map_err(|error| error.to_string())
}

pub(crate) fn subject_configuration(
    arguments: &Arguments,
    corpus: &Corpus,
    subject: &str,
) -> Result<(Command, Conformance), String> {
    let launch = launch_of(subject).ok_or("Unknown subject")?;
    let directory = arguments
        .root
        .join(launch.directory)
        .canonicalize()
        .map_err(|error| error.to_string())?;
    let manifest = crate::bindings::manifest_path(&arguments.root, subject)
        .ok_or("SEE-BINDING: unknown subject")?;
    let conformance = load_bindings(&manifest)?;
    let errors = see_validation::bindings::check(corpus, &conformance);
    if !errors.is_empty() {
        return Err(errors.join("\n"));
    }
    let mut command = Command::new(launch.program);
    command.current_dir(directory).args(launch.arguments);
    Ok((command, conformance))
}
