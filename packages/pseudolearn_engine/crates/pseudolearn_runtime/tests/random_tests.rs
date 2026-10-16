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
