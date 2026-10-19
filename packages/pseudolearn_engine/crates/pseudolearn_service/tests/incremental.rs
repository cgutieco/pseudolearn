use pseudolearn_lexicon::Profile;
use pseudolearn_service::DocumentSession;

#[test]
fn matches_cold_analysis() {
    let initial = "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n";
    let mut session = DocumentSession::new(initial.to_owned(), Profile::Spanish, true);
    let edited = "Algoritmo Principal\n  Definir x Como Entero;\n  x <- 42;\nFinAlgoritmo\n";
    session.apply_edit(edited.to_owned());

    let cold_session = DocumentSession::new(edited.to_owned(), Profile::Spanish, true);
    assert_eq!(
        session.analysis.diagnostics.len(),
        cold_session.analysis.diagnostics.len()
    );
    assert_eq!(
        session.analysis.symbols.len(),
        cold_session.analysis.symbols.len()
    );
}

#[test]
fn reports_reused_and_reanalyzed_units() {
    let initial = "SubProceso Uno()\n  x <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  y <- 2;\nFinSubProceso\n\nAlgoritmo Tres\n  z <- 3;\nFinAlgoritmo\n";
    let mut session = DocumentSession::new(initial.to_owned(), Profile::Spanish, true);
    let edited = "SubProceso Uno()\n  x <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  y <- 20;\nFinSubProceso\n\nAlgoritmo Tres\n  z <- 3;\nFinAlgoritmo\n";
    let report = session.apply_edit(edited.to_owned());
    assert_eq!(report.reused_count, 2);
    assert_eq!(report.reanalyzed_count, 1);
    assert!(!report.signature_invalidated);
}

#[test]
fn invalidates_signatures_on_parameter_change() {
    let initial =
        "SubProceso Sumar(a)\nFinSubProceso\n\nAlgoritmo Principal\n  Sumar(1, 2);\nFinAlgoritmo\n";
    let mut session = DocumentSession::new(initial.to_owned(), Profile::Spanish, true);
    let edited = "SubProceso Sumar(a, b)\nFinSubProceso\n\nAlgoritmo Principal\n  Sumar(1, 2);\nFinAlgoritmo\n";
    let report = session.apply_edit(edited.to_owned());
    assert!(report.signature_invalidated);
}
