use crate::errors::ApiError;
use serde::Serialize;
use serde::de::DeserializeOwned;

pub fn serialize_to_string<Payload: Serialize>(payload: &Payload) -> Result<String, ApiError> {
    serde_json::to_string(payload)
        .map_err(|error| ApiError::SerializationFailure(error.to_string()))
}

pub fn deserialize_from_str<Payload: DeserializeOwned>(text: &str) -> Result<Payload, ApiError> {
    serde_json::from_str(text).map_err(|error| ApiError::SerializationFailure(error.to_string()))
}
