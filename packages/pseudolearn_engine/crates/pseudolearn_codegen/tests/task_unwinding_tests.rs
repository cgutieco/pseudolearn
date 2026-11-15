#![forbid(unsafe_code)]

use object::{Object, ObjectSection, ObjectSymbol, RelocationTarget};
use pseudolearn_codegen::{
    CompiledObject, TargetConfig, compile_module_to_object, function_symbol,
};
use pseudolearn_ir::parse_module;
use std::collections::BTreeSet;
use std::str::FromStr;

const MODULE: &str = "module P es
func suspendible @Work() -> unit {
b0() mass 1:
  %0 = const.i64 1 @2:1-2:2
  stmt.enter @2:1-2:11
  out.write %0, newline @2:1-2:11
  stmt.exit @2:1-2:11
  return @3:1-3:14
}
func suspendible @main() -> unit {
b0() mass 1:
  %0 = task.scope_open @4:1-6:10
  stmt.enter @5:1-5:15
  %1 = task.spawn %0, @task:Work() @5:1-5:15
  stmt.exit @5:1-5:15
  task.cancel_point b2()
  task.scope_boundary %0, b3()
  task.scope_join %0 @4:1-6:10
  jump b1() @4:1-6:10
b1() mass 0:
  return @7:1-7:13
b2() mass 0:
  task.scope_join %0 @4:1-6:10
  return @4:1-6:10
b3() mass 0:
  task.scope_join %0 @4:1-6:10
  jump b1()
}
func suspendible @task:Work() -> unit {
b0() mass 0:
  %0 = call @Work() @1:1-1:30
  task.outcome success @1:1-1:30
  return @1:1-1:30
}
func @Plain(%0: i64) -> i64 {
b0() mass 0:
  %1 = int.add %0, %0 @8:1-8:5
  return %1 @8:1-8:5
}
";

const WORK: usize = 0;
const MAIN: usize = 1;
const TASK_WORK: usize = 2;
const PLAIN: usize = 3;
const LANDING_ENTRIES: [&str; 3] = [
    "rt_aot_task_cancel_point",
    "rt_aot_task_scope_boundary",
    "rt_aot_task_land",
];

fn compiled() -> Result<CompiledObject, String> {
    let module = parse_module(MODULE).map_err(|error| format!("{error:?}"))?;
    let triple = target_lexicon::Triple::from_str("x86_64-unknown-linux-musl")
        .map_err(|error| error.to_string())?;
    compile_module_to_object(&module, &TargetConfig::for_triple(triple).with_inspection())
        .map_err(|error| error.to_string())
}

fn called_entries(bytes: &[u8], function: usize) -> Result<BTreeSet<String>, String> {
    let file = object::File::parse(bytes).map_err(|error| error.to_string())?;
    let symbol = file
        .symbols()
        .find(|symbol| symbol.name() == Ok(function_symbol(function).as_str()))
        .ok_or("missing function symbol")?;
    let range = symbol.address()..symbol.address().saturating_add(symbol.size());
    let mut called = BTreeSet::new();
    for section in file.sections() {
        for (offset, relocation) in section.relocations() {
            let RelocationTarget::Symbol(index) = relocation.target() else {
                continue;
            };
            let target = file
                .symbol_by_index(index)
                .map_err(|error| error.to_string())?;
            if range.contains(&offset)
                && let Ok(name) = target.name()
            {
                called.insert(name.to_owned());
            }
        }
    }
    Ok(called)
}

fn calls_any_landing_entry(called: &BTreeSet<String>) -> bool {
    LANDING_ENTRIES.iter().any(|entry| called.contains(*entry))
}

#[test]
fn a_function_with_cancellation_landings_registers_and_dispatches_them() -> Result<(), String> {
    let object = compiled()?;
    let called = called_entries(&object.bytes, MAIN)?;
    for entry in LANDING_ENTRIES {
        assert!(called.contains(entry), "{entry} in {called:?}");
    }
    let clif = object
        .inspection
        .get(MAIN)
        .ok_or("missing main inspection")?;
    assert!(clif.contains("br_table"), "{clif}");
    Ok(())
}

#[test]
fn functions_without_landings_neither_register_nor_dispatch() -> Result<(), String> {
    let object = compiled()?;
    for function in [WORK, TASK_WORK, PLAIN] {
        assert!(!calls_any_landing_entry(&called_entries(
            &object.bytes,
            function
        )?));
        let clif = object
            .inspection
            .get(function)
            .ok_or("missing inspection")?;
        assert!(!clif.contains("br_table"), "{clif}");
    }
    Ok(())
}

#[test]
fn every_function_is_inspected_in_module_order() -> Result<(), String> {
    let object = compiled()?;
    assert_eq!(object.inspection.len(), 4);
    assert!(
        object
            .inspection
            .iter()
            .all(|text| text.contains("function u0:"))
    );
    Ok(())
}
