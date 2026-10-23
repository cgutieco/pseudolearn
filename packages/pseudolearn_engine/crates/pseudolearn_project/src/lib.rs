#![forbid(unsafe_code)]

mod entry_selection;
mod input_validation;
mod logical_path;
mod module_catalog;
mod module_names;
mod project_error;
mod project_model;

pub use entry_selection::select_entry;
pub use module_catalog::{BuildFailure, Module, Package, ProjectCatalog};
pub use module_names::{is_declared_entry, qualifier};
pub use project_error::{MalformedProject, ProjectError, ProjectErrorCode};
pub use project_model::{FileInput, ModuleId, PackageId, PackageInput, PackageKind, ProjectInput};
