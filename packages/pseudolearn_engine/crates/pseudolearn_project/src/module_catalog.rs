use crate::input_validation;
use crate::logical_path::{is_prefix, segments};
use crate::project_error::{MalformedProject, ProjectError, ProjectErrorCode};
use crate::project_model::{ModuleId, PackageId, PackageKind, ProjectInput};
use pseudolearn_source::{
    ProjectId, RevisionId, SourceId, SourceIdentity, SourceText, source_text_with_identity,
};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum BuildFailure {
    Malformed(MalformedProject),
    Project(Vec<ProjectError>),
}

#[derive(Clone, Debug)]
pub struct Package {
    pub name: String,
    pub root: Vec<String>,
    pub kind: PackageKind,
    pub entries: Vec<String>,
    pub dependencies: BTreeMap<String, PackageId>,
}

#[derive(Clone, Debug)]
pub struct Module {
    pub id: ModuleId,
    pub package: PackageId,
    pub path: String,
    pub segments: Vec<String>,
    pub source_id: SourceId,
}

#[derive(Debug)]
pub struct ProjectCatalog {
    packages: Vec<Package>,
    modules: Vec<Module>,
    sources: Vec<SourceText>,
}

impl ProjectCatalog {
    pub fn build(input: &ProjectInput) -> Result<Self, BuildFailure> {
        input_validation::check(input).map_err(BuildFailure::Malformed)?;
        if input.packages.is_empty() {
            return Err(BuildFailure::Project(vec![ProjectError::new(
                ProjectErrorCode::EmptyWorkspace,
                None,
            )]));
        }
        let mut errors = Vec::new();
        let packages = crate::module_catalog::packages(input, &mut errors);
        let placed = place_files(input, &packages, &mut errors);
        let catalog = assemble(input, packages, placed);
        crate::entry_selection::validate_declared(&catalog, &mut errors);
        if errors.is_empty() {
            return Ok(catalog);
        }
        ProjectError::sort(&mut errors);
        errors.dedup();
        Err(BuildFailure::Project(errors))
    }

    pub fn packages(&self) -> &[Package] {
        &self.packages
    }

    pub fn modules(&self) -> &[Module] {
        &self.modules
    }

    pub fn package(&self, id: PackageId) -> Option<&Package> {
        self.packages.get(usize::try_from(id.0).ok()?)
    }

    pub fn module(&self, id: ModuleId) -> Option<&Module> {
        self.modules.get(usize::try_from(id.0).ok()?)
    }

    pub fn source(&self, id: ModuleId) -> Option<&SourceText> {
        self.sources.get(usize::try_from(id.0).ok()?)
    }

    pub fn module_by_path(&self, path: &str) -> Option<ModuleId> {
        self.modules
            .iter()
            .find(|module| module.path == path)
            .map(|module| module.id)
    }
}

fn packages(input: &ProjectInput, errors: &mut Vec<ProjectError>) -> Vec<Package> {
    let identifiers: BTreeMap<&str, PackageId> = input
        .packages
        .iter()
        .enumerate()
        .map(|(index, package)| {
            (
                package.name.as_str(),
                PackageId(u32::try_from(index).unwrap_or(u32::MAX)),
            )
        })
        .collect();
    input
        .packages
        .iter()
        .map(|package| {
            let mut dependencies = BTreeMap::new();
            for (alias, target) in &package.dependencies {
                match identifiers.get(target.as_str()) {
                    Some(identifier) => {
                        dependencies.insert(alias.clone(), *identifier);
                    }
                    None => errors.push(ProjectError::new(
                        ProjectErrorCode::DependencyNotFound,
                        Some(&package.name),
                    )),
                }
            }
            Package {
                name: package.name.clone(),
                root: segments(&package.root).unwrap_or_default(),
                kind: package.kind,
                entries: package.entries.clone(),
                dependencies,
            }
        })
        .collect()
}

struct PlacedFile {
    file: usize,
    package: PackageId,
    segments: Vec<String>,
    relative: Vec<String>,
}

fn place_files(
    input: &ProjectInput,
    packages: &[Package],
    errors: &mut Vec<ProjectError>,
) -> Vec<PlacedFile> {
    let mut placed = Vec::new();
    for (file, entry) in input.files.iter().enumerate() {
        let path = segments(&entry.path).unwrap_or_default();
        let owners: Vec<usize> = packages
            .iter()
            .enumerate()
            .filter(|(_, package)| is_prefix(&package.root, &path))
            .map(|(index, _)| index)
            .collect();
        match owners.as_slice() {
            [owner] => placed.push(place(file, *owner, packages, path)),
            [] => errors.push(ProjectError::new(
                ProjectErrorCode::ModuleOutsideRoots,
                Some(&entry.path),
            )),
            _ => errors.push(ProjectError::new(
                ProjectErrorCode::ModuleInMultipleRoots,
                Some(&entry.path),
            )),
        }
    }
    placed
}

fn place(file: usize, owner: usize, packages: &[Package], path: Vec<String>) -> PlacedFile {
    let root_length = packages.get(owner).map_or(0, |package| package.root.len());
    PlacedFile {
        file,
        package: PackageId(u32::try_from(owner).unwrap_or(u32::MAX)),
        relative: path.get(root_length..).unwrap_or_default().to_vec(),
        segments: path,
    }
}

fn assemble(
    input: &ProjectInput,
    packages: Vec<Package>,
    mut placed: Vec<PlacedFile>,
) -> ProjectCatalog {
    placed.sort_by(|left, right| left.segments.cmp(&right.segments));
    let mut modules = Vec::new();
    let mut sources = Vec::new();
    for (index, entry) in placed.into_iter().enumerate() {
        let Some(file) = input.files.get(entry.file) else {
            continue;
        };
        let source_id = SourceId::new(file.source_id);
        modules.push(Module {
            id: ModuleId(u32::try_from(index).unwrap_or(u32::MAX)),
            package: entry.package,
            path: file.path.clone(),
            segments: entry.relative,
            source_id,
        });
        let identity = SourceIdentity {
            project_id: ProjectId::new(input.project_id),
            revision_id: RevisionId::new(input.revision_id),
            source_id,
        };
        sources.push(source_text_with_identity(identity, file.text.clone()));
    }
    ProjectCatalog {
        packages,
        modules,
        sources,
    }
}
