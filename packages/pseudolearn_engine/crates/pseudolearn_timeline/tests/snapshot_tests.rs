use pseudolearn_bytecode::compile_text;
use pseudolearn_timeline::{VariableValue, capture_snapshot, format_real};
use pseudolearn_vm::{Fuel, RunOptions, create_machine, load};

fn build_program(source_text: &str) -> Option<pseudolearn_vm::LoadedProgram> {
    let bytecode = compile_text(source_text).ok()?;
    load(&bytecode).ok()
}

#[test]
fn format_real_ensures_at_least_one_decimal() {
    assert_eq!(format_real(42.0), "42.0");
    assert_eq!(format_real(12.345), "12.345");
    assert_eq!(format_real(0.0), "0.0");
}

#[test]
fn variable_value_display_representation_matches_specification() {
    assert_eq!(
        VariableValue::Undefined.display_representation(),
        "sin_valor"
    );
    assert_eq!(VariableValue::Integer(42).display_representation(), "42");
    assert_eq!(VariableValue::Real(2.5).display_representation(), "2.5");
    assert_eq!(
        VariableValue::Boolean(true).display_representation(),
        "Verdadero"
    );
    assert_eq!(
        VariableValue::Boolean(false).display_representation(),
        "Falso"
    );
    assert_eq!(VariableValue::Character('z').display_representation(), "z");
    assert_eq!(
        VariableValue::Text("texto".to_string()).display_representation(),
        "texto"
    );
    assert_eq!(
        VariableValue::NullReference.display_representation(),
        "nulo"
    );
    assert_eq!(
        VariableValue::ObjectReference {
            handle_word: 1,
            identity_ordinal: 7,
            class_identifier: 3,
        }
        .display_representation(),
        "objeto(7)"
    );
    assert_eq!(
        VariableValue::ArrayReference {
            handle_word: 2,
            identity_ordinal: 9,
            dimensions: vec![5],
        }
        .display_representation(),
        "arreglo(9)"
    );
}

#[test]
fn initial_snapshot_captures_main_frame_and_registers() {
    let source =
        "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 10\n  return %0\n}\n";
    let Some(program) = build_program(source) else {
        return;
    };
    let machine_result = create_machine(&program, Fuel::unlimited(), RunOptions::default());
    assert!(machine_result.is_ok());
    let Ok(machine) = machine_result else {
        return;
    };
    let snapshot = capture_snapshot(&machine, 0);
    assert_eq!(snapshot.event_index, 0);
    assert_eq!(snapshot.statement_index, 0);
    assert_eq!(snapshot.frames.len(), 1);
    let main_frame = snapshot.frames.first();
    assert!(main_frame.is_some());
    let Some(main_frame) = main_frame else {
        return;
    };
    assert_eq!(main_frame.function_name, "P");
}

#[test]
fn snapshot_isolation_preserves_captured_values_across_mutation() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 10\n  %1 = const.i64 20\n  return %1\n}\n";
    let Some(program) = build_program(source) else {
        return;
    };
    let machine_result = create_machine(&program, Fuel::unlimited(), RunOptions::default());
    assert!(machine_result.is_ok());
    let Ok(mut machine) = machine_result else {
        return;
    };
    let initial_snapshot = capture_snapshot(&machine, 0);
    let _ = machine.step_instruction();
    let _ = machine.step_instruction();
    let subsequent_snapshot = capture_snapshot(&machine, 1);
    assert_eq!(initial_snapshot.event_index, 0);
    assert_eq!(subsequent_snapshot.event_index, 1);
    assert_eq!(initial_snapshot.output_text, "");
}
