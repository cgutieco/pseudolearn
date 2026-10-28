use crate::pg_tasks_campaign::check_seed;

#[test]
fn every_family_matches_its_derived_expectation_live_repeated_and_replayed() {
    for seed in 0..16 {
        assert_eq!(check_seed(seed), Vec::<String>::new(), "seed {seed}");
    }
}

#[test]
fn collect_rejects_malformed_arguments() {
    assert!(crate::pg_tasks_campaign::collect(&[]).is_err());
    let bad = ["target/none".to_owned(), "x".to_owned(), "2".to_owned()];
    assert!(crate::pg_tasks_campaign::collect(&bad).is_err());
}
