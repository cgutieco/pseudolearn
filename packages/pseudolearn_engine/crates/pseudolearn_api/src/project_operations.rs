use crate::project_authority::with_manifest_status;
use crate::project_compile::{Compiled, Outcome, compile};
use crate::project_diagnostics::convert;
use crate::project_profiles::resolve_units;
use crate::project_resource::{ProjectRequest, error_values, usage};
use crate::{ApiError, ExecuteRequest};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity};
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{BuildFailure, ModuleId, ProjectCatalog, ProjectError, select_entry};
use pseudolearn_semantic::{HirModule, ProjectUnit, SemanticOptions, analyze_project};
use pseudolearn_source::{SourceId, Span};
use pseudolearn_syntax::{SyntaxTree, parse_module_source};
use serde_json::{Value, json};

pub(crate) struct Analysis {
    pub trees: Vec<SyntaxTree>,
    pub hir: Option<HirModule>,
    pub diagnostics: Vec<Diagnostic>,
    pub entry: Option<ModuleId>,
    pub profiles: Vec<Profile>,
}

pub(crate) fn analyze(arguments: &Value) -> Result<Value, ApiError> {
    let request = ProjectRequest::parse(arguments)?;
    let catalog = match build(&request) {
        Ok(catalog) => catalog,
        Err(early) => return early,
    };
    let entry = match select(&catalog, &request, false) {
        Ok(entry) => entry,
        Err(error) => return Ok(project_failure(&[error])),
    };
    let analysis = run_analysis(&catalog, &request, entry);
    let diagnostics = convert(&catalog, &request, analysis.diagnostics);
    Ok(with_manifest_status(
        &request,
        json!({
            "diagnostics": diagnostics,
            "project_errors": [],
            "modules": modules(&catalog),
        }),
    ))
}

pub(crate) fn execute(arguments: &Value) -> Result<Value, ApiError> {
    match compile(arguments)? {
        Outcome::Failed(failure) => Ok(failure),
        Outcome::Compiled(compiled) => run(*compiled),
    }
}

pub(crate) fn build(request: &ProjectRequest) -> Result<ProjectCatalog, Result<Value, ApiError>> {
    if !request.manifest_errors.is_empty() {
        return Err(Ok(crate::project_authority::manifest_failure(request)));
    }
    ProjectCatalog::build(&request.input).map_err(|failure| match failure {
        BuildFailure::Malformed(reason) => Err(usage(&reason.0)),
        BuildFailure::Project(errors) => Ok(project_failure(&errors)),
    })
}

pub(crate) fn project_failure(errors: &[ProjectError]) -> Value {
    json!({"diagnostics": [], "project_errors": error_values(errors)})
}

pub(crate) fn select(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    required: bool,
) -> Result<Option<ModuleId>, ProjectError> {
    select_entry(catalog, request.entry.as_deref(), required)
}

fn modules(catalog: &ProjectCatalog) -> Value {
    Value::Array(
        catalog
            .modules()
            .iter()
            .map(|module| {
                let package = catalog.package(module.package).map_or("", |package| package.name.as_str());
                json!({"path": module.path, "package": package, "module": module.segments.join(".")})
            })
            .collect(),
    )
}

pub(crate) fn run_analysis(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    entry: Option<ModuleId>,
) -> Analysis {
    let (trees, profiles, mut diagnostics) = parse_modules(catalog, request);
    let units = project_units(catalog, &trees, &profiles);
    let options = SemanticOptions {
        profile: request.profile,
        strict: request.strict,
    };
    let (hir, mut semantic) = analyze_project(catalog, &units, entry, options);
    diagnostics.append(&mut semantic);
    Analysis {
        trees,
        hir,
        diagnostics,
        entry,
        profiles,
    }
}

type Parsed = (Vec<SyntaxTree>, Vec<Profile>, Vec<Diagnostic>);

fn parse_modules(catalog: &ProjectCatalog, request: &ProjectRequest) -> Parsed {
    let terminator = request
        .strict
        .then_some(DiagnosticCode::MissingStatementTerminator);
    let mut trees = Vec::new();
    let mut profiles = Vec::new();
    let mut diagnostics = Vec::new();
    let resolved = resolve_units(request);
    for module in catalog.modules() {
        let Some(source) = catalog.source(module.id) else {
            continue;
        };
        let unit = pseudolearn_project::logical_path_key(&module.path)
            .and_then(|path| resolved.get(&path));
        let profile = unit.map_or(request.profile, |found| found.profile);
        let (tree, mut parsed) = parse_module_source(source, profile, terminator);
        diagnostics.append(&mut parsed);
        if let Some(lexeme) = unit.and_then(|found| found.mismatch.as_deref()) {
            diagnostics.push(mismatch(module.source_id, lexeme));
        }
        trees.push(tree);
        profiles.push(profile);
    }
    (trees, profiles, diagnostics)
}

fn mismatch(source_id: SourceId, lexeme: &str) -> Diagnostic {
    Diagnostic::new(
        DiagnosticCode::ProfileMismatch,
        Span::in_source(source_id, 0, 0),
    )
    .with_argument("lexeme", lexeme)
}

fn project_units<'catalog>(
    catalog: &'catalog ProjectCatalog,
    trees: &'catalog [SyntaxTree],
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
                tree,
                source,
                profile: *profile,
            })
        })
        .collect()
}

pub(crate) fn has_errors(diagnostics: &[Diagnostic]) -> bool {
    diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
}

pub(crate) fn execution_request(compiled: &Compiled) -> ExecuteRequest {
    ExecuteRequest {
        profile: compiled.request.profile.as_str().to_owned(),
        strictness: if compiled.request.strict {
            "strict"
        } else {
            "flexible"
        }
        .to_owned(),
        limits: compiled.limits.clone(),
        source: Some(crate::ApiSourceIdentity {
            project_id: compiled.request.input.project_id,
            revision_id: compiled.request.input.revision_id,
            source_id: 0,
        }),
        ..ExecuteRequest::default()
    }
}

pub(crate) fn load_compiled(
    compiled: &Compiled,
) -> Result<pseudolearn_vm::LoadedProgram, ApiError> {
    let bytecode =
        pseudolearn_bytecode::compile_module(&compiled.module).map_err(|_| internal())?;
    pseudolearn_vm::load(&bytecode).map_err(|_| internal())
}

fn run(compiled: Compiled) -> Result<Value, ApiError> {
    let program = load_compiled(&compiled)?;
    let execution = execution_request(&compiled);
    let prepared = crate::execution::PreparedProgram::new(program, compiled.warnings);
    let response = crate::execution::execute_prepared(&prepared, &execution);
    let mut value = serde_json::to_value(&response).map_err(|_| internal())?;
    if let Some(object) = value.as_object_mut() {
        object.insert("project_errors".to_owned(), json!([]));
    }
    Ok(with_manifest_status(&compiled.request, value))
}

pub(crate) fn internal() -> ApiError {
    ApiError::InternalFault("internalFault".to_owned())
}
