#![forbid(unsafe_code)]

use object::{Object, ObjectSection, ObjectSymbol, RelocationTarget};
use pseudolearn_aot_rt::{KIND_INTEGER, KIND_REAL, KIND_REFERENCE};
use pseudolearn_codegen::{
    CodegenError, FAULT_SYMBOL, INTEGER_POWER_SYMBOL, MATH_UNARY_SYMBOL, REAL_POWER_SYMBOL,
    TargetConfig, compile_module_to_object, function_symbol,
};
use pseudolearn_ir::parse_module;

const PROGRAM: &str = "module P es
func @double(%0: i64) -> i64 {
b0() mass 0:
  %1 = const.i64 2
  %2 = int.mul %0, %1 @2:5-2:9
  %3 = int.pow %2, %1 @3:5-3:9
  %4 = int.to_real %3
  %5 = real.pow %4, %4 @4:5-4:9
  %6 = real.trunc %5 @5:5-5:9
  return %6
}
func @main() -> i64 {
b0() mass 0:
  %0 = const.i64 21
  %1 = call @double(%0) @8:5-8:15
  return %1
}
";

fn compile(text: &str) -> Result<pseudolearn_codegen::CompiledObject, String> {
    let module = parse_module(text)?;
    compile_module_to_object(&module, &TargetConfig::host().with_verification())
        .map_err(|error| error.to_string())
}

fn bare(name: &str) -> &str {
    name.strip_prefix('_').unwrap_or(name)
}

#[test]
fn every_undefined_symbol_is_a_runtime_entry_and_every_function_is_exported() -> Result<(), String>
{
    let compiled = compile(PROGRAM)?;
    let file = object::File::parse(compiled.bytes.as_slice()).map_err(|error| error.to_string())?;
    let required = [
        FAULT_SYMBOL,
        MATH_UNARY_SYMBOL,
        REAL_POWER_SYMBOL,
        INTEGER_POWER_SYMBOL,
    ];
    let mut imported = Vec::new();
    let mut defined = Vec::new();
    for symbol in file.symbols() {
        let name = bare(symbol.name().map_err(|error| error.to_string())?);
        if symbol.is_undefined() {
            assert!(name.starts_with("rt_aot_"), "unexpected import {name}");
            imported.push(name.to_owned());
        } else {
            defined.push(name.to_owned());
        }
    }
    for symbol in required {
        assert!(
            imported.iter().any(|name| name == symbol),
            "missing import {symbol}"
        );
    }
    for index in 0..2 {
        assert!(
            defined.contains(&function_symbol(index)),
            "missing function {index}"
        );
    }
    Ok(())
}

#[test]
fn every_relocation_targets_a_symbol_of_the_object() -> Result<(), String> {
    let compiled = compile(PROGRAM)?;
    let file = object::File::parse(compiled.bytes.as_slice()).map_err(|error| error.to_string())?;
    let mut relocations = 0_usize;
    for section in file.sections() {
        for (_, relocation) in section.relocations() {
            relocations = relocations.saturating_add(1);
            let RelocationTarget::Symbol(index) = relocation.target() else {
                return Err("relocation without symbol target".to_owned());
            };
            file.symbol_by_index(index)
                .map_err(|error| error.to_string())?;
        }
    }
    assert!(relocations > 0);
    Ok(())
}

#[test]
fn trapping_instructions_register_fault_sites_with_their_exact_span() -> Result<(), String> {
    let compiled = compile(PROGRAM)?;
    let overflow_sites: Vec<_> = compiled
        .fault_sites
        .iter()
        .filter(|site| site.code.as_str() == "integerOverflow")
        .map(|site| (site.range.start_line, site.range.start_column))
        .collect();
    assert!(overflow_sites.contains(&(2, 5)));
    assert!(overflow_sites.contains(&(3, 5)));
    assert!(overflow_sites.contains(&(5, 5)));
    Ok(())
}

