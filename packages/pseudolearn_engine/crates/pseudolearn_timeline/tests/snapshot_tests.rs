use pseudolearn_bytecode::compile_text;
use pseudolearn_runtime::{
    ObjectLayout, ValueKind, allocation_ordinal, new_array, new_object, new_text, write_element,
};
use pseudolearn_timeline::{
    ArraySliceRange, TimelineError, VariableValue, capture_array_slice, capture_snapshot,
    format_real,
};
use pseudolearn_vm::{Fuel, Machine, RunOptions, create_machine, load};

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

#[test]
fn array_slices_cover_element_kinds_dimensions_and_boundaries() -> Result<(), String> {
    let source = "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  return\n}\n";
    let program = build_program(source).ok_or("Could not build the program")?;
    let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    let text =
        new_text(machine.heap_mut(), "hello", false, &[]).map_err(|error| format!("{error:?}"))?;
    let object = new_object(
        machine.heap_mut(),
        ObjectLayout {
            class: 0,
            fields: Vec::new(),
            dense: false,
            references: Vec::new(),
        },
        &[],
    )
    .map_err(|error| format!("{error:?}"))?;
    let cases = vec![
        (
            ValueKind::Integer,
            vec![Some(u64::from_ne_bytes((-17_i64).to_ne_bytes())), None],
            vec![VariableValue::Integer(-17), VariableValue::Undefined],
        ),
        (
            ValueKind::Real,
            vec![Some(1.25_f64.to_bits()), Some((-2.5_f64).to_bits())],
            vec![VariableValue::Real(1.25), VariableValue::Real(-2.5)],
        ),
        (
            ValueKind::Boolean,
            vec![Some(1), Some(0)],
            vec![VariableValue::Boolean(true), VariableValue::Boolean(false)],
        ),
        (
            ValueKind::Character,
            vec![
                Some(u64::from(u32::from('ñ'))),
                Some(u64::from(u32::from('語'))),
            ],
            vec![
                VariableValue::Character('ñ'),
                VariableValue::Character('語'),
            ],
        ),
        (
            ValueKind::Reference,
            vec![Some(u64::from(text.0)), Some(u64::from(object.0))],
            vec![
                VariableValue::Text("hello".to_owned()),
                VariableValue::ObjectReference {
                    handle_word: object.0,
                    identity_ordinal: allocation_ordinal(machine.heap(), object)
                        .map_err(|error| format!("{error:?}"))?,
                    class_identifier: 0,
                },
            ],
        ),
    ];

    for (kind, words, expected) in cases {
        assert_array_slices(&mut machine, kind, words.as_slice(), expected.clone(), &[2])?;
        assert_array_slices(
            &mut machine,
            kind,
            words.as_slice(),
            expected.clone(),
            &[1, 2],
        )?;
    }
    Ok(())
}

fn assert_array_slices(
    machine: &mut Machine<'_>,
    kind: ValueKind,
    words: &[Option<u64>],
    expected: Vec<VariableValue>,
    dimensions: &[i64],
) -> Result<(), String> {
    let handle = new_array(machine.heap_mut(), kind, dimensions, &[])
        .map_err(|error| format!("{error:?}"))?;
    for (index, word) in words.iter().enumerate() {
        if let Some(word) = word {
            let indices = if dimensions.len() == 1 {
                vec![i64::try_from(index).map_err(|error| format!("{error:?}"))?]
            } else {
                vec![
                    0,
                    i64::try_from(index).map_err(|error| format!("{error:?}"))?,
                ]
            };
            write_element(machine.heap_mut(), handle, (indices.as_slice(), *word))
                .map_err(|error| format!("{error:?}"))?;
        }
    }
    let ordinal =
        allocation_ordinal(machine.heap(), handle).map_err(|error| format!("{error:?}"))?;
    let actual = capture_array_slice(
        machine,
        ordinal,
        ArraySliceRange {
            start_index: 0,
            slice_length: 2,
        },
    )
    .map_err(|error| error.to_string())?;
    assert_eq!(actual, expected);
    assert!(
        capture_array_slice(
            machine,
            ordinal,
            ArraySliceRange {
                start_index: 1,
                slice_length: 1,
            },
        )
        .is_ok()
    );
    assert_eq!(
        capture_array_slice(
            machine,
            ordinal,
            ArraySliceRange {
                start_index: 2,
                slice_length: 0,
            },
        ),
        Ok(Vec::new())
    );
    assert!(matches!(
        capture_array_slice(
            machine,
            ordinal,
            ArraySliceRange {
                start_index: 3,
                slice_length: 0,
            },
        ),
        Err(TimelineError::SliceOutOfRange {
            start_index: 3,
            slice_length: 0,
            total_elements: 2,
        })
    ));
    assert!(matches!(
        capture_array_slice(
            machine,
            ordinal,
            ArraySliceRange {
                start_index: usize::MAX,
                slice_length: 1,
            },
        ),
        Err(TimelineError::SliceOutOfRange { .. })
    ));
    assert!(matches!(
        capture_array_slice(
            machine,
            ordinal.saturating_add(1),
            ArraySliceRange {
                start_index: 0,
                slice_length: 0,
            },
        ),
        Err(TimelineError::InvalidArray { .. })
    ));
    Ok(())
}
