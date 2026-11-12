use super::dap_session::DapSession;
use serde_json::json;

#[test]
fn initialization_reports_only_supported_capabilities() {
    let mut session = DapSession::new(crate::options::parse_cli_options(&[]).ok());
    let messages = session.handle(&json!({"seq":1,"type":"request","command":"initialize"}));
    let response = messages.first().cloned().unwrap_or_default();
    assert_eq!(response["success"], true);
    assert_eq!(response["body"]["supportsConfigurationDoneRequest"], true);
    assert!(response["body"].get("supportsSetVariable").is_none());
}

#[test]
fn configuration_before_launch_fails_without_starting() {
    let mut session = DapSession::new(crate::options::parse_cli_options(&[]).ok());
    let messages = session.handle(&json!({"seq":1,"type":"request","command":"configurationDone"}));
    assert_eq!(
        messages.first().and_then(|message| message.get("success")),
        Some(&json!(false))
    );
    assert!(!session.can_advance());
}

#[test]
fn duplicate_initialization_does_not_replace_session() {
    let mut session = DapSession::new(crate::options::parse_cli_options(&[]).ok());
    let request = json!({"seq":1,"type":"request","command":"initialize"});
    assert_eq!(
        session
            .handle(&request)
            .first()
            .and_then(|message| message.get("success")),
        Some(&json!(true))
    );
    assert_eq!(
        session
            .handle(&request)
            .first()
            .and_then(|message| message.get("success")),
        Some(&json!(false))
    );
}

#[test]
fn malformed_request_is_rejected_as_a_value() {
    let mut session = DapSession::new(None);
    let messages = session.handle(&json!({"seq":-1,"type":"event","command":"initialize"}));
    assert_eq!(
        messages.first().and_then(|message| message.get("success")),
        Some(&json!(false))
    );
    assert!(!session.can_advance());
}
