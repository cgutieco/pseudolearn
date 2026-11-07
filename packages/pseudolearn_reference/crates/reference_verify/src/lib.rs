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
mod route_anatomy;
mod route_book;
mod route_links;
mod route_mix;
mod route_normalize;
mod route_parity;
mod route_shapes;
mod route_terms;
mod route_text;
mod route_verified;
mod source_walk;

pub use anatomy::check_anatomy;
pub use anchors::{AnchorLock, build_lock, check_anchors, check_lock};
pub use coverage::{
    CoverageArea, CoverageExclusions, CoverageInput, CoverageReport, measure_coverage,
};
pub use examples::check_examples;
pub use inline_code::check_inline_code;
pub use internal_ids::{check_internal_ids, find_identifier};
pub use links::check_links;
pub use parity::check_parity;
pub use route_anatomy::{
    check_no_spec_duplicate, check_route_anatomy, check_route_format, check_scaffold,
};
pub use route_book::RouteBook;
pub use route_links::{LinkTargets, check_route_links};
pub use route_mix::{check_exercise_mix, check_hints, check_no_recipe};
pub use route_normalize::{normalize, outputs_match};
pub use route_parity::check_route_parity;
pub use route_terms::{
    check_prerequisites, check_recall_sources, check_term_order, check_term_owners,
};
pub use route_verified::{check_exercise_runs, check_exercise_shape};
