use pseudolearn_lexicon::Profile;
use pseudolearn_service::edit_probe::{identity_stable, unit_local_edit};
use pseudolearn_service::{IdentityCheck, Position, Range, TextEdit, compute_node_identities};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

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

fn identities(text: &str) -> Vec<pseudolearn_service::SyntaxNodeId> {
    let source = SourceText::new(text.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    compute_node_identities(&tree, &source)
        .into_iter()
        .map(|(id, _)| id)
        .collect()
}

const NEIGHBOURS: &str = "SubProceso Previo()\nFinSubProceso\n\nAlgoritmo Principal\n  x <- 1;\nFinAlgoritmo\n\nSubProceso Posterior()\nFinSubProceso\n";

#[test]
fn editing_a_unit_keeps_the_identities_of_its_neighbours() {
    let change = edit((5, 3), (5, 9), "x <- 2;\n  w <- 3;");
    assert!(identity_stable(
        NEIGHBOURS,
        &change,
        IdentityCheck::NeighbourUnits,
        Profile::Spanish
    ));
}

#[test]
fn appending_to_a_block_keeps_previous_statements() {
    let code = "Algoritmo Principal\n  Si x > 0 Entonces\n    Escribir x;\n  FinSi\nFinAlgoritmo\n";
    let change = edit((4, 1), (4, 1), "    Escribir 2;\n");
    assert!(identity_stable(
        code,
        &change,
        IdentityCheck::PreviousStatements,
        Profile::Spanish
    ));
}

#[test]
fn comments_do_not_change_any_semantic_node_identity() {
    let code = "Algoritmo Principal\n  x <- 1;\nFinAlgoritmo\n";
    let change = edit((2, 1), (2, 1), "  // comentario\n");
    assert!(identity_stable(
        code,
        &change,
        IdentityCheck::SemanticNodes,
        Profile::Spanish
    ));
}

#[test]
fn renaming_a_unit_changes_only_its_own_identities() {
    let code = "SubProceso Uno()\nFinSubProceso\n\nSubProceso Dos()\nFinSubProceso\n";
    let change = edit((1, 12), (1, 15), "Renombrado");
    assert!(identity_stable(
        code,
        &change,
        IdentityCheck::NeighbourUnits,
        Profile::Spanish
    ));
    assert!(!identity_stable(
        code,
        &change,
        IdentityCheck::SemanticNodes,
        Profile::Spanish
    ));
}

#[test]
fn inserting_a_statement_before_a_sibling_shifts_the_sibling() {
    let code = "Algoritmo Principal\n  x <- 1;\n  w <- 2;\nFinAlgoritmo\n";
    let before = identities(code);
    let after =
        identities("Algoritmo Principal\n  Escribir 0;\n  x <- 1;\n  w <- 2;\nFinAlgoritmo\n");
    assert_ne!(before, after);
}

#[test]
fn duplicate_unit_names_get_distinct_identities() {
    let ids = identities("SubProceso Igual()\nFinSubProceso\nSubProceso Igual()\nFinSubProceso\n");
    let mut roots: Vec<_> = ids
        .iter()
        .filter(|id| id.structural_path.len() == 1)
        .collect();
    roots.sort();
    roots.dedup();
    assert_eq!(roots.len(), 2);
}

#[test]
fn local_edits_in_any_unit_never_disturb_other_units() -> Result<(), String> {
    for seed in 0..50u64 {
        let change = unit_local_edit(NEIGHBOURS, Profile::Spanish, seed)
            .ok_or("expected an applicable edit")?;
        assert!(
            identity_stable(
                NEIGHBOURS,
                &change,
                IdentityCheck::NeighbourUnits,
                Profile::Spanish
            ),
            "seed {seed}"
        );
    }
    Ok(())
}

#[test]
fn programs_with_syntax_errors_have_no_local_edit() {
    assert!(
        unit_local_edit("Algoritmo A\n  Si x >\nFinAlgoritmo\n", Profile::Spanish, 1).is_none()
    );
}
