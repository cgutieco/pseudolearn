use crate::build_runtime_targets::{RuntimeTarget, compile_static_library, runtime_targets};
use std::fmt::Write;
use std::path::{Path, PathBuf};

const ENGINE: &str = "../../packages/pseudolearn_engine";
const RUNTIME_CRATES: [&str; 7] = [
    "pseudolearn_aot_rt",
    "pseudolearn_runtime",
    "pseudolearn_library",
    "pseudolearn_diagnostics",
    "pseudolearn_abi",
    "pseudolearn_source",
    "pseudolearn_host",
];
const TABLE_NAME: &str = "runtime_archives.rs";

struct BuiltArchive {
    triple: String,
    archive: PathBuf,
    support: Vec<(String, PathBuf)>,
    imports: String,
}

pub fn build() -> Result<(), Box<dyn std::error::Error>> {
    let manifest = PathBuf::from(std::env::var("CARGO_MANIFEST_DIR")?);
    let engine = manifest.join(ENGINE);
    announce_inputs(&engine);
    let out_dir = PathBuf::from(std::env::var("OUT_DIR")?);
    let mut built = Vec::new();
    for target in runtime_targets()? {
        match build_target(&engine, &out_dir, &target) {
            Ok(archive) => built.push(archive),
            Err(error) if target.required => return Err(error),
            Err(error) => println!(
                "cargo:warning=runtime for {} not built: {error}",
                target.triple
            ),
        }
    }
    std::fs::write(out_dir.join(TABLE_NAME), table(&built)?)?;
    Ok(())
}

fn announce_inputs(engine: &Path) {
    println!(
        "cargo:rerun-if-changed={}",
        engine.join("Cargo.lock").display()
    );
    for name in RUNTIME_CRATES {
        println!(
            "cargo:rerun-if-changed={}",
            engine.join("crates").join(name).display()
        );
    }
}

fn build_target(
    engine: &Path,
    out_dir: &Path,
    target: &RuntimeTarget,
) -> Result<BuiltArchive, Box<dyn std::error::Error>> {
    let directory = out_dir.join(&target.triple);
    std::fs::create_dir_all(&directory)?;
    let produced = compile_static_library(engine, &out_dir.join("runtime_target"), target)?;
    let archive = directory.join("runtime_archive");
    std::fs::copy(&produced, &archive)?;
    strip_debug_information(&archive, target);
    let support = crate::build_runtime_targets::copy_support_files(target, &directory)?;
    let imports = if target.windows_imports {
        crate::build_windows_imports::resolve_imports(&std::fs::read(&archive)?)?
    } else {
        String::new()
    };
    Ok(BuiltArchive {
        triple: target.triple.clone(),
        archive,
        support,
        imports,
    })
}

fn table(built: &[BuiltArchive]) -> Result<String, std::fmt::Error> {
    let mut generated =
        String::from("pub(crate) static RUNTIME_ARCHIVES: &[RuntimeArchive] = &[\n");
    for entry in built {
        writeln!(
            generated,
            "RuntimeArchive {{ triple: {:?}, archive: include_bytes!({:?}), support: &[",
            entry.triple,
            entry.archive.display().to_string()
        )?;
        for (name, path) in &entry.support {
            writeln!(
                generated,
                "({name:?}, include_bytes!({:?})),",
                path.display().to_string()
            )?;
        }
        writeln!(generated, "], imports: {:?} }},", entry.imports)?;
    }
    generated.push_str("];\n");
    Ok(generated)
}

fn strip_debug_information(archive: &Path, target: &RuntimeTarget) {
    if !target.native_strip {
        return;
    }
    let _stripped = std::process::Command::new("strip")
        .arg("--strip-debug")
        .arg(archive)
        .status();
}
