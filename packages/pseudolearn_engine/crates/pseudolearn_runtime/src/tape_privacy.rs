#![forbid(unsafe_code)]

pub const DEFAULT_MAX_TAPE_BYTES: usize = 16 * 1024 * 1024;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SecretHandle {
    pub key_id: String,
    pub value_hmac: String,
}

impl SecretHandle {
    pub fn authenticate(
        key_id: String,
        key: &[u8],
        value: &[u8],
    ) -> Result<Self, crate::ReplayError> {
        use hmac::Mac;
        let mut authenticator = hmac::Hmac::<sha2::Sha256>::new_from_slice(key)
            .map_err(|_| crate::ReplayError::CorruptedTape)?;
        authenticator.update(value);
        let value_hmac = authenticator
            .finalize()
            .into_bytes()
            .iter()
            .map(|octet| format!("{octet:02x}"))
            .collect();
        Ok(Self { key_id, value_hmac })
    }

    pub fn verifies(&self, key: &[u8], value: &[u8]) -> bool {
        use hmac::Mac;
        let Ok(mut authenticator) = hmac::Hmac::<sha2::Sha256>::new_from_slice(key) else {
            return false;
        };
        let Some(expected) = decode_hex(&self.value_hmac) else {
            return false;
        };
        authenticator.update(value);
        authenticator.verify_slice(&expected).is_ok()
    }

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
        if key_id.is_empty() || value_hmac.is_empty() || parts.next().is_some() {
            return None;
        }
        Some(Self { key_id, value_hmac })
    }
}

fn decode_hex(value: &str) -> Option<Vec<u8>> {
    if !value.len().is_multiple_of(2) {
        return None;
    }
    value
        .as_bytes()
        .as_chunks::<2>()
        .0
        .iter()
        .map(|pair| {
            let text = std::str::from_utf8(pair).ok()?;
            u8::from_str_radix(text, 16).ok()
        })
        .collect()
}

#[derive(Clone, Copy, Debug, Eq, PartialEq, serde::Serialize, serde::Deserialize)]
#[serde(deny_unknown_fields)]
pub struct TapeBudget {
    #[serde(rename = "max_tape_bytes")]
    pub max_bytes: usize,
    #[serde(skip)]
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
