use pseudolearn_codegen::{TargetConfig, compile_module_to_object};
use std::process::Command;

const MODULE: &str = "module P es
class Node { value: i64 }
func @load_array(%0: array<i64, 1>, %1: i64) -> i64 {
b0() mass 0:
  %2 = array.load %0, %1 @1:1-1:5
  return %2
}
func @store_array(%0: array<i64, 1>, %1: i64) -> i64 {
b0() mass 0:
  %2 = const.i64 42
  array.store %0, %1, %2 @2:1-2:5
  return %2
}
func @load_field(%0: obj<Node>) -> i64 {
b0() mass 0:
  %1 = object.load %0, value @3:1-3:5
  return %1
}
func @store_field(%0: obj<Node>) -> i64 {
b0() mass 0:
  %1 = const.i64 42
  object.store %0, value, %1 @4:1-4:5
  return %1
}
";

#[test]
fn successful_runtime_fallback_is_an_internal_fault_for_each_terminal_access() -> Result<(), String>
{
    let module = pseudolearn_ir::parse_module(MODULE).map_err(|error| error.to_string())?;
    let compiled = compile_module_to_object(&module, &TargetConfig::host().with_verification())
        .map_err(|error| error.to_string())?;
    let directory = std::path::Path::new(env!("CARGO_TARGET_TMPDIR"))
        .join(format!("terminal-success-{}", std::process::id()));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    let source = include_str!("terminal_success.c.template")
        .replace(
            "@@STATUS_OFFSET@@",
            &pseudolearn_aot_rt::CONTEXT_FAULT_STATUS_OFFSET.to_string(),
        )
        .replace(
            "@@CONTEXT_WORDS@@",
            &std::mem::size_of::<pseudolearn_aot_rt::AotRuntimeContext>()
                .div_ceil(8)
                .to_string(),
        );
    std::fs::write(directory.join("launcher.c"), source).map_err(|error| error.to_string())?;
    std::fs::write(directory.join("program.o"), compiled.bytes)
        .map_err(|error| error.to_string())?;
    let output = Command::new("cc")
        .arg(directory.join("launcher.c"))
        .arg(directory.join("program.o"))
        .arg("-o")
        .arg(directory.join("launcher"))
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    let output = Command::new(directory.join("launcher"))
        .output()
        .map_err(|error| error.to_string())?;
    assert!(output.status.success());
    let reported = String::from_utf8(output.stdout).map_err(|error| error.to_string())?;
    for site in reported.lines() {
        let index = site.parse::<usize>().map_err(|error| error.to_string())?;
        assert_eq!(
            compiled
                .fault_sites
                .get(index)
                .map(|site| site.code.as_str()),
            Some("internalFault")
        );
    }
    assert_eq!(reported.lines().count(), 4);
    std::fs::remove_dir_all(directory).map_err(|error| error.to_string())?;
    Ok(())
}
