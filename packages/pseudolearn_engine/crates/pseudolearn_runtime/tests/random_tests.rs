use pseudolearn_runtime::RandomState;

#[test]
fn random_state_round_trip_preserves_every_next_output() {
    for seed in [0, 42, -1, i64::MIN, i64::MAX] {
        let mut state = RandomState::seeded(seed);
        assert_ne!(state.words, [0; 4]);
        let saved = state;
        let expected = state.next_word();
        let mut restored = RandomState { words: saved.words };
        assert_eq!(restored.next_word(), expected);
        for _ in 0..1000 {
            assert!((0.0..1.0).contains(&restored.next_real()));
        }
    }
}

#[test]
fn bounded_integers_stay_inside_their_interval() {
    let mut state = RandomState::seeded(7);
    for bound in [1_u64, 2, 6, 1000, u64::MAX] {
        for _ in 0..500 {
            assert!(state.next_below(bound).is_some_and(|value| value < bound));
        }
    }
    for (low, high) in [(5, 5), (-2, 2), (i64::MIN, i64::MAX), (i64::MAX - 1, i64::MAX)] {
        for _ in 0..500 {
            assert!(
                state
                    .next_between(low, high)
                    .is_some_and(|value| (low..=high).contains(&value))
            );
        }
    }
}

#[test]
fn bounded_integers_reject_empty_intervals() {
    let mut state = RandomState::seeded(0);
    assert_eq!(state.next_below(0), None);
    assert_eq!(state.next_between(3, 1), None);
    assert_eq!(state.next_between(i64::MAX, i64::MIN), None);
}

#[test]
fn a_single_value_interval_always_returns_that_value() {
    let mut state = RandomState::seeded(-1);
    for _ in 0..100 {
        assert_eq!(state.next_below(1), Some(0));
        assert_eq!(state.next_between(-4, -4), Some(-4));
    }
}

#[test]
fn small_bounds_reach_every_value() {
    let mut state = RandomState::seeded(42);
    let mut seen = [false; 6];
    for _ in 0..600 {
        if let Some(slot) = state
            .next_below(6)
            .and_then(|value| usize::try_from(value).ok())
            .and_then(|index| seen.get_mut(index))
        {
            *slot = true;
        }
    }
    assert!(seen.iter().all(|reached| *reached));
}
