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

fn parse(program: &str, profile: Profile) -> Vec<String> {
    let source = SourceText::new(program.to_owned());
    let (_, diagnostics) = parse_source(&source, profile);
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code.as_str().to_owned())
        .collect()
}

#[test]
fn accepts_lists_of_names_with_and_without_a_single_initial_value() {
    for program in [
        "Algoritmo P\nDefinir a, b, c Como Entero;\nFinAlgoritmo\n",
        "Algoritmo P\nDefinir x Como Real;\nFinAlgoritmo\n",
        "Algoritmo P\nDefinir x Como Real <- 1.5;\nFinAlgoritmo\n",
        "Algoritmo P\nDefinir n Como Entero;\nFinAlgoritmo\n",
        "Algoritmo P\nDefinir Mutable Como Entero <- 1;\nFinAlgoritmo\n",
    ] {
        assert!(parse(program, Profile::Spanish).is_empty(), "{program}");
    }
}

#[test]
fn rejects_an_initial_value_shared_by_several_names() {
    let codes = parse(
        "Algoritmo P\nDefinir a, b Como Entero <- 1;\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert_eq!(codes, vec!["initializerWithMultipleNames".to_owned()]);
}

#[test]
fn rejects_an_empty_list_and_a_dangling_comma() {
    for program in [
        "algorithm P\ndefine as integer;\nendAlgorithm\n",
        "algorithm P\ndefine a, as integer;\nendAlgorithm\n",
    ] {
        assert!(
            parse(program, Profile::English)
                .iter()
                .any(|code| code == "expectedIdentifierInDeclaration"),
            "{program}"
        );
    }
}

#[test]
fn reads_the_former_mutable_word_as_a_name_followed_by_a_missing_connector() {
    let codes = parse(
        "Algoritmo P\nDefinir Mutable x Como Entero <- 1;\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    assert_eq!(codes, vec!["expectedTypeConnector".to_owned()]);
}

#[test]
fn dimension_statements_accept_a_missing_type_but_class_fields_do_not() {
    assert!(
        parse(
            "Algoritmo P\nDefinir v Como Real;\nDimension v[3];\nFinAlgoritmo\n",
            Profile::Spanish
        )
        .is_empty()
    );
    assert!(
        parse(
            "Clase Caja\nDimension v[3];\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
            Profile::Spanish
        )
        .iter()
        .any(|code| code == "expectedTypeConnector")
    );
}
