use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{parse_source, reprint_lossless};

#[test]
fn parses_basic_algorithm_in_spanish() {
    let source_code =
        "Algoritmo Principal\n  Definir x Como Entero\n  x <- 42\n  Escribir x\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    assert!(!tree.nodes.is_empty());
}

#[test]
fn parses_basic_algorithm_in_english() {
    let source_code =
        "algorithm Main\n  define x as integer\n  x <- 42\n  write x\nend algorithm\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::English);
    assert!(diagnostics.is_empty());
    assert!(!tree.nodes.is_empty());
}

#[test]
fn lossless_reprint_matches_source_exactly() {
    let source_code =
        "// header comment\nAlgoritmo Prueba\n  /* inner */\n  x <- 10 + 20\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let reprinted = reprint_lossless(&source, &tree.tokens);
    assert_eq!(reprinted, source_code);
}

#[test]
fn reports_unterminated_string_diagnostic() {
    let source_code = "Algoritmo Prueba\n  x <- \"hola mundo\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (_, diagnostics) = parse_source(&source, Profile::Spanish);
    assert!(!diagnostics.is_empty());
}

#[test]
fn handles_empty_source() {
    let source = SourceText::new(String::new());
    let (tree, diagnostics) = parse_source(&source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    assert_eq!(tree.node_count(), 0);
}
