use crate::ApiDiagnostic;
use crate::project_profiles::resolve_units;
use crate::project_resource::ProjectRequest;
use pseudolearn_diagnostics::{Diagnostic, sort_diagnostics};
use pseudolearn_project::{Module, ProjectCatalog};
use pseudolearn_source::{SourceId, SourceText};

pub(crate) fn convert(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    mut diagnostics: Vec<Diagnostic>,
) -> Vec<ApiDiagnostic> {
    sort_diagnostics(&mut diagnostics);
    let units = resolve_units(request);
    diagnostics
        .iter()
        .filter_map(|diagnostic| {
            let module = module_of(catalog, diagnostic.span.source_id)?;
            let source = catalog.source(module.id)?;
            let profile = units
                .get(&module.path)
                .map_or(request.profile, |unit| unit.profile);
            let mut converted = crate::diagnostic_conversion::convert_in_profile(
                diagnostic,
                source,
                (request.profile.as_str(), profile.as_str()),
            );
            converted.related = diagnostic
                .related
                .iter()
                .filter_map(|related| {
                    let owner = source_of(catalog, related.source_id)?;
                    Some(crate::diagnostic_conversion::span(*related, owner))
                })
                .collect();
            Some(converted)
        })
        .collect()
}

fn module_of(catalog: &ProjectCatalog, source_id: SourceId) -> Option<&Module> {
    catalog
        .modules()
        .iter()
        .find(|module| module.source_id == source_id)
        .or_else(|| catalog.modules().first())
}

fn source_of(catalog: &ProjectCatalog, source_id: SourceId) -> Option<&SourceText> {
    catalog.source(module_of(catalog, source_id)?.id)
}
