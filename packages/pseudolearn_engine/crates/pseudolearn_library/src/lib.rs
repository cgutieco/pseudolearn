#![forbid(unsafe_code)]

mod collections;
mod conversion;
mod quoted_text;
pub use collections::{CollectionRequest, collection_operation};
pub use quoted_text::quote_text;
mod bytes_operations;
mod decimal;
mod error;
mod format;
mod http_operations;
mod json_build;
mod json_local_views;
mod json_parse;
mod json_parse_strings;
mod json_query;
mod json_source;
mod json_source_scan;
mod json_text;
mod local_operations;
mod math;
mod precision;
mod rounding;
mod text_replace;
mod text_search;
mod text_split;
mod transcendental;

pub use bytes_operations::{bytes_from_text, bytes_join, bytes_segment};
pub use conversion::{integer_to_real, real_to_integer};
pub use decimal::{DecimalError, parse_integer, parse_real};
pub use error::LibraryError;
pub use format::{BooleanLexemes, PrimitiveValue, format_value};
pub use json_local_views::{LocalJsonViewCall, local_json_view};
pub use local_operations::{LocalOperationRequest, local_operation};
pub use math::{absolute, square_root};
pub use rounding::{round_real, truncate_real};
pub use text_replace::{replace_all, trim_text};
pub use text_search::{
    text_contains, text_ends_with, text_position, text_starts_with, text_substring,
};
pub use text_split::{join_text, split_text};

#[cfg(test)]
mod bytes_operations_tests;
#[cfg(test)]
mod json_local_views_tests;
#[cfg(test)]
mod json_parse_tests;
#[cfg(test)]
mod json_query_tests;
#[cfg(test)]
mod json_source_tests;
#[cfg(test)]
mod json_text_tests;
#[cfg(test)]
mod text_replace_tests;
#[cfg(test)]
mod text_search_tests;
#[cfg(test)]
mod text_split_tests;
pub use transcendental::{arctangent, cosine, exponential, natural_logarithm, real_power, sine};