#[test]
fn function_symbols_follow_module_order() -> Result<(), String> {
    let compiled = compile(PROGRAM)?;
    let names: Vec<_> = compiled
        .function_symbols
        .iter()
        .map(|entry| (entry.name.as_str(), entry.symbol.as_str()))
        .collect();
    assert_eq!(names, [("@double", "__pl_fn_0"), ("@main", "__pl_fn_1")]);
    Ok(())
}

#[test]
fn compilation_is_deterministic() -> Result<(), String> {
    assert_eq!(compile(PROGRAM)?.bytes, compile(PROGRAM)?.bytes);
    Ok(())
}

#[test]
fn an_empty_module_compiles_to_an_object_without_functions() -> Result<(), String> {
    let compiled = compile("module P es\n")?;
    assert!(compiled.function_symbols.is_empty());
    assert!(compiled.fault_sites.is_empty());
    Ok(())
}

#[test]
fn string_literals_are_stored_once_as_local_symbols() -> Result<(), String> {
    let text = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.str \"abc\"\n  %1 = const.str \"abc\"\n  %2 = const.str \"\"\n  %3 = text.length %0\n  return %3\n}\n";
    let compiled = compile(text)?;
    let file = object::File::parse(compiled.bytes.as_slice()).map_err(|error| error.to_string())?;
    let literal_symbols = file
        .symbols()
        .filter(|symbol| {
            symbol
                .name()
                .is_ok_and(|name| bare(name).starts_with("__pl_str_"))
        })
        .count();
    assert_eq!(literal_symbols, 2);
    for symbol in file.symbols() {
        if symbol.is_undefined() {
            let name = symbol.name().map_err(|error| error.to_string())?;
            assert!(
                bare(name).starts_with("rt_aot_"),
                "unexpected import {name}"
            );
        }
    }
    Ok(())
}

#[test]
fn class_descriptors_list_inherited_fields_before_declared_ones() -> Result<(), String> {
    let text = "module P es\nclass Base { first: i64 }\nclass Derived : Base { ratio: f64, name: str }\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let mut module = parse_module(text)?;
    if let Some(class) = module.classes.get_mut(1) {
        class.dense_integers = true;
    }
    let compiled = compile_module_to_object(&module, &TargetConfig::host().with_verification())
        .map_err(|error| error.to_string())?;
    let fields: Vec<_> = compiled
        .classes
        .iter()
        .map(|class| (class.fields.clone(), class.dense))
        .collect();
    assert_eq!(
        fields,
        [
            (vec![KIND_INTEGER], false),
            (vec![KIND_INTEGER, KIND_REAL, KIND_REFERENCE], true)
        ]
    );
    Ok(())
}

#[test]
fn a_method_naming_a_missing_function_is_rejected() -> Result<(), String> {
    let text = "module P es\nclass C { }\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let mut module = parse_module(text)?;
    if let Some(class) = module.classes.first_mut() {
        class.methods.push(("go".to_owned(), "@missing".to_owned()));
    }
    let error = compile_module_to_object(&module, &TargetConfig::host().with_verification());
    assert!(matches!(error, Err(CodegenError::InvalidModule(_))));
    Ok(())
}

#[test]
fn a_cyclic_class_hierarchy_is_rejected() -> Result<(), String> {
    let text = "module P es\nclass A : B { }\nclass B : A { }\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let module = parse_module(text)?;
    let error = compile_module_to_object(&module, &TargetConfig::host().with_verification());
    assert!(error.is_err());
    Ok(())
}

#[test]
fn ill_formed_modules_are_rejected_before_any_code_is_emitted() -> Result<(), String> {
    let text = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n}\n";
    let module = parse_module(text)?;
    let error = compile_module_to_object(&module, &TargetConfig::host().with_verification());
    assert!(matches!(error, Err(CodegenError::InvalidModule(_))));
    Ok(())
}
