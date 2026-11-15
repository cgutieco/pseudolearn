use crate::dap_session::{DapSession, Reference};
use serde_json::json;

#[test]
fn root_task_gets_a_positive_distinct_dap_identity() -> Result<(), String> {
    let mut session = DapSession::new(None);
    assert_eq!(session.thread_id(0)?, 1);
    assert_eq!(session.thread_id(u64::MAX)?, 2);
    assert_eq!(session.thread_id(0)?, 1);
    assert_eq!(session.selected_task(&json!(2))?, u64::MAX);
    assert!(session.selected_task(&json!(0)).is_err());
    Ok(())
}

#[test]
fn frame_references_cannot_cross_stop_generations() -> Result<(), String> {
    let mut session = DapSession::new(None);
    session.state = json!({"stop_generation":4});
    let reference = session.reference(Reference::Frame {
        task: 7,
        position: 3,
        generation: 4,
    })?;
    assert_eq!(session.frame(&json!(reference))?, (7, 3));
    session.state = json!({"stop_generation":5});
    assert!(session.frame(&json!(reference)).is_err());
    assert!(session.frame(&json!(-1)).is_err());
    Ok(())
}

#[test]
fn input_tokens_are_checked_before_touching_the_execution() {
    let mut session = DapSession::new(None);
    session.input_token = Some("session:1:2".to_owned());
    let stale = json!({"seq":1,"type":"request","command":"pseudolearn/input",
        "arguments":{"token":"foreign:1:2","action":"line","text":""}});
    let reply = session.handle(&stale);
    assert_eq!(
        reply.first().and_then(|message| message.get("success")),
        Some(&json!(false))
    );
    assert_eq!(session.input_token.as_deref(), Some("session:1:2"));
}
