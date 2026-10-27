use crate::{IoError, SecretHandle};
use pseudolearn_abi::IoErrorKind;
use serde_json::Value;

#[derive(Clone, Debug, Default, Eq, PartialEq)]
pub(crate) struct SecretPolicy {
    rules: Vec<SecretRule>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
struct SecretRule {
    key_id: String,
    key: Vec<u8>,
    value: Vec<u8>,
}

impl SecretPolicy {
    pub(crate) fn from_host(host: Option<&Value>) -> Result<Self, IoError> {
        let mut rules = Vec::new();
        let secrets = host
            .and_then(|host| host.get("secrets"))
            .and_then(Value::as_object);
        for secret in secrets.into_iter().flat_map(|secrets| secrets.values()) {
            let key_id = secret
                .get("key_id")
                .and_then(Value::as_str)
                .ok_or_else(invalid)?;
            let value = secret
                .get("value")
                .and_then(Value::as_str)
                .filter(|value| !value.is_empty())
                .ok_or_else(invalid)?;
            let key = host
                .and_then(|host| host.get("secret_keys"))
                .and_then(|keys| keys.get(key_id))
                .and_then(Value::as_str)
                .filter(|key| !key.is_empty())
                .ok_or_else(invalid)?;
            rules.push(SecretRule {
                key_id: key_id.to_owned(),
                key: key.as_bytes().to_vec(),
                value: value.as_bytes().to_vec(),
            });
        }
        Ok(Self { rules })
    }

    pub(crate) fn reference(&self, arguments: &[u8], payload: &[u8]) -> Option<SecretHandle> {
        let rule = self
            .rules
            .iter()
            .find(|rule| contains(arguments, &rule.value) || contains(payload, &rule.value))?;
        let mut bytes = arguments.to_vec();
        bytes.extend_from_slice(payload);
        SecretHandle::authenticate(rule.key_id.clone(), &rule.key, &bytes).ok()
    }
}

fn contains(bytes: &[u8], secret: &[u8]) -> bool {
    bytes.windows(secret.len()).any(|window| window == secret)
        || serde_json::from_slice::<Value>(bytes)
            .ok()
            .is_some_and(|value| contains_value(&value, secret))
}

fn contains_value(value: &Value, secret: &[u8]) -> bool {
    match value {
        Value::String(text) => text
            .as_bytes()
            .windows(secret.len())
            .any(|window| window == secret),
        Value::Array(values) => {
            let bytes: Option<Vec<_>> = values
                .iter()
                .map(|value| value.as_u64().and_then(|number| u8::try_from(number).ok()))
                .collect();
            bytes.is_some_and(|bytes| bytes.windows(secret.len()).any(|window| window == secret))
                || values.iter().any(|value| contains_value(value, secret))
        }
        Value::Object(fields) => fields.values().any(|value| contains_value(value, secret)),
        _ => false,
    }
}

fn invalid() -> IoError {
    IoError::from_kind(IoErrorKind::InvalidPath)
}
