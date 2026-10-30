use crate::hir::HirModule;
use crate::identities::TypeId;
pub use crate::service_model::*;
use crate::session::{AnalysisSession, SemanticOptions};
use pseudolearn_source::{SourceId, SourceText, Span};
use pseudolearn_syntax::SyntaxTree;

impl ServiceAnalysis {
    pub fn symbol_at_byte_offset(&self, offset: usize) -> Option<&ServiceSymbol> {
        let reference = innermost_reference(&self.occurrences, offset)?;
        match reference.target {
            ServiceSymbolTarget::Local(local_id) => {
                let index = usize::try_from(local_id.0).ok()?;
                self.symbols.iter().find(|symbol| {
                    symbol.identifier == index
                        && matches!(
                            symbol.category,
                            ServiceSymbolCategory::Variable | ServiceSymbolCategory::Parameter
                        )
                })
            }
            ServiceSymbolTarget::Function(function_id) => {
                let index = usize::try_from(function_id.0).ok()?;
                self.symbols
                    .iter()
                    .find(|symbol| symbol.identifier == index)
            }
            ServiceSymbolTarget::Class(class_id) => {
                let index = usize::try_from(class_id.0).ok()?;
                self.symbols
                    .iter()
                    .find(|symbol| symbol.identifier == index)
            }
            _ => None,
        }
    }

    pub fn definition_span_at_byte_offset(&self, offset: usize) -> Option<Span> {
        let reference = innermost_reference(&self.occurrences, offset)?;
        find_definition_span(&self.module, reference.target)
    }

    pub fn reference_at_source_offset(
        &self,
        source_id: SourceId,
        offset: usize,
    ) -> Option<&ServiceReference> {
        let position = u32::try_from(offset).unwrap_or(u32::MAX);
        self.occurrences
            .iter()
            .filter(|reference| {
                reference.span.source_id == source_id
                    && reference.span.start <= position
                    && position <= reference.span.ending
            })
            .min_by_key(|reference| reference.span.length())
    }

    pub fn references_for_target(&self, target: ServiceSymbolTarget) -> Vec<ServiceReference> {
        self.occurrences
            .iter()
            .filter(|reference| reference.target == target)
            .cloned()
            .collect()
    }

    pub fn definition_span(&self, target: ServiceSymbolTarget) -> Option<Span> {
        find_definition_span(&self.module, target)
    }

    pub fn visible_symbols_at_span(&self, span: Span) -> Vec<&ServiceSymbol> {
        crate::service_visibility::visible(self, span)
    }

    pub fn expression_type_at_span(&self, span: Span) -> Option<TypeId> {
        self.expression_types
            .iter()
            .find(|(candidate, _)| *candidate == span)
            .map(|(_, type_id)| *type_id)
    }
}

pub fn references_at_byte_offset(
    analysis: &ServiceAnalysis,
    offset: usize,
) -> Vec<ServiceReference> {
    let Some(reference) = innermost_reference(&analysis.occurrences, offset) else {
        return Vec::new();
    };
    analysis
        .occurrences
        .iter()
        .filter(|candidate| candidate.target == reference.target)
        .cloned()
        .collect()
}

fn contains_offset(span: Span, offset: usize) -> bool {
    let start = usize::try_from(span.start).unwrap_or(usize::MAX);
    let ending = usize::try_from(span.ending).unwrap_or(0);
    offset >= start && offset <= ending
}

fn innermost_reference(
    occurrences: &[ServiceReference],
    offset: usize,
) -> Option<&ServiceReference> {
    occurrences
        .iter()
        .filter(|occurrence| contains_offset(occurrence.span, offset))
        .min_by_key(|occurrence| occurrence.span.ending.saturating_sub(occurrence.span.start))
}

fn find_definition_span(module: &HirModule, target: ServiceSymbolTarget) -> Option<Span> {
    match target {
        ServiceSymbolTarget::Local(local_id) => {
            let index = usize::try_from(local_id.0).ok()?;
            module.locals.get(index).map(|local| local.span)
        }
        ServiceSymbolTarget::Function(function_id) => {
            let index = usize::try_from(function_id.0).ok()?;
            module.functions.get(index).map(|func| func.span)
        }
        ServiceSymbolTarget::Class(class_id) => {
            let index = usize::try_from(class_id.0).ok()?;
            module.classes.get(index).map(|class| class.span)
        }
        ServiceSymbolTarget::Field(field_id) => {
            for class in &module.classes {
                if let Some(field) = class.fields.iter().find(|field| field.id == field_id) {
                    return Some(field.span);
                }
            }
            None
        }
        ServiceSymbolTarget::Builtin(_) => None,
    }
}

pub fn analyze_for_service(
    tree: &SyntaxTree,
    source: &SourceText,
    options: SemanticOptions,
) -> ServiceAnalysis {
    let mut session = AnalysisSession::new(tree, source, options);
    crate::unit_resolver::register(&mut session);
    crate::hierarchy::check(&mut session);
    crate::interface_realizations::check(&mut session);
    crate::flow::bodies(&mut session);
    let mut symbols = Vec::new();
    let mut occurrences = Vec::new();
    crate::service_collection::collect_symbols(
        &session.module,
        &session.inferred,
        &mut symbols,
        &mut occurrences,
    );
    crate::service_collection::collect_expression_occurrences(&session.module, &mut occurrences);
    let expression_types = session
        .module
        .expressions
        .spans
        .iter()
        .copied()
        .zip(session.module.expressions.types.iter().copied())
        .collect();
    ServiceAnalysis {
        module: session.module,
        diagnostics: session.diagnostics,
        symbols,
        occurrences,
        expression_types,
    }
}

pub fn service_analysis_from_project(
    module: HirModule,
    diagnostics: Vec<pseudolearn_diagnostics::Diagnostic>,
) -> ServiceAnalysis {
    let mut symbols = Vec::new();
    let mut occurrences = Vec::new();
    crate::service_collection::collect_symbols(
        &module,
        &std::collections::BTreeSet::new(),
        &mut symbols,
        &mut occurrences,
    );
    crate::service_collection::collect_expression_occurrences(&module, &mut occurrences);
    let expression_types = module
        .expressions
        .spans
        .iter()
        .copied()
        .zip(module.expressions.types.iter().copied())
        .collect();
    ServiceAnalysis {
        module,
        diagnostics,
        symbols,
        occurrences,
        expression_types,
    }
}
