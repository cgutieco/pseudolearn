use pseudolearn_vm::{
    EventPayload, StepAction, TraceClass, TraceEvent, advance_step, step_into, step_out, step_over,
    step_to_line,
};

fn sample_execution_trace() -> Vec<TraceEvent> {
    vec![
        TraceEvent {
            class: TraceClass::StatementEntered,
            line: 1,
            depth: 1,
            payload: None,
        },
        TraceEvent {
            class: TraceClass::StatementEntered,
            line: 2,
            depth: 1,
            payload: None,
        },
        TraceEvent {
            class: TraceClass::Call,
            line: 2,
            depth: 1,
            payload: Some(EventPayload::Call {
                nombre: "sub".to_owned(),
            }),
        },
        TraceEvent {
            class: TraceClass::StatementEntered,
            line: 10,
            depth: 2,
            payload: None,
        },
        TraceEvent {
            class: TraceClass::Output,
            line: 10,
            depth: 2,
            payload: Some(EventPayload::Output {
                texto: "hola\n".to_owned(),
            }),
        },
        TraceEvent {
            class: TraceClass::StatementEntered,
            line: 11,
            depth: 2,
            payload: None,
        },
        TraceEvent {
            class: TraceClass::Return,
            line: 12,
            depth: 2,
            payload: Some(EventPayload::Return {
                nombre: "sub".to_owned(),
            }),
        },
        TraceEvent {
            class: TraceClass::StatementEntered,
            line: 3,
            depth: 1,
            payload: None,
        },
    ]
}

#[test]
fn step_into_advances_to_next_statement_entered() {
    let trace = sample_execution_trace();
    let step_first = step_into(&trace, 0);
    assert_eq!(step_first, 1);
    let step_second = step_into(&trace, 1);
    assert_eq!(step_second, 3);
}

#[test]
fn step_over_skips_nested_call_depth() {
    let trace = sample_execution_trace();
    let step_result = step_over(&trace, 1);
    assert_eq!(step_result, 7);
}

#[test]
fn step_out_advances_to_current_frame_return() {
    let trace = sample_execution_trace();
    let step_result = step_out(&trace, 3);
    assert_eq!(step_result, 6);
}

#[test]
fn step_to_line_finds_matching_statement() {
    let trace = sample_execution_trace();
    let step_result = step_to_line(&trace, 0, 11);
    assert_eq!(step_result, 5);
}

#[test]
fn advance_step_dispatches_actions() {
    let trace = sample_execution_trace();
    assert_eq!(advance_step(&trace, 0, StepAction::Into), 1);
    assert_eq!(advance_step(&trace, 1, StepAction::Over), 7);
    assert_eq!(advance_step(&trace, 3, StepAction::Out), 6);
    assert_eq!(advance_step(&trace, 0, StepAction::ToLine(3)), 7);
}

#[test]
fn step_past_end_returns_trace_length() {
    let trace = sample_execution_trace();
    let end_index = trace.len();
    assert_eq!(step_into(&trace, end_index), end_index);
    assert_eq!(step_over(&trace, end_index), end_index);
    assert_eq!(step_out(&trace, end_index), end_index);
    assert_eq!(step_to_line(&trace, end_index, 99), end_index);
}
