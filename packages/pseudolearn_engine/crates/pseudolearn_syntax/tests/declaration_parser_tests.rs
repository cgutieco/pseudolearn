use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn accepts_json_types_in_both_profiles() {
    let programs = [
        (
            Profile::Spanish,
            "Registro JsonTypes\nDefinir valueData Como ValorJson;\nDefinir kindData Como TipoJson;\nDefinir errorData Como ErrorJson;\nDefinir codeData Como CodigoErrorJson;\nFinRegistro\nAlgoritmo Main\nFinAlgoritmo\n",
        ),
        (
            Profile::English,
            "record JsonTypes\ndefine valueData as JsonValue;\ndefine kindData as JsonKind;\ndefine errorData as JsonError;\ndefine codeData as JsonErrorCode;\nendRecord\nalgorithm Main\nendAlgorithm\n",
        ),
    ];
    for (profile, program) in programs {
        let source = SourceText::new(program.to_owned());
        let (tree, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{profile:?}: {diagnostics:?}");
        assert!(tree.node_count() > 1);
    }
}

#[test]
fn rejects_a_reserved_non_type_keyword_in_type_position() {
    let source = SourceText::new("record JsonTypes\ndefine value as if;\nendRecord\n".to_owned());
    let (_, diagnostics) = parse_source(&source, Profile::English);
    assert!(
        diagnostics
            .iter()
            .any(|diagnostic| diagnostic.code.as_str() == "expectedType")
    );
}
