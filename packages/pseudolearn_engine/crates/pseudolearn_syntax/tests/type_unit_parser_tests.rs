use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, parse_source};

fn parse(text: &str, profile: Profile) -> (SyntaxTree, Vec<Diagnostic>) {
    parse_source(&SourceText::new(text.to_owned()), profile)
}

fn has(diagnostics: &[Diagnostic], code: DiagnosticCode) -> bool {
    diagnostics.iter().any(|diagnostic| diagnostic.code == code)
}

fn count(tree: &SyntaxTree, kind: NodeKind) -> usize {
    tree.nodes.iter().filter(|node| node.kind == kind).count()
}

#[test]
fn parses_module_and_local_constants_in_both_profiles() {
    let spanish = "Constante A Como Entero <- 2;\nAlgoritmo P\nConstante B Como Real <- 1.5;\nEscribir A, B;\nFinAlgoritmo\n";
    let english = "constant A as integer <- 2;\nalgorithm P\nconstant B as real <- 1.5;\nwrite A, B;\nendAlgorithm\n";
    for (text, profile) in [(spanish, Profile::Spanish), (english, Profile::English)] {
        let (tree, diagnostics) = parse(text, profile);
        assert!(diagnostics.is_empty());
        assert_eq!(count(&tree, NodeKind::ConstantDeclaration), 2);
    }
}

#[test]
fn reports_constant_without_initializer_or_name() {
    let (_, diagnostics) = parse(
        "Constante A Como Entero;\nAlgoritmo P\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(has(
        &diagnostics,
        DiagnosticCode::ExpectedConstantInitializer
    ));
    let (_, diagnostics) = parse(
        "Constante Como Entero <- 1;\nAlgoritmo P\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(has(&diagnostics, DiagnosticCode::ExpectedConstantName));
}

#[test]
fn parses_enumerations_including_empty_and_single_member() {
    let source = "Enumerado Color\nRojo, Verde\nFinEnumerado\nEnumerado Solo\nUno\nFinEnumerado\nEnumerado Nada\nFinEnumerado\nAlgoritmo P\nFinAlgoritmo\n";
    let (tree, diagnostics) = parse(source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    assert_eq!(count(&tree, NodeKind::EnumUnit), 3);
    assert_eq!(count(&tree, NodeKind::EnumMembers), 2);
}

#[test]
fn reports_unclosed_enumeration_and_reserved_member() {
    let (_, diagnostics) = parse(
        "Enumerado Color\nRojo\nAlgoritmo P\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(has(&diagnostics, DiagnosticCode::UnclosedEnum));
    let (_, diagnostics) = parse(
        "Enumerado Color\nSi\nFinEnumerado\nAlgoritmo P\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(
        has(&diagnostics, DiagnosticCode::ReservedLexemeUsedAsName)
            || has(&diagnostics, DiagnosticCode::ExpectedEnumMember)
    );
    let (_, diagnostics) = parse(
        "Enumerado\nFinEnumerado\nAlgoritmo P\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(has(&diagnostics, DiagnosticCode::ExpectedEnumName));
}

#[test]
fn parses_records_with_several_declarations() {
    let source = "record Point\ndefine x, z as integer;\ndefine label as string;\nendRecord\nalgorithm P\nendAlgorithm\n";
    let (tree, diagnostics) = parse(source, Profile::English);
    assert!(diagnostics.is_empty());
    assert_eq!(count(&tree, NodeKind::RecordUnit), 1);
    assert_eq!(count(&tree, NodeKind::RecordField), 2);
}

#[test]
fn reports_non_declaration_inside_record_and_unclosed_record() {
    let (_, diagnostics) = parse(
        "Registro P\nDimension a[3] Como Entero;\nFinRegistro\nAlgoritmo Q\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(has(&diagnostics, DiagnosticCode::ExpectedRecordField));
    let (_, diagnostics) = parse(
        "Registro P\nDefinir a Como Entero;\nAlgoritmo Q\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(
        has(&diagnostics, DiagnosticCode::UnclosedRecord)
            || has(&diagnostics, DiagnosticCode::ExpectedRecordField)
    );
    let (_, diagnostics) = parse(
        "Registro\nFinRegistro\nAlgoritmo Q\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(has(&diagnostics, DiagnosticCode::ExpectedRecordName));
}

#[test]
fn parses_qualified_member_labels_in_switch() {
    let source = "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nSegun c Hacer\nColor.Rojo: Escribir 1;\nColor.Verde, Color.Rojo: Escribir 2;\nDe Otro Modo: Escribir 3;\nFinSegun\nFinAlgoritmo\n";
    let (tree, diagnostics) = parse(source, Profile::Spanish);
    assert!(diagnostics.is_empty());
    assert_eq!(count(&tree, NodeKind::Labels), 2);
}

#[test]
fn rejects_visibility_prefix_on_new_units() {
    let (_, diagnostics) = parse(
        "Publico Enumerado Color\nRojo\nFinEnumerado\nAlgoritmo P\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert!(has(
        &diagnostics,
        DiagnosticCode::UnexpectedTokenOutsideProgramUnit
    ));
}
