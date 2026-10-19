use pseudolearn_lexicon::Profile;
use pseudolearn_service::{DocumentSession, Position};

#[test]
fn locates_definition_range() {
    let code = "Algoritmo Principal\n  Definir total Como Entero;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n";
    let session = DocumentSession::new(code.to_owned(), Profile::Spanish, true);
    let definition = session.definition(Position {
        line: 4,
        column: 13,
    });
    assert!(definition.is_some());
    let Some(range) = definition else {
        return;
    };
    assert_eq!(range.start.line, 2);
    assert_eq!(range.start.column, 11);
}

#[test]
fn locates_all_references() {
    let code = "SubProceso Uno()\n  Definir i Como Entero;\n  i <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  Definir i Como Entero;\n  i <- 2;\nFinSubProceso\n";
    let session = DocumentSession::new(code.to_owned(), Profile::Spanish, true);
    let references = session.references(Position { line: 3, column: 3 });
    assert_eq!(references.len(), 2);
    assert_eq!(
        references.first().map(|reference| reference.start.line),
        Some(2)
    );
    assert_eq!(
        references.get(1).map(|reference| reference.start.line),
        Some(3)
    );
}
