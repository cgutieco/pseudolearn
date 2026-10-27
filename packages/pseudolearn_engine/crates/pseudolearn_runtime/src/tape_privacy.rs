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

    pub fn to_reference_string(&self) -> String {
        format!("secret:{}:{}", self.key_id, self.value_hmac)
    }
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
}
