use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn requires_statement_terminators_in_both_profiles() {
    for (profile, program) in [
        (
            Profile::Spanish,
            "Algoritmo Main\nEscribir 1\nFinAlgoritmo\n",
        ),
        (Profile::English, "algorithm Main\nwrite 1\nendAlgorithm\n"),
    ] {
        let source = SourceText::new(program.to_owned());
        let (_, diagnostics) = parse_source(&source, profile);
        assert!(
            diagnostics.iter().any(|diagnostic| {
                diagnostic.code == DiagnosticCode::MissingStatementTerminator
            })
        );
    }
}

#[test]
fn accepts_terminated_statements_in_both_profiles() {
    for (profile, program) in [
        (
            Profile::Spanish,
            "Algoritmo Main\nEscribir 1;\nFinAlgoritmo\n",
        ),
        (Profile::English, "algorithm Main\nwrite 1;\nendAlgorithm\n"),
    ] {
        let source = SourceText::new(program.to_owned());
        let (_, diagnostics) = parse_source(&source, profile);
        assert!(diagnostics.is_empty(), "{profile:?}: {diagnostics:?}");
    }
}
