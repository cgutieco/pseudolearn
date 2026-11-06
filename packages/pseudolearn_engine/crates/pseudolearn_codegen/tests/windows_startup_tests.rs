#![forbid(unsafe_code)]

use object::{Object, ObjectSection, ObjectSymbol};
use pseudolearn_aot_rt::{AotLimits, BooleanWords, ExecutableSettings};
use pseudolearn_codegen::{
    RUNTIME_EXIT_SYMBOL, TLS_DIRECTORY_SYMBOL, TargetConfig, WINDOWS_ENTRY_SYMBOL,
    compile_module_to_executable_object, compile_module_to_object,
};
use pseudolearn_ir::parse_module;
use std::str::FromStr;

const PROGRAM: &str = "module P es
func @main() -> i64 {
b0() mass 0:
  %0 = const.i64 0
  return %0
}
";

fn settings() -> ExecutableSettings {
    ExecutableSettings {
        source_name: "p.pseudo".to_owned(),
        locale: "en".to_owned(),
        forced_collection: false,
        limits: AotLimits::default(),
        boolean_words: BooleanWords {
            truth: "true".to_owned(),
            falsity: "false".to_owned(),
        },
        site_boolean_words: Vec::new(),
        error_template: "{path}\n".to_owned(),
        warning_template: "{path}\n".to_owned(),
        information_template: "{path}\n".to_owned(),
        exhausted_template: "{path}\n".to_owned(),
        source_names: Vec::new(),
    }
}

fn executable_object(triple: &str) -> Result<Vec<u8>, String> {
    let module = parse_module(PROGRAM).map_err(|error| format!("{error:?}"))?;
    let triple = target_lexicon::Triple::from_str(triple).map_err(|error| error.to_string())?;
    compile_module_to_executable_object(&module, &TargetConfig::for_triple(triple), &settings())
        .map(|compiled| compiled.bytes)
        .map_err(|error| error.to_string())
}

fn defined_symbols(bytes: &[u8]) -> Result<Vec<String>, String> {
    let file = object::File::parse(bytes).map_err(|error| error.to_string())?;
    Ok(file
        .symbols()
        .filter(|symbol| symbol.is_definition())
        .filter_map(|symbol| symbol.name().ok().map(str::to_owned))
        .collect())
}

#[test]
fn a_windows_executable_object_defines_its_entry_and_tls_directory() -> Result<(), String> {
    let bytes = executable_object("x86_64-pc-windows-msvc")?;
    let defined = defined_symbols(&bytes)?;
    for expected in [
        WINDOWS_ENTRY_SYMBOL,
        TLS_DIRECTORY_SYMBOL,
        "_tls_index",
        "_fltused",
        "??_7type_info@@6B@",
    ] {
        assert!(defined.iter().any(|name| name == expected), "{expected}");
    }
    let file = object::File::parse(bytes.as_slice()).map_err(|error| error.to_string())?;
    assert!(
        file.symbols()
            .any(|symbol| symbol.is_undefined() && symbol.name() == Ok(RUNTIME_EXIT_SYMBOL))
    );
    let directory = file
        .sections()
        .find(|section| section.name() == Ok(".rdata$T"))
        .ok_or("missing TLS directory section")?;
    assert_eq!(directory.size(), 40);
    assert_eq!(directory.relocations().count(), 4);
    for marker in [".tls$AAA", ".tls$ZZZ", ".CRT$XLA", ".CRT$XLZ"] {
        assert!(
            file.sections().any(|section| section.name() == Ok(marker)),
            "{marker}"
        );
    }
    Ok(())
}

#[test]
fn unix_executable_objects_keep_only_the_c_entry() -> Result<(), String> {
    for triple in [
        "aarch64-apple-darwin",
        "x86_64-apple-darwin",
        "x86_64-unknown-linux-musl",
    ] {
        let defined = defined_symbols(&executable_object(triple)?)?;
        assert!(!defined.iter().any(|name| name == WINDOWS_ENTRY_SYMBOL));
        assert!(!defined.iter().any(|name| name == TLS_DIRECTORY_SYMBOL));
    }
    Ok(())
}

#[test]
fn a_windows_library_object_has_no_process_entry() -> Result<(), String> {
    let module = parse_module(PROGRAM).map_err(|error| format!("{error:?}"))?;
    let triple = target_lexicon::Triple::from_str("x86_64-pc-windows-msvc")
        .map_err(|error| error.to_string())?;
    let compiled = compile_module_to_object(&module, &TargetConfig::for_triple(triple))
        .map_err(|error| error.to_string())?;
    let defined = defined_symbols(&compiled.bytes)?;
    assert!(!defined.iter().any(|name| name == WINDOWS_ENTRY_SYMBOL));
    Ok(())
}
