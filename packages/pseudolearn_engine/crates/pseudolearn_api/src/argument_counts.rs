use crate::ApiError;
use crate::execution_resource::usage;
use serde_json::Value;

pub(crate) fn count(
    arguments: &Value,
    name: &str,
    default: Option<usize>,
) -> Result<usize, ApiError> {
    optional_count(arguments, name)?
        .or(default)
        .ok_or_else(|| usage("missing count"))
}

pub(crate) fn optional_count(arguments: &Value, name: &str) -> Result<Option<usize>, ApiError> {
    arguments
        .get(name)
        .map(|value| {
            value
                .as_u64()
                .and_then(|count| usize::try_from(count).ok())
                .ok_or_else(|| usage("invalid count"))
        })
        .transpose()
}
