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
