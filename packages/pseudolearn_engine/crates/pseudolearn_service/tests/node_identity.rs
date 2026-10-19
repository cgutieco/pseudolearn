use pseudolearn_lexicon::Profile;
use pseudolearn_service::compute_node_identities;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn preserves_neighboring_units_identities() {
    let before = "SubProceso Previo()\nFinSubProceso\n\nAlgoritmo Principal\n  x <- 1;\nFinAlgoritmo\n\nSubProceso Posterior()\nFinSubProceso\n";
    let source_before = SourceText::new(before.to_owned());
    let (tree_before, _) = parse_source(&source_before, Profile::Spanish);
    let ids_before = compute_node_identities(&tree_before, &source_before);

    let after = "SubProceso Previo()\nFinSubProceso\n\nAlgoritmo Principal\n  x <- 2;\n  y <- 3;\nFinAlgoritmo\n\nSubProceso Posterior()\nFinSubProceso\n";
    let source_after = SourceText::new(after.to_owned());
    let (tree_after, _) = parse_source(&source_after, Profile::Spanish);
    let ids_after = compute_node_identities(&tree_after, &source_after);

    let previo_before: Vec<_> = ids_before
        .iter()
        .filter(|(id, _)| id.unit_name == "Previo")
        .collect();
    let previo_after: Vec<_> = ids_after
        .iter()
        .filter(|(id, _)| id.unit_name == "Previo")
        .collect();
    assert_eq!(previo_before.len(), previo_after.len());
    for (previous_entry, current_entry) in previo_before.iter().zip(previo_after.iter()) {
        assert_eq!(previous_entry.0, current_entry.0);
    }

    let posterior_before: Vec<_> = ids_before
        .iter()
        .filter(|(id, _)| id.unit_name == "Posterior")
        .collect();
    let posterior_after: Vec<_> = ids_after
        .iter()
        .filter(|(id, _)| id.unit_name == "Posterior")
        .collect();
    assert_eq!(posterior_before.len(), posterior_after.len());
    for (previous_entry, current_entry) in posterior_before.iter().zip(posterior_after.iter()) {
        assert_eq!(previous_entry.0, current_entry.0);
    }
}
