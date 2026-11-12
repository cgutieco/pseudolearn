#![forbid(unsafe_code)]

use object::{Architecture, BinaryFormat, Object};
use pseudolearn_codegen::{TargetConfig, compile_module_to_object};
use pseudolearn_ir::parse_module;
use std::str::FromStr;

const PROGRAM: &str = "module P es
func @main() -> i64 {
b0() mass 0:
  %0 = const.i64 21
  %1 = const.i64 2
  %2 = int.mul %0, %1 @1:1-1:5
  return %2
}
";

const TARGETS: &[(&str, BinaryFormat, Architecture)] = &[
    (
        "aarch64-apple-darwin",
        BinaryFormat::MachO,
        Architecture::Aarch64,
    ),
    (
        "x86_64-apple-darwin",
        BinaryFormat::MachO,
        Architecture::X86_64,
    ),
    (
        "x86_64-unknown-linux-musl",
        BinaryFormat::Elf,
        Architecture::X86_64,
    ),
    (
        "x86_64-pc-windows-msvc",
        BinaryFormat::Coff,
        Architecture::X86_64,
    ),
];

#[test]
fn every_declared_target_emits_an_object_of_its_format() -> Result<(), String> {
    let module = parse_module(PROGRAM).map_err(|error| format!("{error:?}"))?;
    for (triple, format, architecture) in TARGETS {
        let triple = target_lexicon::Triple::from_str(triple).map_err(|error| error.to_string())?;
        let compiled = compile_module_to_object(&module, &TargetConfig::for_triple(triple))
            .map_err(|error| error.to_string())?;
        let file =
            object::File::parse(compiled.bytes.as_slice()).map_err(|error| error.to_string())?;
        assert_eq!(file.format(), *format);
        assert_eq!(file.architecture(), *architecture);
    }
    Ok(())
}

#[test]
fn an_unknown_triple_is_rejected_as_a_target_error() -> Result<(), String> {
    let module = parse_module(PROGRAM).map_err(|error| format!("{error:?}"))?;
    let triple = target_lexicon::Triple::from_str("riscv64gc-unknown-linux-gnu")
        .map_err(|error| error.to_string())?;
    let compiled = compile_module_to_object(&module, &TargetConfig::for_triple(triple));
    assert!(matches!(
        compiled,
        Err(pseudolearn_codegen::CodegenError::Target(_))
    ));
    Ok(())
}
