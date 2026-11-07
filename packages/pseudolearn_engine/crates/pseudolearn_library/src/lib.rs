#![forbid(unsafe_code)]

mod civil_calendar;
mod collections;
mod conversion;
mod quoted_text;
pub use collections::{CollectionRequest, collection_operation};
pub use quoted_text::quote_text;
mod bytes_operations;
mod date_time_construction;
mod date_time_format;
mod date_time_operations;
mod date_time_parse;
mod decimal;
mod decimal_format;
mod error;
mod format;
mod http_operations;
mod json_build;
mod json_local_views;
mod json_parse;
mod json_parse_strings;
mod json_positions;
mod json_query;
mod json_source;
mod json_source_scan;
mod json_text;
mod local_operations;
mod math;
mod precision;
mod rounding;
mod text_case;
mod text_format_operations;
mod text_padding;
mod text_replace;
mod text_search;
mod text_split;
mod transcendental;

pub use bytes_operations::{bytes_from_text, bytes_join, bytes_segment};
pub use conversion::{integer_to_real, real_to_integer};
pub use decimal::{DecimalError, parse_integer, parse_real};
pub use decimal_format::{MAXIMUM_DECIMAL_PLACES, format_fixed_decimals};
pub use error::LibraryError;
pub use format::{BooleanLexemes, PrimitiveValue, format_value};
pub use json_local_views::{LocalJsonViewCall, local_json_view};
pub use local_operations::{LocalOperationRequest, local_operation};
pub use math::{absolute, square_root};
pub use rounding::{ceiling_real, floor_real, round_real, truncate_real};
pub use text_case::{to_lower_text, to_upper_text};
pub use text_padding::{MAXIMUM_PADDING_WIDTH, pad_left, pad_right};
pub use text_replace::{replace_all, trim_text};
pub use text_search::{
    text_contains, text_ends_with, text_position, text_starts_with, text_substring,
};
pub use text_split::{join_text, split_text};

#[cfg(test)]
mod bytes_operations_tests;
#[cfg(test)]
mod civil_calendar_tests;
#[cfg(test)]
mod date_time_tests;
#[cfg(test)]
mod decimal_format_tests;
#[cfg(test)]
mod json_local_views_tests;
#[cfg(test)]
mod json_parse_tests;
#[cfg(test)]
mod json_positions_tests;
#[cfg(test)]
mod json_query_tests;
#[cfg(test)]
mod json_source_tests;
#[cfg(test)]
mod json_text_tests;
#[cfg(test)]
mod text_case_tests;
#[cfg(test)]
mod text_padding_tests;
#[cfg(test)]
mod text_replace_tests;
#[cfg(test)]
mod text_search_tests;
#[cfg(test)]
mod text_split_tests;
pub use transcendental::{
    arc_cosine, arc_sine, arc_tangent2, arctangent, cosine, exponential, logarithm2, logarithm10,
    natural_logarithm, real_power, sine, tangent,
};
