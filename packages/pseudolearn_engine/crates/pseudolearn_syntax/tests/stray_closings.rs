use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;

fn codes(program: &str) -> Vec<DiagnosticCode> {
    let source = pseudolearn_source::SourceText::new(program.to_owned());
    let (_, diagnostics) = pseudolearn_syntax::parse_source(&source, Profile::Spanish);
    diagnostics
        .iter()
        .map(|diagnostic| diagnostic.code)
        .collect()
}

#[test]
fn an_else_inside_its_conditional_is_not_stray() {
    let program =
        "Algoritmo P\nSi Verdadero Entonces\nEscribir 1;\nSino\nEscribir 2;\nFinSi\nFinAlgoritmo\n";
    assert!(codes(program).is_empty());
}

#[test]
fn every_stray_word_is_one_unexpected_statement() {
    let program =
        "Algoritmo P\nFinMientras\nHasta Que\nFinPara\nFinSegun\nEscribir 1;\nFinAlgoritmo\n";
    assert_eq!(codes(program), vec![DiagnosticCode::UnexpectedStatement; 4]);
}

#[test]
fn a_function_literal_does_not_inherit_the_enclosing_blocks() {
    let program = "Algoritmo P\nSi Verdadero Entonces\nDefinir f Como SubProceso() <- SubProceso()\nSino\nFinSubProceso;\nFinSi\nFinAlgoritmo\n";
    assert_eq!(codes(program), vec![DiagnosticCode::UnexpectedStatement]);
}

#[test]
fn an_else_owned_by_an_outer_conditional_still_ends_the_inner_loop() {
    let program = "Algoritmo P\nSi Verdadero Entonces\nMientras Falso Hacer\nSino\nFinMientras\nFinSi\nFinAlgoritmo\n";
    assert!(codes(program).contains(&DiagnosticCode::UnclosedWhileStatement));
}

#[test]
fn a_lexical_gap_does_not_add_a_missing_terminator() {
    let program = "Algoritmo P\nEscribir 5 @ 2;\nEscribir 1 @;\nFinAlgoritmo\n";
    assert_eq!(
        codes(program),
        vec![DiagnosticCode::UnrecognizedCharacter; 2]
    );
}
