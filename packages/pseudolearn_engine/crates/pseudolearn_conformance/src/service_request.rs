use pseudolearn_api::service::{DocumentSession, Position, Profile};
use serde_json::Value;

pub struct ServiceRequest<'raw> {
    raw: &'raw Value,
}

impl<'raw> ServiceRequest<'raw> {
    pub fn new(raw: &'raw Value) -> Self {
        Self { raw }
    }

    pub fn raw(&self) -> &'raw Value {
        self.raw
    }

    pub fn text(&self, name: &str) -> &'raw str {
        self.raw.get(name).and_then(Value::as_str).unwrap_or("")
    }

    pub fn profile(&self) -> Profile {
        match self.text("profile") {
            "en" => Profile::English,
            _ => Profile::Spanish,
        }
    }

    pub fn strict(&self) -> bool {
        self.text("strictness") != "flexible"
    }

    pub fn session(&self) -> DocumentSession {
        DocumentSession::new(
            self.text("documento").to_owned(),
            self.profile(),
            self.strict(),
        )
    }
}

pub fn position_of(request: &ServiceRequest<'_>) -> Position {
    let coordinate = |pointer: &str| {
        request
            .raw()
            .pointer(pointer)
            .and_then(Value::as_u64)
            .and_then(|value| u32::try_from(value).ok())
            .unwrap_or(1)
    };
    Position {
        line: coordinate("/posicion/line"),
        column: coordinate("/posicion/column"),
    }
}

pub fn seed_of(request: &ServiceRequest<'_>) -> u64 {
    request
        .raw()
        .get("semilla")
        .and_then(Value::as_u64)
        .unwrap_or(0)
}

pub fn strings_of(request: &ServiceRequest<'_>, name: &str) -> Vec<String> {
    request
        .raw()
        .get(name)
        .and_then(Value::as_array)
        .map(|items| {
            items
                .iter()
                .filter_map(Value::as_str)
                .map(str::to_owned)
                .collect()
        })
        .unwrap_or_default()
}
