use crate::ApiDiagnostic;
use crate::project_resource::ProjectRequest;
use pseudolearn_diagnostics::{Diagnostic, sort_diagnostics};
use pseudolearn_project::ProjectCatalog;
use pseudolearn_source::{SourceId, SourceText};

pub(crate) fn convert(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    mut diagnostics: Vec<Diagnostic>,
) -> Vec<ApiDiagnostic> {
    sort_diagnostics(&mut diagnostics);
    diagnostics
        .iter()
        .filter_map(|diagnostic| {
            let source = source_of(catalog, diagnostic.span.source_id)?;
            let mut converted =
                crate::diagnostic_conversion::convert(diagnostic, source, request.profile.as_str());
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

fn source_of(catalog: &ProjectCatalog, source_id: SourceId) -> Option<&SourceText> {
    let module = catalog
        .modules()
        .iter()
        .find(|module| module.source_id == source_id)
        .or_else(|| catalog.modules().first())?;
    catalog.source(module.id)
}
