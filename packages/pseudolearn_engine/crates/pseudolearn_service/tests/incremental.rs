use pseudolearn_lexicon::Profile;
use pseudolearn_service::IncrementalProbe;
use pseudolearn_service::edit_probe::incremental_matches_cold;
use pseudolearn_service::{DocumentSession, Position, Range, TextEdit};

fn edit(start: (u32, u32), end: (u32, u32), text: &str) -> TextEdit {
    TextEdit {
        range: Range {
            start: Position {
                line: start.0,
                column: start.1,
            },
            end: Position {
                line: end.0,
                column: end.1,
            },
        },
        new_text: text.to_owned(),
    }
}

const THREE_UNITS: &str = "SubProceso Uno()\n  x <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  w <- 2;\nFinSubProceso\n\nAlgoritmo Tres\n  z <- 3;\nFinAlgoritmo\n";

#[test]
fn text_edits_update_the_document_like_a_cold_start() {
    let initial = "Algoritmo Principal\n  Definir x Como Entero;\nFinAlgoritmo\n";
    let mut session = DocumentSession::new(initial.to_owned(), Profile::Spanish, true);
    session.apply_text_edits(&[
        edit((3, 1), (3, 1), "  x <- \"hola\";\n"),
        edit((3, 8), (3, 14), "42"),
    ]);
    assert_eq!(
        session.text(),
        "Algoritmo Principal\n  Definir x Como Entero;\n  x <- 42;\nFinAlgoritmo\n"
    );
    assert!(session.matches_cold_analysis());
    assert!(session.diagnostics().is_empty());
}

#[test]
fn reports_which_units_keep_their_fingerprint() {
    let mut session = DocumentSession::new(THREE_UNITS.to_owned(), Profile::Spanish, true);
    let report = session.apply_text_edits(&[edit((6, 8), (6, 9), "20")]);
    assert_eq!(report.unchanged_count, 2);
    assert_eq!(report.affected_count, 1);
    assert!(!report.signature_invalidated);
}

#[test]
fn flags_signature_changes_and_new_arity_errors() {
    let initial =
        "SubProceso Sumar(a)\nFinSubProceso\n\nAlgoritmo Principal\n  Sumar(1, 2);\nFinAlgoritmo\n";
    let mut session = DocumentSession::new(initial.to_owned(), Profile::Spanish, true);
    let before = session.diagnostics().len();
    let report = session.apply_text_edits(&[edit((1, 18), (1, 20), "a, b)")]);
    assert!(report.signature_invalidated);
    assert!(session.matches_cold_analysis());
    assert!(session.diagnostics().len() <= before);
}

#[test]
fn an_identical_text_changes_nothing() {
    let mut session = DocumentSession::new(THREE_UNITS.to_owned(), Profile::Spanish, true);
    let report = session.apply_edit(THREE_UNITS.to_owned());
    assert_eq!(report.unchanged_count, 3);
    assert_eq!(report.affected_count, 0);
    assert!(!report.signature_invalidated);
}

#[test]
fn duplicate_unit_names_are_matched_by_ordinal() {
    let twins = "SubProceso Igual()\n  a <- 1;\nFinSubProceso\n\nSubProceso Igual()\n  b <- 2;\nFinSubProceso\n\nAlgoritmo Principal\nFinAlgoritmo\n";
    let mut session = DocumentSession::new(twins.to_owned(), Profile::Spanish, true);
    let report = session.apply_text_edits(&[edit((2, 8), (2, 9), "9")]);
    assert_eq!(report.affected_count, 1);
    assert_eq!(report.unchanged_count, 2);
}

#[test]
fn removed_and_added_units_invalidate_signatures() {
    let mut session = DocumentSession::new(THREE_UNITS.to_owned(), Profile::Spanish, true);
    let shorter =
        "SubProceso Uno()\n  x <- 1;\nFinSubProceso\n\nAlgoritmo Tres\n  z <- 3;\nFinAlgoritmo\n";
    let report = session.apply_edit(shorter.to_owned());
    assert!(report.signature_invalidated);
}

#[test]
fn keeps_symbols_declared_before_an_unfinished_block() {
    let incomplete = "Algoritmo Principal\n  Definir limite Como Entero;\n  limite <- 10;\n  Si limite > 0 Entonces\n";
    let session = DocumentSession::new(incomplete.to_owned(), Profile::Spanish, true);
    let names: Vec<&str> = session
        .analysis
        .symbols
        .iter()
        .map(|symbol| symbol.name.as_str())
        .collect();
    assert!(names.contains(&"limite"));
    assert!(!session.diagnostics().is_empty());
}

#[test]
fn out_of_range_edits_do_not_panic_and_still_match_cold_analysis() {
    let mut session = DocumentSession::new(THREE_UNITS.to_owned(), Profile::Spanish, true);
    session.apply_text_edits(&[edit((900, 900), (999, 999), "zzz")]);
    assert!(session.text().ends_with("zzz"));
    assert!(session.matches_cold_analysis());
}

#[test]
fn random_edit_sequences_match_cold_analysis_on_representative_programs() {
    let programs = [
        THREE_UNITS,
        "Clase Punto\n  Definir x Como Entero;\n  Metodo Mover()\n    x <- x + 1;\n  FinMetodo\nFinClase\nAlgoritmo Principal\n  Definir p Como Punto;\n  p <- Nuevo Punto();\n  p.Mover();\nFinAlgoritmo\n",
        "Algoritmo Año\n  Definir ñandú Como Entero;\n  Si ñandú > 0 Entonces\n    Escribir ñandú;\n  FinSi\nFinAlgoritmo\n",
    ];
    for (offset, program) in programs.iter().enumerate() {
        for seed in 0..20u64 {
            let seed = seed.wrapping_add(u64::try_from(offset).unwrap_or(0).wrapping_mul(1000));
            assert!(
                incremental_matches_cold(
                    program,
                    IncrementalProbe {
                        profile: Profile::Spanish,
                        strict: true,
                        seed,
                        steps: 12,
                    }
                ),
                "seed {seed}"
            );
        }
    }
}
