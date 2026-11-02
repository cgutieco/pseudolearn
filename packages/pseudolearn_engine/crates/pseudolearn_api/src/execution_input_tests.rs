use super::super::ExecutionResource;
use crate::ExecuteRequest;
use serde_json::Value;

fn waiting_execution(resource_id: u64) -> Result<ExecutionResource, String> {
    let request = ExecuteRequest {
        program: "Algoritmo Main\nDefinir Mutable count Como Entero <- 0;\nLeer count;\nEscribir count;\nFinAlgoritmo\n".to_owned(),
        ..ExecuteRequest::default()
    };
    let mut execution = ExecutionResource::start(&request)
        .map_err(|error| format!("could not start input test execution: {error:?}"))?;
    execution.set_resource_id(resource_id);
    execution
        .advance(64)
        .map_err(|error| format!("could not reach input wait: {error:?}"))?;
    if execution.pending_input.is_none() {
        return Err("execution did not expose an input request".to_owned());
    }
    Ok(execution)
}

fn request_id(response: &Value) -> Option<u64> {
    response.get("pending_input")?.get("request_id")?.as_u64()
}

#[test]
fn input_rejects_crossed_stale_and_duplicate_responses_without_consuming_them() -> Result<(), String>
{
    let mut execution = waiting_execution(7)?;
    assert_eq!(
        execution
            .pending_input
            .as_ref()
            .map(|request| request.resource_id),
        Some(7)
    );
    assert!(execution.input(7, 1, 1, "wrong task".to_owned()).is_err());
    assert!(
        execution
            .input(7, 0, 2, "wrong request".to_owned())
            .is_err()
    );
    assert!(
        execution
            .input(8, 0, 1, "wrong execution".to_owned())
            .is_err()
    );
    assert_eq!(execution.machine.input_consumed_count(), 0);

    assert!(
        execution
            .input(7, 0, 1, "not an integer".to_owned())
            .is_ok()
    );
    let next = execution
        .advance(64)
        .map_err(|error| format!("could not retry input request: {error:?}"))?;
    assert_eq!(request_id(&next), Some(2));
    assert!(execution.input(7, 0, 1, "7".to_owned()).is_err());
    assert_eq!(execution.machine.input_consumed_count(), 1);

    assert!(execution.input(7, 0, 2, "7".to_owned()).is_ok());
    let completed = execution.advance(64);
    assert!(completed.is_ok());
    assert!(execution.input(7, 0, 2, "7".to_owned()).is_err());
    assert_eq!(execution.machine.input_consumed_count(), 2);
    Ok(())
}

#[test]
fn cancellation_rejects_a_response_before_the_machine_receives_it() -> Result<(), String> {
    let mut execution = waiting_execution(7)?;
    execution.cancel();
    assert!(execution.input(7, 0, 1, "7".to_owned()).is_err());
    assert_eq!(execution.machine.input_consumed_count(), 0);
    Ok(())
}

#[test]
fn a_response_from_an_execution_with_the_same_program_is_rejected() -> Result<(), String> {
    let first = waiting_execution(7)?;
    let mut second = waiting_execution(8)?;
    assert_eq!(
        first
            .pending_input
            .as_ref()
            .map(|request| request.request_id),
        Some(1)
    );
    assert_eq!(
        second
            .pending_input
            .as_ref()
            .map(|request| request.request_id),
        Some(1)
    );
    assert_eq!(
        first
            .pending_input
            .as_ref()
            .map(|request| request.resource_id),
        Some(7)
    );
    assert_eq!(
        second
            .pending_input
            .as_ref()
            .map(|request| request.resource_id),
        Some(8)
    );
    assert!(second.input(7, 0, 1, "stale response".to_owned()).is_err());
    assert_eq!(second.machine.input_consumed_count(), 0);
    Ok(())
}
