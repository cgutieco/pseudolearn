use crate::logical_path::key;
use crate::module_catalog::ProjectCatalog;
use crate::project_model::{ModuleId, PackageKind};

pub fn qualifier(catalog: &ProjectCatalog, id: ModuleId) -> String {
    let Some(module) = catalog.module(id) else {
        return String::new();
    };
    let package = catalog
        .package(module.package)
        .map_or("", |package| &package.name);
    let mut parts = vec![package];
    parts.extend(module.segments.iter().map(String::as_str));
    parts.join(".")
}

pub fn is_declared_entry(catalog: &ProjectCatalog, id: ModuleId) -> bool {
    let Some(module) = catalog.module(id) else {
        return false;
    };
    catalog.package(module.package).is_some_and(|package| {
        package.kind == PackageKind::Application
            && package
                .entries
                .iter()
                .any(|entry| key(entry) == key(&module.path))
    })
}
