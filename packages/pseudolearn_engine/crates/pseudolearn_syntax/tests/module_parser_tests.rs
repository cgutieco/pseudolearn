use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, parse_module_source, parse_source};

fn module(text: &str) -> (SyntaxTree, Vec<DiagnosticCode>) {
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_module_source(&source, Profile::Spanish, None);
    (
        tree,
        diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code)
            .collect(),
    )
}

fn standalone(text: &str) -> (SyntaxTree, Vec<DiagnosticCode>) {
    let source = SourceText::new(text.to_owned());
    let (tree, diagnostics) = parse_source(&source, Profile::Spanish);
    (
        tree,
        diagnostics
            .iter()
            .map(|diagnostic| diagnostic.code)
            .collect(),
    )
}

fn count(tree: &SyntaxTree, kind: NodeKind) -> usize {
    tree.nodes.iter().filter(|node| node.kind == kind).count()
}

#[test]
fn library_module_without_algorithm_has_no_diagnostics() {
    let (tree, codes) = module("Publico SubProceso f()\nFinSubProceso\n");
    assert!(codes.is_empty());
    assert_eq!(count(&tree, NodeKind::Subprogram), 1);
}

#[test]
fn empty_module_is_accepted() {
    let (_, codes) = module("");
    assert!(codes.is_empty());
}

#[test]
fn import_with_alias_builds_path_and_alias_nodes() {
    let (tree, codes) = module("Importar geo.vectores.Doble Como D;\nAlgoritmo P\nFinAlgoritmo\n");
    assert!(codes.is_empty());
    assert_eq!(count(&tree, NodeKind::ImportDeclaration), 1);
    assert_eq!(count(&tree, NodeKind::ModulePath), 1);
    assert_eq!(count(&tree, NodeKind::Identifier), 5);
}

#[test]
fn export_declaration_builds_a_path() {
    let (tree, codes) = module("Exportar geo.base.Doble;\n");
    assert!(codes.is_empty());
    assert_eq!(count(&tree, NodeKind::ExportDeclaration), 1);
}

#[test]
fn english_keywords_are_recognised() {
    let source =
        SourceText::new("import a.b as c;\npublic subroutine f()\nendSubroutine\n".to_owned());
    let (_, diagnostics) = parse_module_source(&source, Profile::English, None);
    assert!(diagnostics.is_empty());
}

#[test]
fn wildcard_is_rejected_with_expected_module_name() {
    let (_, codes) = module("Importar geo.vectores.*;\n");
    assert!(codes.contains(&DiagnosticCode::ExpectedModuleName));
}

#[test]
fn directive_after_a_unit_is_rejected() {
    let (_, codes) = module("SubProceso f()\nFinSubProceso\nImportar a.b;\n");
    assert!(codes.contains(&DiagnosticCode::UnexpectedTokenOutsideProgramUnit));
}

#[test]
fn visibility_before_an_algorithm_is_rejected() {
    let (_, codes) = module("Publico Algoritmo P\nFinAlgoritmo\n");
    assert!(codes.contains(&DiagnosticCode::UnexpectedTokenOutsideProgramUnit));
}

#[test]
fn visible_unit_starts_at_its_visibility_keyword() {
    let (tree, _) = module("Publico SubProceso f()\nFinSubProceso\n");
    let unit = tree
        .nodes
        .iter()
        .position(|node| node.kind == NodeKind::Subprogram);
    let span = unit.and_then(|index| tree.span_for_node(index));
    assert_eq!(span.map(|span| span.start), Some(0));
}

#[test]
fn standalone_text_rejects_module_syntax() {
    for text in [
        "Importar a.b;\nAlgoritmo P\nFinAlgoritmo\n",
        "Exportar a.b;\nAlgoritmo P\nFinAlgoritmo\n",
        "Publico SubProceso f()\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n",
    ] {
        let (_, codes) = standalone(text);
        assert!(codes.contains(&DiagnosticCode::ModuleSyntaxOutsideProject));
    }
}

#[test]
fn standalone_text_without_module_syntax_is_unchanged() {
    let (_, codes) = standalone("Algoritmo P\nFinAlgoritmo\n");
    assert!(codes.is_empty());
    let (_, missing) = standalone("");
    assert_eq!(missing, [DiagnosticCode::ExpectedAlgorithmStart]);
}

#[test]
fn module_mode_still_rejects_two_algorithms() {
    let (_, codes) = module("Algoritmo P\nFinAlgoritmo\nAlgoritmo Q\nFinAlgoritmo\n");
    assert!(codes.contains(&DiagnosticCode::MultipleAlgorithms));
}
