use crate::tasks_agendas::{FAMILY_COUNT, SplitMix64, generate};

#[test]
fn splitmix_is_deterministic_and_seed_sensitive() {
    let mut first = SplitMix64::new(7);
    let mut second = SplitMix64::new(7);
    assert_eq!(first.advance(), second.advance());
    assert_ne!(SplitMix64::new(7).advance(), SplitMix64::new(8).advance());
}

#[test]
fn bounded_draws_stay_inside_their_range() {
    let mut random = SplitMix64::new(1);
    for _ in 0..200 {
        assert!(random.below(5) < 5);
        assert!((3..=9).contains(&random.between(3, 9)));
    }
    assert_eq!(random.below(0), 0);
    assert_eq!(random.between(4, 4), 4);
}

#[test]
fn shuffles_are_permutations() {
    let mut random = SplitMix64::new(11);
    for count in [0, 1, 2, 6] {
        let mut order = random.shuffled(count);
        order.sort_unstable();
        assert_eq!(order, (1..=count).collect::<Vec<_>>());
    }
}

#[test]
fn seeds_cycle_through_the_eight_families_and_are_reproducible() {
    for seed in 0..32 {
        let agenda = generate(seed);
        assert_eq!(agenda.family, seed % FAMILY_COUNT);
        assert_eq!(agenda.program, generate(seed).program);
    }
}

#[test]
fn effect_families_declare_a_delivery_permutation_and_gc_family_forces_collection() {
    assert!(generate(6).host.is_some());
    assert!(generate(7).gc_stress);
    assert!(generate(0).host.is_none());
}

#[test]
fn each_family_reuses_one_template_and_varies_only_its_inputs() {
    for family in 0..FAMILY_COUNT {
        let first = generate(family);
        let later = generate(family.saturating_add(FAMILY_COUNT.saturating_mul(5)));
        assert_eq!(first.program, later.program);
        assert!(!first.inputs.is_empty());
        assert!(
            first
                .inputs
                .iter()
                .all(|value| value.parse::<u64>().is_ok())
        );
    }
}

#[test]
fn the_templates_are_eight_distinct_programs_that_read_their_parameters() {
    let programs: std::collections::BTreeSet<String> = (0..FAMILY_COUNT)
        .map(|seed| generate(seed).program)
        .collect();
    assert_eq!(programs.len(), 8);
    assert!(programs.iter().all(|program| program.contains("Leer ")));
}
