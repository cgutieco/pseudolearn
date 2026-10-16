use crate::views::{FrameView, StateSnapshot, VariableValue, VariableView};

#[derive(Clone, Debug, PartialEq)]
pub struct VariableChange {
    pub frame_position: usize,
    pub variable_name: String,
    pub previous_value: VariableValue,
    pub current_value: VariableValue,
}

#[derive(Clone, Debug, PartialEq)]
pub enum FrameChange {
    Push(FrameView),
    Pop(FrameView),
}

#[derive(Clone, Debug, PartialEq)]
pub struct FieldChange {
    pub identity_ordinal: u64,
    pub field_name: String,
    pub previous_value: VariableValue,
    pub current_value: VariableValue,
}

#[derive(Clone, Debug, PartialEq)]
pub struct StateDelta {
    pub event_index: usize,
    pub output_delta: String,
    pub variables_modified: Vec<VariableChange>,
    pub frames_transition: Vec<FrameChange>,
    pub objects_allocated: Vec<u64>,
    pub fields_modified: Vec<FieldChange>,
}

pub fn compute_delta(previous: &StateSnapshot, current: &StateSnapshot) -> StateDelta {
    let output_delta = compute_output_delta(&previous.output_text, &current.output_text);
    let frames_transition = compute_frame_transitions(&previous.frames, &current.frames);
    let variables_modified = compute_variable_changes(&previous.frames, &current.frames);
    let objects_allocated = compute_allocated_objects(previous, current);
    let fields_modified = compute_field_changes(previous, current);

    StateDelta {
        event_index: current.event_index,
        output_delta,
        variables_modified,
        frames_transition,
        objects_allocated,
        fields_modified,
    }
}

fn compute_output_delta(previous: &str, current: &str) -> String {
    if current.len() >= previous.len() {
        current.get(previous.len()..).unwrap_or("").to_string()
    } else {
        String::new()
    }
}

fn compute_frame_transitions(previous: &[FrameView], current: &[FrameView]) -> Vec<FrameChange> {
    let mut transitions = Vec::new();
    if current.len() > previous.len() {
        for frame in current.get(previous.len()..).unwrap_or(&[]) {
            transitions.push(FrameChange::Push(frame.clone()));
        }
    } else if previous.len() > current.len() {
        for frame in previous.get(current.len()..).unwrap_or(&[]) {
            transitions.push(FrameChange::Pop(frame.clone()));
        }
    }
    transitions
}

fn compute_variable_changes(
    previous_frames: &[FrameView],
    current_frames: &[FrameView],
) -> Vec<VariableChange> {
    let mut changes = Vec::new();
    let common_depth = previous_frames.len().min(current_frames.len());
    for position in 0..common_depth {
        let previous_frame = match previous_frames.get(position) {
            Some(frame) => frame,
            None => continue,
        };
        let current_frame = match current_frames.get(position) {
            Some(frame) => frame,
            None => continue,
        };
        compare_frame_variables(position, previous_frame, current_frame, &mut changes);
    }
    changes
}

fn compare_frame_variables(
    frame_position: usize,
    previous_frame: &FrameView,
    current_frame: &FrameView,
    changes: &mut Vec<VariableChange>,
) {
    for current_variable in &current_frame.variables {
        let previous_variable = previous_frame
            .variables
            .iter()
            .find(|variable| variable.name == current_variable.name);
        let previous_value = match previous_variable {
            Some(variable) => variable.value.clone(),
            None => VariableValue::Undefined,
        };
        if previous_value != current_variable.value {
            changes.push(VariableChange {
                frame_position,
                variable_name: current_variable.name.clone(),
                previous_value,
                current_value: current_variable.value.clone(),
            });
        }
    }
}

fn compute_allocated_objects(previous: &StateSnapshot, current: &StateSnapshot) -> Vec<u64> {
    let mut allocated = Vec::new();
    for object in &current.objects {
        let exists_previously = previous
            .objects
            .iter()
            .any(|previous_object| previous_object.identity_ordinal == object.identity_ordinal);
        if !exists_previously {
            allocated.push(object.identity_ordinal);
        }
    }
    allocated
}

fn compute_field_changes(previous: &StateSnapshot, current: &StateSnapshot) -> Vec<FieldChange> {
    let mut changes = Vec::new();
    for current_object in &current.objects {
        let previous_object = previous
            .objects
            .iter()
            .find(|candidate| candidate.identity_ordinal == current_object.identity_ordinal);
        let previous_object = match previous_object {
            Some(object) => object,
            None => continue,
        };
        for current_field in &current_object.fields {
            let previous_field = previous_object
                .fields
                .iter()
                .find(|candidate| candidate.name == current_field.name);
            let previous_value = match previous_field {
                Some(field) => field.value.clone(),
                None => VariableValue::Undefined,
            };
            if previous_value != current_field.value {
                changes.push(FieldChange {
                    identity_ordinal: current_object.identity_ordinal,
                    field_name: current_field.name.clone(),
                    previous_value,
                    current_value: current_field.value.clone(),
                });
            }
        }
    }
    changes
}

pub fn apply_delta_forward(snapshot: &StateSnapshot, delta: &StateDelta) -> StateSnapshot {
    let mut output_text = snapshot.output_text.clone();
    output_text.push_str(&delta.output_delta);
    let mut frames = snapshot.frames.clone();
    for transition in &delta.frames_transition {
        match transition {
            FrameChange::Push(frame) => frames.push(frame.clone()),
            FrameChange::Pop(_) => {
                frames.pop();
            }
        }
    }
    for variable_change in &delta.variables_modified {
        apply_variable_update(&mut frames, variable_change);
    }
    let objects = update_objects_with_fields(&snapshot.objects, &delta.fields_modified);
    StateSnapshot {
        event_index: delta.event_index,
        statement_index: snapshot.statement_index,
        output_text,
        frames,
        objects,
    }
}

fn apply_variable_update(frames: &mut [FrameView], change: &VariableChange) {
    if let Some(frame) = frames.get_mut(change.frame_position) {
        if let Some(variable) = frame
            .variables
            .iter_mut()
            .find(|candidate| candidate.name == change.variable_name)
        {
            variable.value = change.current_value.clone();
        } else {
            frame.variables.push(VariableView {
                name: change.variable_name.clone(),
                variable_type: "Dinamico".to_string(),
                value: change.current_value.clone(),
                alias: None,
            });
        }
    }
}

fn update_objects_with_fields(
    objects: &[crate::views::ObjectView],
    changes: &[FieldChange],
) -> Vec<crate::views::ObjectView> {
    let mut updated = objects.to_vec();
    for change in changes {
        let target_field = updated
            .iter_mut()
            .find(|candidate| candidate.identity_ordinal == change.identity_ordinal)
            .and_then(|object| {
                object
                    .fields
                    .iter_mut()
                    .find(|candidate| candidate.name == change.field_name)
            });
        if let Some(field) = target_field {
            field.value = change.current_value.clone();
        }
    }
    updated
}
