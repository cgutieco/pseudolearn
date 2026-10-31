use crate::workspace_index::{base_index, entry_failure, portable_key, project_failure};
use crate::workspace_invalidation::compare_workspace;
use crate::workspace_model::{
    WorkspaceError, WorkspaceIndex, WorkspaceOverlay, WorkspaceResult, WorkspaceSnapshot,
};
use crate::workspace_parse::{ParsedWorkspace, parse_catalog};
use pseudolearn_diagnostics::render::sort_diagnostics;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    BuildFailure, FileInput, ModuleId, ProjectCatalog, ProjectInput, select_entry,
};
use pseudolearn_semantic::{
    ProjectUnit, ResolvedUnitProfile, SemanticOptions, analyze_project_detailed,
    resolve_project_profiles, service_analysis_from_project,
};
use pseudolearn_syntax::SyntaxTree;
use std::collections::BTreeMap;
use std::sync::Arc;

pub(crate) struct WorkspaceBuildRequest<'input> {
    pub snapshot: &'input WorkspaceSnapshot,
    pub overlays: &'input BTreeMap<String, WorkspaceOverlay>,
    pub revision_id: u64,
    pub previous: Option<&'input WorkspaceIndex>,
}

struct CatalogAnalysisInput {
    catalog: ProjectCatalog,
    profiles: BTreeMap<String, ResolvedUnitProfile>,
    entry: Option<ModuleId>,
}

struct WorkspaceAnalysisOutput {
    parsed: ParsedWorkspace,
    analysis: pseudolearn_semantic::ProjectAnalysis,
}

pub(crate) fn build_workspace(
    request: WorkspaceBuildRequest<'_>,
) -> Result<(WorkspaceResult, WorkspaceIndex), WorkspaceError> {
    let project = effective_project(&request);
    let profiles = resolved_profiles(&project, &request.snapshot.options);
    let catalog = match ProjectCatalog::build(&project) {
        Ok(catalog) => catalog,
        Err(BuildFailure::Malformed(error)) => {
            return Err(WorkspaceError::MalformedProject(error));
        }
        Err(BuildFailure::Project(errors)) => {
            return Ok(project_failure(
                &request,
                &project,
                profiles.clone(),
                errors,
            ));
        }
    };
    let entry = match select_entry(&catalog, request.snapshot.options.entry.as_deref(), false) {
        Ok(entry) => entry,
        Err(error) => {
            return Ok(entry_failure(&request, &project, profiles.clone(), error));
        }
    };
    analyze_catalog(
        request,
        project,
        CatalogAnalysisInput {
            catalog,
            profiles,
            entry,
        },
    )
}

fn effective_project(request: &WorkspaceBuildRequest<'_>) -> ProjectInput {
    let mut project = request.snapshot.project.clone();
    project.revision_id = request.revision_id;
    for overlay in request.overlays.values() {
        let key = portable_key(&overlay.path);
        let existing = project
            .files
            .iter_mut()
            .find(|file| portable_key(&file.path) == key);
        match existing {
            Some(file) => {
                file.source_id = overlay.source_id;
                file.text.clone_from(&overlay.text);
            }
            None => project.files.push(FileInput {
                path: overlay.path.clone(),
                source_id: overlay.source_id,
                text: overlay.text.clone(),
            }),
        }
    }
    project
}

fn resolved_profiles(
    project: &ProjectInput,
    options: &crate::workspace_model::WorkspaceOptions,
) -> BTreeMap<String, ResolvedUnitProfile> {
    resolve_project_profiles(
        &project.files,
        &options.file_profiles,
        &options.configurations,
        options.requested_profile,
    )
    .into_iter()
    .collect()
}

fn analyze_catalog(
    request: WorkspaceBuildRequest<'_>,
    project: ProjectInput,
    input: CatalogAnalysisInput,
) -> Result<(WorkspaceResult, WorkspaceIndex), WorkspaceError> {
    let parsed = parse_catalog(
        &input.catalog,
        &input.profiles,
        &request.snapshot.options,
        request.previous,
    );
    let units = project_units(&input.catalog, &parsed.trees, &parsed.profiles);
    let profile = request
        .snapshot
        .options
        .requested_profile
        .unwrap_or_default();
    let analysis = analyze_project_detailed(
        &input.catalog,
        &units,
        input.entry,
        SemanticOptions {
            profile,
            strict: request.snapshot.options.strict,
        },
    );
    assemble_workspace_result(
        request,
        project,
        input.profiles,
        WorkspaceAnalysisOutput { parsed, analysis },
    )
}

fn assemble_workspace_result(
    request: WorkspaceBuildRequest<'_>,
    project: ProjectInput,
    profiles: BTreeMap<String, ResolvedUnitProfile>,
    output: WorkspaceAnalysisOutput,
) -> Result<(WorkspaceResult, WorkspaceIndex), WorkspaceError> {
    let parsed = output.parsed;
    let analysis = output.analysis;
    let mut diagnostics = parsed.diagnostics;
    diagnostics.extend(analysis.diagnostics);
    sort_diagnostics(&mut diagnostics);
    let mut index = base_index(&project, &request.snapshot.options, profiles);
    index.units = parsed.units;
    index.parsed_units = parsed.cache;
    index.imports.clone_from(&analysis.imports);
    index.modules = parsed.modules;
    let invalidation = compare_workspace(request.previous, &index);
    let result = WorkspaceResult {
        project_id: project.project_id,
        revision_id: project.revision_id,
        service_analysis: analysis
            .hir
            .clone()
            .map(|module| service_analysis_from_project(module, diagnostics.clone())),
        hir: analysis.hir,
        diagnostics,
        project_errors: Vec::new(),
        imports: analysis.imports,
        invalidation,
    };
    Ok((result, index))
}

fn project_units<'catalog>(
    catalog: &'catalog ProjectCatalog,
    trees: &'catalog [Arc<SyntaxTree>],
    profiles: &[Profile],
) -> Vec<ProjectUnit<'catalog>> {
    catalog
        .modules()
        .iter()
        .zip(trees)
        .zip(profiles)
        .filter_map(|((module, tree), profile)| {
            catalog.source(module.id).map(|source| ProjectUnit {
                module: module.id,
                tree: tree.as_ref(),
                source,
                profile: *profile,
            })
        })
        .collect()
}
