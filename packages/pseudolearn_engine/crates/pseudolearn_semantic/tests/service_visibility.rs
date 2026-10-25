use pseudolearn_semantic::HirModule;
use pseudolearn_semantic::identities::{LocalId, TypeId};
use pseudolearn_semantic::service_model::{ServiceAnalysis, ServiceSymbol, ServiceSymbolCategory};
use pseudolearn_source::{SourceId, Span};

fn symbol(identifier: usize, start: u32) -> ServiceSymbol {
    ServiceSymbol {
        identifier,
        name: "value".to_owned(),
        category: ServiceSymbolCategory::Variable,
        type_id: TypeId(0),
        span: Span::new(start, start.saturating_add(1)),
        is_inferred: false,
        owner_class: None,
        parameter_types: Vec::new(),
        return_type: None,
    }
}

fn analysis() -> ServiceAnalysis {
    let mut module = HirModule::default();
    module
        .local_visibility
        .insert(LocalId(0), Span::new(0, 100));
    module
        .local_visibility
        .insert(LocalId(1), Span::new(20, 40));
    ServiceAnalysis {
        module,
        diagnostics: Vec::new(),
        symbols: vec![symbol(0, 10), symbol(1, 25)],
        occurrences: Vec::new(),
        expression_types: Vec::new(),
    }
}

#[test]
fn restores_outer_symbol_after_shadowing_scope_closes() {
    let analysis = analysis();
    let before = analysis.visible_symbols_at_span(Span::new(21, 22));
    assert_eq!(before.len(), 1);
    assert_eq!(before.first().map(|symbol| symbol.identifier), Some(0));
    let inside = analysis.visible_symbols_at_span(Span::new(30, 31));
    assert_eq!(inside.len(), 1);
    assert_eq!(inside.first().map(|symbol| symbol.identifier), Some(1));
    let after = analysis.visible_symbols_at_span(Span::new(50, 51));
    assert_eq!(after.len(), 1);
    assert_eq!(after.first().map(|symbol| symbol.identifier), Some(0));
}

#[test]
fn excludes_undeclared_expired_and_other_source_symbols() {
    let analysis = analysis();
    assert!(analysis.visible_symbols_at_span(Span::new(1, 2)).is_empty());
    assert!(
        analysis
            .visible_symbols_at_span(Span::new(101, 102))
            .is_empty()
    );
    let other = Span::in_source(SourceId::new(1), 30, 31);
    assert!(analysis.visible_symbols_at_span(other).is_empty());
}

#[test]
fn resolves_sparse_local_identifiers_after_internal_symbols_are_omitted() {
    let mut analysis = analysis();
    analysis.symbols = vec![symbol(7, 10)];
    analysis
        .occurrences
        .push(pseudolearn_semantic::ServiceReference {
            span: Span::new(30, 31),
            target: pseudolearn_semantic::ServiceSymbolTarget::Local(LocalId(7)),
            is_write: false,
            is_declaration: false,
        });
    assert_eq!(
        analysis
            .symbol_at_byte_offset(30)
            .map(|symbol| symbol.identifier),
        Some(7)
    );
    assert!(analysis.symbol_at_byte_offset(40).is_none());
}
