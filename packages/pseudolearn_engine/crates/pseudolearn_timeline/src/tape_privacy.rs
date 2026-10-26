#![forbid(unsafe_code)]

pub const DEFAULT_MAX_TAPE_BYTES: usize = 16 * 1024 * 1024;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SecretHandle {
    pub key_id: String,
    pub value_hmac: String,
}

impl SecretHandle {
    pub fn new(key_id: String, value_hmac: String) -> Self {
        Self { key_id, value_hmac }
    }

    pub fn to_reference_string(&self) -> String {
        format!("secret:{}:{}", self.key_id, self.value_hmac)
    }

    pub fn parse_reference(input: &str) -> Option<Self> {
        let mut parts = input.split(':');
        if parts.next()? != "secret" {
            return None;
        }
        let key_id = parts.next()?.to_owned();
        let value_hmac = parts.next()?.to_owned();
        Some(Self { key_id, value_hmac })
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct TapeBudget {
    pub max_bytes: usize,
    pub current_bytes: usize,
}

impl TapeBudget {
    pub fn new(max_bytes: usize) -> Self {
        Self {
            max_bytes,
            current_bytes: 0,
        }
    }

    pub fn can_admit(&self, incoming: usize) -> bool {
        self.current_bytes.saturating_add(incoming) <= self.max_bytes
    }

    pub fn record_admitted(&mut self, bytes: usize) {
        self.current_bytes = self.current_bytes.saturating_add(bytes);
    }
}
