#![forbid(unsafe_code)]

mod bundle;
mod manifest;
mod parts;
mod search;

pub use bundle::{Bundle, BundleInput, SectionMeta, build_bundle};
pub use parts::{PartDefinition, parse_parts};

pub const FORMAT: &str = "pseudolearn-reference/1";
