use pseudolearn_api::{ExecuteRequest, native_effect_input};

fn request() -> ExecuteRequest {
    ExecuteRequest {
        program: "Algoritmo Main\nFinAlgoritmo\n".to_owned(),
        ..ExecuteRequest::default()
    }
}

#[test]
fn live_native_request_without_observation_is_accepted() {
    assert!(native_effect_input(&request()).is_ok());
}

#[test]
fn native_subject_rejects_observation() {
    let observed = ExecuteRequest {
        observe: "events".to_owned(),
        ..request()
    };
    assert!(native_effect_input(&observed).is_err());
}

#[test]
fn native_subject_rejects_seek_by_state_index() {
    let seeking = ExecuteRequest {
        state_at: Some(1),
        ..request()
    };
    assert!(native_effect_input(&seeking).is_err());
}

#[test]
fn native_subject_rejects_history_seek_mode() {
    let history = ExecuteRequest {
        execution_mode: Some("history_seek".to_owned()),
        ..request()
    };
    assert!(native_effect_input(&history).is_err());
}
