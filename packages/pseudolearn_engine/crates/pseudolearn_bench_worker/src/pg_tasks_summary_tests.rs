use crate::pg_tasks_agendas::generate;
use crate::pg_tasks_summary::Summary;

#[test]
fn empty_summary_has_no_totals_or_divergences() {
    let summary = Summary::default();
    assert_eq!(summary.total(), 0);
    assert!(summary.divergent_seeds().is_empty());
}

#[test]
fn recording_counts_families_and_keeps_divergent_seeds() {
    let mut summary = Summary::default();
    summary.record(&generate(0), Vec::new());
    summary.record(&generate(8), Vec::new());
    summary.record(&generate(3), vec!["output differs".to_owned()]);
    assert_eq!(summary.total(), 3);
    assert_eq!(summary.divergent_seeds(), vec![3]);
    assert_eq!(
        summary.document().pointer("/per_family/0"),
        Some(&serde_json::json!(2))
    );
}
