use crate::ApiDiagnostic;
use crate::project_profiles::resolve_units;
use crate::project_resource::ProjectRequest;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode, sort_diagnostics_with};
use pseudolearn_project::{Module, ProjectCatalog, source_order_keys};
use pseudolearn_source::{SourceId, SourceText, Span};
use std::collections::BTreeMap;

pub(crate) fn convert(
    catalog: &ProjectCatalog,
    request: &ProjectRequest,
    mut diagnostics: Vec<Diagnostic>,
) -> Vec<ApiDiagnostic> {
    let order_keys = source_order_keys(catalog);
    sort_diagnostics_with(&mut diagnostics, &order_keys);
    let units = resolve_units(request);
    let sources = source_index(catalog);
    let empty = SourceText::new(String::new());
    diagnostics
        .iter()
        .map(|diagnostic| {
            let Some((module, source)) = source(diagnostic.span.source_id, &sources, &empty) else {
                return internal_fault(&empty, request);
            };
            let profile = module
                .and_then(|module| pseudolearn_project::logical_path_key(&module.path))
                .and_then(|path| units.get(&path))
                .map_or(request.profile, |unit| unit.profile);
            let mut converted = crate::diagnostic_conversion::convert_in_profile(
                diagnostic,
                source,
                (request.profile.as_str(), profile.as_str()),
            );
            let Some(related) = related(diagnostic, &sources, &empty) else {
                return internal_fault(&empty, request);
            };
            converted.related = related;
            converted
        })
        .collect()
}

type SourceIndex<'catalog> = BTreeMap<SourceId, (&'catalog Module, &'catalog SourceText)>;

fn source_index(catalog: &ProjectCatalog) -> SourceIndex<'_> {
    catalog
        .modules()
        .iter()
        .filter_map(|module| {
            catalog
                .source(module.id)
                .map(|source| (module.source_id, (module, source)))
        })
        .collect()
}

fn source<'catalog>(
    source_id: SourceId,
    sources: &SourceIndex<'catalog>,
    empty: &'catalog SourceText,
) -> Option<(Option<&'catalog Module>, &'catalog SourceText)> {
    if source_id == SourceId::STANDALONE {
        return Some((None, empty));
    }
    sources
        .get(&source_id)
        .map(|(module, source)| (Some(*module), *source))
}

fn related(
    diagnostic: &Diagnostic,
    sources: &SourceIndex<'_>,
    empty: &SourceText,
) -> Option<Vec<crate::ApiSpan>> {
    diagnostic
        .related
        .iter()
        .map(|related| {
            let (_, source) = source(related.source_id, sources, empty)?;
            Some(crate::diagnostic_conversion::span(*related, source))
        })
        .collect()
}

fn internal_fault(empty: &SourceText, request: &ProjectRequest) -> ApiDiagnostic {
    let diagnostic = Diagnostic::new(DiagnosticCode::InternalFault, Span::empty());
    crate::diagnostic_conversion::convert(&diagnostic, empty, request.profile.as_str())
}
