use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::analyze_semantics;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn detects_duplicate_variable_declaration() {
    let source_code =
        "Algoritmo Principal\n  Definir x Como Entero <- 1\n  Definir x Como Entero <- 2\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let (_, diagnostics) = analyze_semantics(&tree, &source, true);
    assert!(!diagnostics.is_empty());
}

#[test]
fn detects_undeclared_variable_in_strict_mode() {
    let source_code = "Algoritmo Principal\n  x <- 10\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let (_, diagnostics) = analyze_semantics(&tree, &source, true);
    assert!(!diagnostics.is_empty());
}

#[test]
fn detects_duplicate_subroutine() {
    let source_code = "SubProceso duplicate()\nFinSubProceso\nSubProceso duplicate()\nFinSubProceso\nAlgoritmo Entry\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let (_, diagnostics) = analyze_semantics(&tree, &source, true);
    assert!(!diagnostics.is_empty());
}

#[test]
fn detects_non_boolean_condition() {
    let source_code = "Algoritmo Principal\n  Si 123 Entonces\n    Definir x Como Entero <- 1\n  FinSi\nFinAlgoritmo\n";
    let source = SourceText::new(source_code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let (_, diagnostics) = analyze_semantics(&tree, &source, true);
    assert!(!diagnostics.is_empty());
}
