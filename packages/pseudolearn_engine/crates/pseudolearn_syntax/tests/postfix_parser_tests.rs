use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn parses_error_code_fields_after_member_access_in_both_profiles() {
    let programs = [
        (
            "Algoritmo Main\nEscribir problem.Codigo;\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "algorithm Main\nwrite problem.code;\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        let source = SourceText::new(program.to_owned());
        let (_, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
    }
}

#[test]
fn parses_error_position_fields_after_member_access_in_both_profiles() {
    let programs = [
        (
            "Algoritmo Main\nEscribir problem.JsonLinea, problem.JsonColumna;\nFinAlgoritmo\n",
            Profile::Spanish,
        ),
        (
            "algorithm Main\nwrite problem.jsonLine, problem.jsonColumn;\nendAlgorithm\n",
            Profile::English,
        ),
    ];
    for (program, profile) in programs {
        let source = SourceText::new(program.to_owned());
        let (_, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{diagnostics:?}");
    }
}

#[test]
fn rejects_error_position_fields_as_variable_names() {
    let source = SourceText::new(
        "Algoritmo Main\nDefinir JsonLinea Como Entero <- 1;\nFinAlgoritmo\n".to_owned(),
    );
    let (_, diagnostics) = parse_source(&source, Profile::Spanish);
    assert!(!diagnostics.is_empty());
}
