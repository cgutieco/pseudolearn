use super::inspect_cell;
use crate::VariableValue;
use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{Cell, Fuel, RunOptions, create_machine, load, machine_cell};

fn compile_program(source: &str) -> Result<pseudolearn_vm::LoadedProgram, String> {
    let bytecode = compile_text(source).map_err(|error| format!("{error:?}"))?;
    load(&bytecode).map_err(|error| format!("{error:?}"))
}

#[test]
fn local_scalar_cells_show_defined_and_undefined_values() -> Result<(), String> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = cell.local i64\n  %1 = const.i64 41\n  cell.store %0, %1\n  return\n}\n";
    let program = compile_program(source)?;
    let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    for _ in 0..3 {
        if machine.step_instruction().is_some() {
            return Err("Program ended before the cell could be inspected".to_owned());
        }
    }
    assert!(matches!(
        machine_cell(&machine, 0),
        Some(Cell::Local { .. })
    ));
    let view = inspect_cell(&machine, 1, "total").ok_or("Local cell was not visible")?;
    assert_eq!(view.variable_type, "Entero");
    assert_eq!(view.value, VariableValue::Integer(41));
    assert!(view.alias.is_none());

    let undefined_source =
        "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = cell.local i64\n  return\n}\n";
    let undefined_program = compile_program(undefined_source)?;
    let mut undefined_machine =
        create_machine(&undefined_program, Fuel::unlimited(), RunOptions::default())
            .map_err(|error| format!("{error:?}"))?;
    if undefined_machine.step_instruction().is_some() {
        return Err("Program ended before the undefined cell could be inspected".to_owned());
    }
    let undefined_view = inspect_cell(&undefined_machine, 1, "total")
        .ok_or("Undefined local cell was not visible")?;
    assert_eq!(undefined_view.value, VariableValue::Undefined);
    Ok(())
}

#[test]
fn local_reference_cells_decode_text_values() -> Result<(), String> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = cell.local str\n  %1 = const.str \"sample\"\n  cell.store %0, %1\n  return\n}\n";
    let program = compile_program(source)?;
    let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    for _ in 0..3 {
        if machine.step_instruction().is_some() {
            return Err("Program ended before the reference cell could be inspected".to_owned());
        }
    }
    let view = inspect_cell(&machine, 1, "label").ok_or("Reference cell was not visible")?;
    assert_eq!(view.variable_type, "Referencia");
    assert_eq!(view.value, VariableValue::Text("sample".to_owned()));
    Ok(())
}

#[test]
fn managed_array_cells_decode_the_referenced_element() -> Result<(), String> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 2\n  %1 = array.new i64, %0 @1:1-1:2\n  %2 = const.i64 1\n  %3 = cell.element %1, %2 @1:1-1:2\n  %4 = const.i64 29\n  cell.store %3, %4\n  return\n}\n";
    let program = compile_program(source)?;
    let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    for _ in 0..6 {
        if machine.step_instruction().is_some() {
            return Err("Program ended before the array cell could be inspected".to_owned());
        }
    }
    assert!(matches!(machine_cell(&machine, 0), Some(Cell::Managed(_))));
    let view = inspect_cell(&machine, 1, "element").ok_or("Array cell was not visible")?;
    assert_eq!(view.variable_type, "Entero");
    assert_eq!(view.value, VariableValue::Integer(29));
    Ok(())
}

#[test]
fn managed_object_cells_decode_the_referenced_field() -> Result<(), String> {
    let source = "module P es\nclass C { value: i64 }\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new C @1:1-1:2\n  %1 = cell.field %0, value @1:1-1:2\n  %2 = const.i64 37\n  cell.store %1, %2\n  return\n}\n";
    let program = compile_program(source)?;
    let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    for _ in 0..4 {
        if machine.step_instruction().is_some() {
            return Err("Program ended before the object cell could be inspected".to_owned());
        }
    }
    assert!(matches!(machine_cell(&machine, 0), Some(Cell::Managed(_))));
    let view = inspect_cell(&machine, 1, "field").ok_or("Object cell was not visible")?;
    assert_eq!(view.variable_type, "Entero");
    assert_eq!(view.value, VariableValue::Integer(37));
    Ok(())
}

#[test]
fn invalid_cell_handles_are_rejected() -> Result<(), String> {
    let program =
        compile_program("module P es\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n")?;
    let machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    assert!(inspect_cell(&machine, 0, "value").is_none());
    assert!(inspect_cell(&machine, u32::MAX, "value").is_none());
    Ok(())
}
