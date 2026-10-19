use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, HighlightKind, Position, Range, SymbolCategory};

fn session_at(marked: &str) -> (DocumentSession, Position) {
    let (clean, position) = split_cursor(marked);
    (
        DocumentSession::new(clean, Profile::Spanish, true),
        position,
    )
}

fn range(start: (u32, u32), end: (u32, u32)) -> Range {
    Range {
        start: Position {
            line: start.0,
            column: start.1,
        },
        end: Position {
            line: end.0,
            column: end.1,
        },
    }
}

#[test]
fn locates_the_exact_name_of_a_variable_declaration() {
    let (session, position) = session_at(
        "Algoritmo Principal\n  Definir total Como Entero;\n  total <- 10;\n  Escribir to|tal;\nFinAlgoritmo\n",
    );
    assert_eq!(
        session.queries().definition(position),
        Some(range((2, 11), (2, 16)))
    );
}

#[test]
fn locates_the_name_of_methods_called_through_an_instance() {
    let (session, position) = session_at(
        "Clase Punto\n  Metodo Mover()\n  FinMetodo\nFinClase\n\nAlgoritmo Principal\n  Definir p Como Punto;\n  p.Mo|ver();\nFinAlgoritmo\n",
    );
    assert_eq!(
        session.queries().definition(position),
        Some(range((2, 10), (2, 15)))
    );
}

#[test]
fn locates_the_name_of_subroutines_from_their_calls() {
    let (session, position) = session_at(
        "SubProceso Saludar()\nFinSubProceso\n\nAlgoritmo Principal\n  Salu|dar();\nFinAlgoritmo\n",
    );
    assert_eq!(
        session.queries().definition(position),
        Some(range((1, 12), (1, 19)))
    );
}

#[test]
fn separates_homonymous_locals_of_different_subroutines() {
    let (session, position) = session_at(
        "SubProceso Uno()\n  Definir i Como Entero;\n  |i <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  Definir i Como Entero;\n  i <- 2;\nFinSubProceso\n",
    );
    assert_eq!(
        session.queries().references(position),
        vec![range((2, 11), (2, 12)), range((3, 3), (3, 4))]
    );
}

#[test]
fn classifies_reads_and_writes_in_highlights() {
    let (session, position) =
        session_at("Algoritmo Principal\n  |x <- 1;\n  Escribir x;\nFinAlgoritmo\n");
    let highlights = session.queries().highlights(position);
    assert_eq!(highlights.len(), 2);
    assert_eq!(
        highlights.first().map(|entry| entry.range),
        Some(range((2, 3), (2, 4)))
    );
    assert_eq!(
        highlights.first().map(|entry| entry.kind),
        Some(HighlightKind::Write)
    );
    assert_eq!(
        highlights.get(1).map(|entry| entry.range),
        Some(range((3, 12), (3, 13)))
    );
    assert_eq!(
        highlights.get(1).map(|entry| entry.kind),
        Some(HighlightKind::Read)
    );
}

#[test]
fn returns_nothing_away_from_symbols() {
    let (session, position) = session_at("Algoritmo Principal\n  Escribir 1|;\nFinAlgoritmo\n");
    assert_eq!(session.queries().definition(position), None);
    assert!(session.queries().references(position).is_empty());
    assert!(session.queries().highlights(position).is_empty());
    let (empty, origin) = session_at("|");
    assert_eq!(empty.queries().definition(origin), None);
}

#[test]
fn counts_columns_in_characters_for_accented_identifiers() {
    let (session, position) = session_at(
        "Algoritmo Principal\n  Definir año Como Entero;\n  año <- 1;\n  Escribir a|ño;\nFinAlgoritmo\n",
    );
    assert_eq!(
        session.queries().definition(position),
        Some(range((2, 11), (2, 14)))
    );
    assert_eq!(session.queries().references(position).len(), 3);
}

#[test]
fn lists_document_symbols_with_their_containers() {
    let session = DocumentSession::new(
        "Clase Punto\n  Definir x Como Entero;\n  Metodo Mover()\n  FinMetodo\nFinClase\nSubProceso Util()\nFinSubProceso\nAlgoritmo Principal\nFinAlgoritmo\n"
            .to_owned(),
        Profile::Spanish,
        true,
    );
    let symbols = session.queries().symbols();
    let names: Vec<(&str, SymbolCategory)> = symbols
        .iter()
        .map(|entry| (entry.name.as_str(), entry.category))
        .collect();
    assert!(names.contains(&("Punto", SymbolCategory::Class)));
    assert!(names.contains(&("x", SymbolCategory::Field)));
    assert!(names.contains(&("Mover", SymbolCategory::Method)));
    assert!(names.contains(&("Util", SymbolCategory::Function)));
    let mover = symbols.iter().find(|entry| entry.name == "Mover");
    assert_eq!(
        mover.and_then(|entry| entry.container.as_deref()),
        Some("Punto")
    );
}
