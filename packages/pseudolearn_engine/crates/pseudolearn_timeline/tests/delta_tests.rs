use pseudolearn_timeline::{StateSnapshot, VariableValue, apply_delta_forward, compute_delta};

fn create_empty_snapshot(event_index: usize, output_text: &str) -> StateSnapshot {
    StateSnapshot {
        event_index,
        statement_index: u64::try_from(event_index).unwrap_or(0),
        output_text: output_text.to_string(),
        frames: Vec::new(),
        objects: Vec::new(),
    }
}

#[test]
fn compute_delta_detects_output_append() {
    let previous = create_empty_snapshot(0, "hola");
    let current = create_empty_snapshot(1, "hola mundo\n");
    let delta = compute_delta(&previous, &current);
    assert_eq!(delta.event_index, 1);
    assert_eq!(delta.output_delta, " mundo\n");
}

#[test]
fn compute_delta_and_apply_forward_reproduces_output_and_frames() {
    let mut initial_snapshot = create_empty_snapshot(0, "inicio: ");
    initial_snapshot
        .frames
        .push(pseudolearn_timeline::FrameView {
            position: 0,
            function_name: "@main".to_string(),
            variables: vec![pseudolearn_timeline::VariableView {
                name: "contador".to_string(),
                variable_type: "Entero".to_string(),
                value: VariableValue::Integer(0),
                alias: None,
            }],
            receiver_handle: None,
        });

    let mut advanced_snapshot = create_empty_snapshot(1, "inicio: 1\n");
    advanced_snapshot
        .frames
        .push(pseudolearn_timeline::FrameView {
            position: 0,
            function_name: "@main".to_string(),
            variables: vec![pseudolearn_timeline::VariableView {
                name: "contador".to_string(),
                variable_type: "Entero".to_string(),
                value: VariableValue::Integer(1),
                alias: None,
            }],
            receiver_handle: None,
        });

    let delta = compute_delta(&initial_snapshot, &advanced_snapshot);
    assert_eq!(delta.variables_modified.len(), 1);
    let change = delta.variables_modified.first();
    assert!(change.is_some());
    let Some(change) = change else {
        return;
    };
    assert_eq!(change.variable_name, "contador");
    assert_eq!(change.previous_value, VariableValue::Integer(0));
    assert_eq!(change.current_value, VariableValue::Integer(1));

    let reconstructed = apply_delta_forward(&initial_snapshot, &delta);
    assert_eq!(reconstructed.event_index, 1);
    assert_eq!(reconstructed.output_text, "inicio: 1\n");
    assert_eq!(reconstructed.frames.len(), 1);
    let reconstructed_frame = reconstructed.frames.first();
    assert!(reconstructed_frame.is_some());
    let Some(reconstructed_frame) = reconstructed_frame else {
        return;
    };
    let reconstructed_variable = reconstructed_frame.variables.first();
    assert!(reconstructed_variable.is_some());
    let Some(reconstructed_variable) = reconstructed_variable else {
        return;
    };
    assert_eq!(reconstructed_variable.value, VariableValue::Integer(1));
}
