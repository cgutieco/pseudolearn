#![forbid(unsafe_code)]

mod anatomy;
mod anchors;
mod coverage;
mod coverage_items;
mod examples;
mod inline_code;
mod internal_ids;
mod links;
mod parity;
mod source_walk;

pub use anatomy::check_anatomy;
pub use anchors::{AnchorLock, build_lock, check_anchors, check_lock};
pub use coverage::{
    CoverageArea, CoverageExclusions, CoverageInput, CoverageReport, measure_coverage,
};
pub use examples::check_examples;
pub use inline_code::check_inline_code;
pub use internal_ids::check_internal_ids;
pub use links::check_links;
pub use parity::check_parity;
