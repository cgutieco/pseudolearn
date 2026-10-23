use crate::module_catalog::ProjectCatalog;
use crate::project_error::{ProjectError, ProjectErrorCode};
use crate::project_model::{ModuleId, PackageKind};
use std::collections::BTreeSet;

pub fn select_entry(
    catalog: &ProjectCatalog,
    requested: Option<&str>,
    required: bool,
) -> Result<Option<ModuleId>, ProjectError> {
    let Some(path) = requested else {
        return if required {
            Err(ProjectError::new(ProjectErrorCode::EntryNotSelected, None))
        } else {
            Ok(None)
        };
    };
    catalog
        .module_by_path(path)
        .filter(|module| crate::module_names::is_declared_entry(catalog, *module))
        .map(Some)
        .ok_or_else(|| ProjectError::new(ProjectErrorCode::EntryNotFound, Some(path)))
}

pub(crate) fn validate_declared(catalog: &ProjectCatalog, errors: &mut Vec<ProjectError>) {
    let mut seen = BTreeSet::new();
    for package in catalog.packages() {
        for entry in &package.entries {
            if package.kind == PackageKind::Library {
                errors.push(ProjectError::new(
                    ProjectErrorCode::NoEntryInLibrary,
                    Some(entry),
                ));
                continue;
            }
            if !seen.insert(entry.as_str()) {
                errors.push(ProjectError::new(
                    ProjectErrorCode::EntryDuplicated,
                    Some(entry),
                ));
            }
            if !exists_in_package(catalog, package.name.as_str(), entry) {
                errors.push(ProjectError::new(
                    ProjectErrorCode::EntryNotFound,
                    Some(entry),
                ));
            }
        }
    }
}

fn exists_in_package(catalog: &ProjectCatalog, package: &str, path: &str) -> bool {
    catalog.module_by_path(path).is_some_and(|module| {
        catalog
            .module(module)
            .and_then(|module| catalog.package(module.package))
            .is_some_and(|owner| owner.name == package)
    })
}
