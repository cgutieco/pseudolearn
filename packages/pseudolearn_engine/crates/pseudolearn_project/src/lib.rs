#![forbid(unsafe_code)]

mod authority;
mod capability_fs;
mod dependency_graph;
mod entry_selection;
mod graph_adjacency;
mod graph_components;
mod graph_cycle_path;
mod input_validation;
mod lock_canonical;
mod lock_error;
mod lock_model;
mod lock_normalization;
mod lock_parser;
mod lock_verification;
mod logical_path;
mod manifest_checker;
mod manifest_cursor;
mod manifest_error;
mod manifest_model;
mod manifest_parser;
mod manifest_resolution;
mod manifest_scalars;
mod manifest_schema;
mod manifest_sections;
mod manifest_value;
mod manifest_values;
mod module_catalog;
mod module_cycles;
mod module_names;
mod package_cycles;
mod profile_resolution;
mod project_error;
mod project_model;

pub use authority::{HostGrants, LimitAuthority, resolve_permissions};
pub use capability_fs::{CapabilityFsError, ConfinedDirectory, FileRights};
pub use dependency_graph::find_cycles;
pub use entry_selection::select_entry;
pub use lock_error::{LockError, LockErrorCode};
pub use lock_model::{DIGEST_PREFIX, Lock, LockKind, LockPackage, is_digest};
pub use logical_path::{logical_path_key, normalize_logical_path};
pub use manifest_error::{Location, ManifestError, ManifestErrorCode};
pub use manifest_model::{
    Field, LimitName, LimitRequest, Manifest, ManifestDependency, PermissionName, ProfileChoice,
    ProfileException, Provenance,
};
pub use manifest_resolution::{
    Configuration, LocatedError, LocatedManifest, ManifestRequest, is_logical_path, resolve_all,
};
pub use module_catalog::{BuildFailure, Module, Package, ProjectCatalog, source_order_keys};
pub use module_cycles::{ImportEdge, ModuleCycle, module_cycles};
pub use module_names::{is_declared_entry, qualifier};
pub use profile_resolution::{
    ProfileChosen, ProfileOrigin, ProfileSources, ResolvedProfile, resolve_profile,
};
pub use project_error::{MalformedProject, ProjectError, ProjectErrorCode};
pub use project_model::{FileInput, ModuleId, PackageId, PackageInput, PackageKind, ProjectInput};
