use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::service_analysis::references_at_byte_offset;
use pseudolearn_semantic::{SemanticOptions, analyze_for_service};
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::parse_source;

#[test]
fn locates_symbols_and_references_for_service_analysis() {
    let source_code =
        "Algoritmo Principal\n  Definir valor Como Entero <- 42\n  Escribir valor\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let options = SemanticOptions {
        profile: Profile::Spanish,
        strict: true,
    };
    let analysis = analyze_for_service(&tree, &source, options);
    assert!(analysis.diagnostics.is_empty());
    assert!(!analysis.symbols.is_empty());
    let symbol = analysis.symbol_at_byte_offset(30);
    assert!(symbol.is_some());
    let references = references_at_byte_offset(&analysis, 30);
    assert!(!references.is_empty());
    let definition_span = analysis.definition_span_at_byte_offset(30);
    assert!(definition_span.is_some());
}

#[test]
fn returns_none_when_querying_unknown_byte_offsets() {
    let source_code = "Algoritmo Vacio\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let options = SemanticOptions {
        profile: Profile::Spanish,
        strict: true,
    };
    let analysis = analyze_for_service(&tree, &source, options);
    assert!(analysis.symbol_at_byte_offset(9999).is_none());
    assert!(analysis.definition_span_at_byte_offset(9999).is_none());
    assert!(references_at_byte_offset(&analysis, 9999).is_empty());
    assert!(
        analysis
            .expression_type_at_span(Span::new(999, 1000))
            .is_none()
    );
}

#[test]
fn locates_method_call_definition() {
    let source_code = "Clase Punto\n  SubProceso Mover()\n  FinSubProceso\nFinClase\n\nAlgoritmo Principal\n  Definir p Como Punto <- Nuevo Punto();\n  p.Mover();\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let options = SemanticOptions {
        profile: Profile::Spanish,
        strict: true,
    };
    let analysis = analyze_for_service(&tree, &source, options);
    let offset = 124;
    let definition_span = analysis.definition_span_at_byte_offset(offset);
    assert!(definition_span.is_some());
}
