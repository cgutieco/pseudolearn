use crate::{HostEffectRequest, HostValue, IoError};
use pseudolearn_abi::IoErrorKind;

const MAXIMUM_EXIT_CODE: i64 = 255;

pub fn exit_code_argument(request: &HostEffectRequest) -> Result<u8, IoError> {
    let Some(HostValue::Integer(code)) = request.arguments.first() else {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    };
    if !(0..=MAXIMUM_EXIT_CODE).contains(code) {
        return Err(IoError::from_kind(IoErrorKind::InvalidRequest));
    }
    u8::try_from(*code).map_err(|_| IoError::from_kind(IoErrorKind::InvalidRequest))
}
