use crate::IoError;
use pseudolearn_abi::IoErrorKind;

const FORBIDDEN: &[&str] = &[
    "host",
    "content-length",
    "transfer-encoding",
    "connection",
    "upgrade",
    "te",
    "trailer",
    "keep-alive",
    "cookie",
    "set-cookie",
    "accept-encoding",
];

pub(crate) fn validate(headers: &[(String, String)]) -> Result<(), IoError> {
    if headers
        .iter()
        .any(|(name, value)| !valid_name(name) || !valid_value(value) || forbidden(name))
    {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    }
    Ok(())
}

pub(crate) fn validate_response(headers: &[(String, String)]) -> Result<(), IoError> {
    if headers
        .iter()
        .any(|(name, value)| !valid_name(name) || !valid_value(value))
    {
        return Err(IoError::from_kind(IoErrorKind::InvalidResponse));
    }
    Ok(())
}

fn valid_name(name: &str) -> bool {
    !name.is_empty() && name.bytes().all(token_byte)
}

fn token_byte(byte: u8) -> bool {
    byte.is_ascii_alphanumeric()
        || matches!(
            byte,
            b'!' | b'#'
                | b'$'
                | b'%'
                | b'&'
                | b'\''
                | b'*'
                | b'+'
                | b'-'
                | b'.'
                | b'^'
                | b'_'
                | b'`'
                | b'|'
                | b'~'
        )
}

fn valid_value(value: &str) -> bool {
    !value.bytes().any(|byte| matches!(byte, b'\r' | b'\n' | 0))
}

fn forbidden(name: &str) -> bool {
    let lower = name.to_ascii_lowercase();
    FORBIDDEN.contains(&lower.as_str()) || lower.starts_with("proxy-")
}
