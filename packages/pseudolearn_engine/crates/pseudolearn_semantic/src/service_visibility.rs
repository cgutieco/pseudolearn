use crate::identities::LocalId;
use crate::service_model::{ServiceAnalysis, ServiceSymbol, ServiceSymbolCategory};
use pseudolearn_source::Span;
use std::collections::BTreeSet;

pub(crate) fn visible(analysis: &ServiceAnalysis, span: Span) -> Vec<&ServiceSymbol> {
    let mut names = BTreeSet::new();
    let mut symbols = Vec::new();
    for symbol in analysis.symbols.iter().rev() {
        if local_visible(analysis, symbol, span) && names.insert(symbol.name.clone()) {
            symbols.push(symbol);
        }
    }
    symbols.reverse();
    symbols
}

fn local_visible(analysis: &ServiceAnalysis, symbol: &ServiceSymbol, span: Span) -> bool {
    if !matches!(
        symbol.category,
        ServiceSymbolCategory::Variable | ServiceSymbolCategory::Parameter
    ) {
        return true;
    }
    let Ok(identifier) = u32::try_from(symbol.identifier) else {
        return false;
    };
    analysis
        .module
        .local_visibility
        .get(&LocalId(identifier))
        .is_some_and(|scope| {
            scope.source_id == span.source_id
                && symbol.span.start <= span.start
                && scope.start <= span.start
                && scope.ending >= span.ending
        })
}
