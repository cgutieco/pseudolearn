use crate::project_resource::{ProjectRequest, error_values, usage};
use crate::{ApiDiagnostic, ApiError, ExecuteRequest};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, DiagnosticSeverity, sort_diagnostics};
use pseudolearn_ir::Module;
use pseudolearn_project::{BuildFailure, ModuleId, ProjectCatalog, ProjectError, select_entry};
use pseudolearn_semantic::{HirModule, ProjectUnit, SemanticOptions, analyze_project};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{ModuleSchema, SyntaxTree, UnitKind, parse_module_source};
use serde_json::{Value, json};

struct Analysis {
    trees: Vec<SyntaxTree>,
    hir: Option<HirModule>,
    diagnostics: Vec<Diagnostic>,
    entry: Option<ModuleId>,
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
    Ok(json!({
        "diagnostics": diagnostics,
        "project_errors": [],
        "modules": modules(&catalog),
    }))
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
        return Ok(json!({"diagnostics": diagnostics, "project_errors": []}));
    };
    let warnings = convert(&catalog, &request, analysis.diagnostics);
    run(
        &catalog,
        &request,
        (&hir, &analysis.trees, analysis.entry),
        warnings,
    )
}

fn build(request: &ProjectRequest) -> Result<ProjectCatalog, Result<Value, ApiError>> {
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
    let terminator = request
        .strict
        .then_some(DiagnosticCode::MissingStatementTerminator);
    let mut trees = Vec::new();
    let mut diagnostics = Vec::new();
    for module in catalog.modules() {
        let Some(source) = catalog.source(module.id) else {
            continue;
        };
        let (tree, mut parsed) = parse_module_source(source, request.profile, terminator);
        diagnostics.append(&mut parsed);
        trees.push(tree);
    }
    let units = project_units(catalog, &trees);
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
    }
}

fn project_units<'catalog>(
    catalog: &'catalog ProjectCatalog,
    trees: &'catalog [SyntaxTree],
) -> Vec<ProjectUnit<'catalog>> {
    catalog
        .modules()
        .iter()
        .zip(trees)
        .filter_map(|(module, tree)| {
            catalog.source(module.id).map(|source| ProjectUnit {
                module: module.id,
                tree,
                source,
            })
        })
        .collect()
}

fn has_errors(diagnostics: &[Diagnostic]) -> bool {
    diagnostics
        .iter()
        .any(|diagnostic| diagnostic.severity == DiagnosticSeverity::Error)
}

fn convert(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    mut diagnostics: Vec<Diagnostic>,
) -> Vec<ApiDiagnostic> {
    sort_diagnostics(&mut diagnostics);
    diagnostics
        .iter()
        .filter_map(|diagnostic| {
            let source = source_of(catalog, diagnostic)?;
            Some(crate::diagnostic_conversion::convert(
                diagnostic,
                source,
                request.profile.as_str(),
            ))
        })
        .collect()
}

fn source_of<'catalog>(
    catalog: &'catalog ProjectCatalog,
    diagnostic: &Diagnostic,
) -> Option<&'catalog SourceText> {
    let module = catalog
        .modules()
        .iter()
        .find(|module| module.source_id == diagnostic.span.source_id)
        .or_else(|| catalog.modules().first())?;
    catalog.source(module.id)
}

fn run(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    compiled: (&HirModule, &[SyntaxTree], Option<ModuleId>),
    warnings: Vec<ApiDiagnostic>,
) -> Result<Value, ApiError> {
    let (hir, trees, entry) = compiled;
    let module = lower(catalog, request, hir, (trees, entry)).ok_or_else(internal)?;
    let bytecode = pseudolearn_bytecode::compile_module(&module).map_err(|_| internal())?;
    let program = pseudolearn_vm::load(&bytecode).map_err(|_| internal())?;
    let prepared = crate::execution::PreparedProgram::new(program, warnings);
    let execution = ExecuteRequest {
        profile: request.profile.as_str().to_owned(),
        strictness: if request.strict { "strict" } else { "flexible" }.to_owned(),
        ..ExecuteRequest::default()
    };
    let response = crate::execution::execute_prepared(&prepared, &execution);
    let mut value = serde_json::to_value(&response).map_err(|_| internal())?;
    if let Some(object) = value.as_object_mut() {
        object.insert("project_errors".to_owned(), json!([]));
    }
    Ok(value)
}

fn lower(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    hir: &HirModule,
    selection: (&[SyntaxTree], Option<ModuleId>),
) -> Option<Module> {
    let sources: Vec<&SourceText> = catalog
        .modules()
        .iter()
        .filter_map(|module| catalog.source(module.id))
        .collect();
    let mut module = pseudolearn_lowering::lower_project(hir, &sources).ok()?;
    module.vocabulary = request.profile.as_str().to_owned();
    if let Some(name) = entry_name(catalog, selection.0, selection.1) {
        module.name = name;
    }
    pseudolearn_ir::verify_module(&module).ok()?;
    Some(module)
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
