use flutter_rust_bridge::frb;
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};
use std::cell::RefCell;
use std::collections::BTreeMap;

#[frb(sync)]
pub fn create_session() -> Result<u64, String> {
    SESSIONS.with(|sessions| {
        sessions
            .try_borrow_mut()
            .map_err(|_| "session registry is busy".to_owned())?
            .create()
    })
}

#[frb(sync)]
pub fn call_session(session_identifier: u64, request_json: String) -> String {
    let response = SESSIONS.with(|sessions| {
        sessions
            .try_borrow_mut()
            .map_err(|_| "session registry is busy".to_owned())?
            .call(session_identifier, &request_json)
    });
    response.unwrap_or_else(|detail| failure("usage", &detail))
}

#[frb(sync)]
pub fn close_session(session_identifier: u64) -> Result<(), String> {
    SESSIONS.with(|sessions| {
        sessions
            .try_borrow_mut()
            .map_err(|_| "session registry is busy".to_owned())?
            .close(session_identifier)
    })
}

struct SessionRegistry {
    next_identifier: u64,
    sessions: BTreeMap<u64, ApiSession>,
}

impl SessionRegistry {
    fn new() -> Self {
        Self {
            next_identifier: 0,
            sessions: BTreeMap::new(),
        }
    }

    fn create(&mut self) -> Result<u64, String> {
        let identifier = self
            .next_identifier
            .checked_add(1)
            .ok_or_else(|| "session identifiers exhausted".to_owned())?;
        self.next_identifier = identifier;
        self.sessions.insert(identifier, ApiSession::default());
        Ok(identifier)
    }

    fn call(&mut self, session_identifier: u64, request_json: &str) -> Result<String, String> {
        let request: Value = serde_json::from_str(request_json)
            .map_err(|_| "request is not valid JSON".to_owned())?;
        let operation = request
            .get("operation")
            .and_then(Value::as_str)
            .ok_or_else(|| "request has no operation".to_owned())?;
        let arguments = request
            .get("arguments")
            .ok_or_else(|| "request has no arguments".to_owned())?;
        let session = self
            .sessions
            .get_mut(&session_identifier)
            .ok_or_else(|| "invalid session".to_owned())?;
        let response = session.call(operation, arguments);
        serde_json::to_string(&response).map_err(|_| "response serialization failed".to_owned())
    }

    fn close(&mut self, session_identifier: u64) -> Result<(), String> {
        self.sessions
            .remove(&session_identifier)
            .map(|_| ())
            .ok_or_else(|| "invalid session".to_owned())
    }
}

thread_local! {
    static SESSIONS: RefCell<SessionRegistry> = RefCell::new(SessionRegistry::new());
}

fn failure(family: &str, detail: &str) -> String {
    match serde_json::to_string(&json!({"failure":{"family":family,"detail":detail}})) {
        Ok(response) => response,
        Err(_) => {
            "{\"failure\":{\"family\":\"internal\",\"detail\":\"serialization failed\"}}".to_owned()
        }
    }
}
