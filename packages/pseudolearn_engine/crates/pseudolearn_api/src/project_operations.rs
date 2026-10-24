use crate::project_authority::{execution_limits, with_manifest_status};
use crate::project_diagnostics::convert;
use crate::project_profiles::resolve_units;
use crate::project_resource::{ProjectRequest, error_values, usage};
use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity};
use pseudolearn_ir::{Module, SourceProfile};
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{BuildFailure, ModuleId, ProjectCatalog, ProjectError, select_entry};
use pseudolearn_semantic::{HirModule, ProjectUnit, SemanticOptions, analyze_project};
use pseudolearn_source::{SourceId, SourceText, Span};
use pseudolearn_syntax::{ModuleSchema, SyntaxTree, UnitKind, parse_module_source};
use serde_json::{Value, json};

struct Analysis {
    trees: Vec<SyntaxTree>,
    hir: Option<HirModule>,
    diagnostics: Vec<Diagnostic>,
    entry: Option<ModuleId>,
    profiles: Vec<Profile>,
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
    let request = ProjectRequest::parse(arguments)?;
    let catalog = match build(&request) {
        Ok(catalog) => catalog,
        Err(early) => return early,
    };
    let entry = match select(&catalog, &request, true) {
        Ok(entry) => entry,
        Err(error) => return Ok(project_failure(&[error])),
    };
    let analysis = run_analysis(&catalog, &request, entry);
    let failed = analysis.hir.is_none() || has_errors(&analysis.diagnostics);
    let Some(hir) = analysis.hir.filter(|_| !failed) else {
        let diagnostics = convert(&catalog, &request, analysis.diagnostics);
        let failure = json!({"diagnostics": diagnostics, "project_errors": []});
        return Ok(with_manifest_status(&request, failure));
    };
    let warnings = convert(&catalog, &request, analysis.diagnostics);
    run(
        &catalog,
        &request,
        (&hir, &analysis.trees, analysis.entry),
        (&analysis.profiles, warnings),
    )
}

fn build(request: &ProjectRequest) -> Result<ProjectCatalog, Result<Value, ApiError>> {
    if !request.manifest_errors.is_empty() {
        return Err(Ok(crate::project_authority::manifest_failure(request)));
    }
    ProjectCatalog::build(&request.input).map_err(|failure| match failure {
        BuildFailure::Malformed(reason) => Err(usage(&reason.0)),
        BuildFailure::Project(errors) => Ok(project_failure(&errors)),
    })
}

fn project_failure(errors: &[ProjectError]) -> Value {
    json!({"diagnostics": [], "project_errors": error_values(errors)})
}

fn select(
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

fn run_analysis(
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
        let unit = resolved.get(&module.path);
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

fn has_errors(diagnostics: &[Diagnostic]) -> bool {
    diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
}

fn run(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    compiled: (&HirModule, &[SyntaxTree], Option<ModuleId>),
    reported: (&[Profile], Vec<ApiDiagnostic>),
) -> Result<Value, ApiError> {
    let (hir, trees, entry) = compiled;
    let (profiles, warnings) = reported;
    let module = lower(catalog, hir, (trees, entry), profiles).ok_or_else(internal)?;
    let bytecode = pseudolearn_bytecode::compile_module(&module).map_err(|_| internal())?;
    let program = pseudolearn_vm::load(&bytecode).map_err(|_| internal())?;
    let prepared = crate::execution::PreparedProgram::new(program, warnings);
    let execution = ExecuteRequest {
        profile: request.profile.as_str().to_owned(),
        strictness: if request.strict { "strict" } else { "flexible" }.to_owned(),
        limits: execution_limits(catalog, request, entry),
        ..ExecuteRequest::default()
    };
    let response = crate::execution::execute_prepared(&prepared, &execution);
    let mut value = serde_json::to_value(&response).map_err(|_| internal())?;
    if let Some(object) = value.as_object_mut() {
        object.insert("project_errors".to_owned(), json!([]));
    }
    Ok(with_manifest_status(request, value))
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

fn internal() -> ApiError {
    ApiError::InternalFault("internalFault".to_owned())
}
