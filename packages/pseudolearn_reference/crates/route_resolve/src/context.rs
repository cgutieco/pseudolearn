use crate::RouteCatalog;
use reference_model::PublishedSection;
use reference_resolve::Resolution;
use std::collections::BTreeMap;

pub struct RouteContext<'context> {
    pub resolution: &'context Resolution<'context>,
    pub catalog: &'context RouteCatalog,
    pub specification: &'context BTreeMap<String, PublishedSection>,
    pub current: &'context str,
}
