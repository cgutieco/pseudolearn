use pseudolearn_lexicon::Profile;
use pseudolearn_service::{DocumentSession, Position};

#[test]
fn provides_hover_type_and_inferred_status() {
    let code =
        "Algoritmo Principal\n  Definir contador Como Entero;\n  contador <- 1;\nFinAlgoritmo\n";
    let session = DocumentSession::new(code.to_owned(), Profile::Spanish, true);
    let hover_outcome = session.hover(Position { line: 3, column: 5 });
    assert!(hover_outcome.is_some());
    let Some(outcome) = hover_outcome else {
        return;
    };
    assert_eq!(outcome.type_name, "Entero");
    assert!(!outcome.is_inferred);
}

#[test]
fn identifies_intrinsic_functions() {
    let code = "Algoritmo Principal\n  s <- subcadena(\"hola\", 1, 2);\nFinAlgoritmo\n";
    let session = DocumentSession::new(code.to_owned(), Profile::Spanish, true);
    let hover_outcome = session.hover(Position {
        line: 2,
        column: 10,
    });
    assert!(hover_outcome.is_some());
    let Some(outcome) = hover_outcome else {
        return;
    };
    assert!(outcome.is_intrinsic);
    assert_eq!(outcome.identifier, "subcadena");
}
