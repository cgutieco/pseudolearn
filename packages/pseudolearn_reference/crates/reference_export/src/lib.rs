#![forbid(unsafe_code)]

mod bundle;
mod manifest;
mod parts;
mod route_bundle;
mod search;

pub use bundle::{Bundle, BundleInput, SectionMeta, build_bundle};
pub use manifest::digest;
pub use parts::{PartDefinition, parse_parts};
pub use route_bundle::{
    ROUTE_FORMAT, RouteBundleInput, RoutePart, RouteTerm, build_route_bundle, parse_route_parts,
    spec_links,
};

pub const FORMAT: &str = "pseudolearn-reference/1";
