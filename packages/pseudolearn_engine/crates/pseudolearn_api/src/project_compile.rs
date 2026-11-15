use crate::project_authority::{execution_limits, with_manifest_status};
use crate::project_diagnostics::convert;
use crate::project_operations::{
    build, has_errors, internal, project_failure, run_analysis, select,
};
use crate::project_resource::ProjectRequest;
use crate::{ApiDiagnostic, ApiError, ExecutionLimits};
use pseudolearn_ir::{Module, SourceProfile};
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{ModuleId, ProjectCatalog};
use pseudolearn_semantic::HirModule;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{ModuleSchema, SyntaxTree, UnitKind};
use serde_json::{Value, json};

pub(crate) struct Compiled {
    pub module: Module,
    pub warnings: Vec<ApiDiagnostic>,
    pub request: ProjectRequest,
    pub limits: ExecutionLimits,
}

pub(crate) enum Outcome {
    Compiled(Box<Compiled>),
    Failed(Value),
}

pub(crate) fn compile(arguments: &Value) -> Result<Outcome, ApiError> {
    let request = ProjectRequest::parse(arguments)?;
    let catalog = match build(&request) {
        Ok(catalog) => catalog,
        Err(early) => return early.map(Outcome::Failed),
    };
    let entry = match select(&catalog, &request, true) {
        Ok(entry) => entry,
        Err(error) => return Ok(Outcome::Failed(project_failure(&[error]))),
    };
    let analysis = run_analysis(&catalog, &request, entry);
    let failed = analysis.hir.is_none() || has_errors(&analysis.diagnostics);
    let Some(hir) = analysis.hir.filter(|_| !failed) else {
        let diagnostics = convert(&catalog, &request, analysis.diagnostics);
        let failure = json!({"diagnostics": diagnostics, "project_errors": []});
        return Ok(Outcome::Failed(with_manifest_status(&request, failure)));
    };
    let warnings = convert(&catalog, &request, analysis.diagnostics);
    let module = lower(
        &catalog,
        &hir,
        (&analysis.trees, analysis.entry),
        &analysis.profiles,
    )
    .ok_or_else(internal)?;
    let limits = execution_limits(&catalog, &request, analysis.entry);
    Ok(Outcome::Compiled(Box::new(Compiled {
        module,
        warnings,
        request,
        limits,
    })))
}

fn lower(
    catalog: &ProjectCatalog,
    hir: &HirModule,
    selection: (&[SyntaxTree], Option<ModuleId>),
    profiles: &[Profile],
) -> Option<Module> {
    let sources: Vec<&SourceText> = catalog
        .modules()
        .iter()
        .filter_map(|module| catalog.source(module.id))
        .collect();
    let mut module = pseudolearn_lowering::lower_project(hir, &sources).ok()?;
    module.vocabulary = entry_vocabulary(selection.1, profiles);
    module.profiles = source_profiles(catalog, profiles);
    if let Some(name) = entry_name(catalog, selection.0, selection.1) {
        module.name = name;
    }
    pseudolearn_ir::verify_module(&module).ok()?;
    Some(module)
}

fn entry_vocabulary(entry: Option<ModuleId>, profiles: &[Profile]) -> String {
    let index = entry.and_then(|module| usize::try_from(module.0).ok());
    let profile = index
        .and_then(|position| profiles.get(position))
        .or_else(|| profiles.first())
        .copied()
        .unwrap_or(Profile::Spanish);
    profile.as_str().to_owned()
}

fn source_profiles(catalog: &ProjectCatalog, profiles: &[Profile]) -> Vec<SourceProfile> {
    catalog
        .modules()
        .iter()
        .zip(profiles)
        .map(|(module, profile)| SourceProfile {
            source_id: module.source_id,
            vocabulary: profile.as_str().to_owned(),
        })
        .collect()
}

fn entry_name(
    catalog: &ProjectCatalog,
    trees: &[SyntaxTree],
    entry: Option<ModuleId>,
) -> Option<String> {
    let index = usize::try_from(entry?.0).ok()?;
    let tree = trees.get(index)?;
    let source = catalog.source(entry?)?;
    ModuleSchema::extract(tree, source)
        .units
        .into_iter()
        .find(|unit| unit.kind == UnitKind::Program)
        .map(|unit| unit.name)
}
