use std::collections::BTreeMap;

use pseudolearn_runtime::{
    BLOCK_WORDS, BlockDelta, DeltaError, Heap, MapDelta, MemoryOptions, TailDelta, ValueKind,
    advance_heap, compose_heap_deltas, heap_used_words, heap_words, live_allocation_handles,
    new_array, revert_heap, write_element,
};

fn words(count: usize, seed: u64) -> Vec<u64> {
    (0..count)
        .map(|offset| seed.wrapping_add(u64::try_from(offset).unwrap_or(0)))
        .collect()
}

#[test]
fn block_delta_records_only_changed_blocks_and_reverts_exactly() -> Result<(), DeltaError> {
    let original = words(BLOCK_WORDS.saturating_mul(4), 1);
    let mut live = original.clone();
    if let Some(word) = live.get_mut(BLOCK_WORDS.saturating_add(3)) {
        *word = 9_999;
    }
    let mut tip = original.clone();
    let delta = BlockDelta::advance(&mut tip, &live);
    assert_eq!(tip, live);
    assert_eq!(delta.blocks.len(), 1);
    assert_eq!(delta.copied_slots(), BLOCK_WORDS);
    let mut restored = live.clone();
    delta.revert(&mut restored)?;
    assert_eq!(restored, original);
    Ok(())
}

#[test]
fn block_delta_handles_growth_shrink_and_empty_vectors() -> Result<(), DeltaError> {
    for (before, after) in [(0, 70), (70, 0), (70, 130), (130, 5), (0, 0), (64, 64)] {
        let original = words(before, 7);
        let live = words(after, 100);
        let mut tip = original.clone();
        let delta = BlockDelta::advance(&mut tip, &live);
        assert_eq!(tip, live);
        let mut restored = live.clone();
        delta.revert(&mut restored)?;
        assert_eq!(restored, original);
    }
    Ok(())
}

#[test]
fn dirty_block_delta_skips_clean_prefix_and_restores_truncated_tail() -> Result<(), DeltaError> {
    let original = words(BLOCK_WORDS.saturating_mul(16), 1);
    let mut extended = original.clone();
    if let Some(word) = extended.get_mut(1_000) {
        *word = 9_999;
    }
    let mut tip = original.clone();
    let delta = BlockDelta::advance_from(&mut tip, &extended, 1_000);
    assert_eq!(delta.blocks.len(), 1);
    assert_eq!(delta.copied_slots(), BLOCK_WORDS);
    let mut restored = extended;
    delta.revert(&mut restored)?;
    assert_eq!(restored, original);

    let mut tip = original.clone();
    let truncated = original.get(..900).unwrap_or_default().to_vec();
    let delta = BlockDelta::advance_from(&mut tip, &truncated, 900);
    assert_eq!(tip, truncated);
    assert_eq!(delta.copied_slots(), BLOCK_WORDS.saturating_mul(2));
    delta.revert(&mut tip)?;
    assert_eq!(tip, original);
    Ok(())
}

#[test]
fn block_delta_revert_without_fill_content_is_rejected() {
    let delta: BlockDelta<u64> = BlockDelta::empty(10);
    let mut current = Vec::new();
    assert_eq!(delta.revert(&mut current), Err(DeltaError::MissingFill));
}

#[test]
fn composed_block_deltas_equal_two_step_revert() -> Result<(), DeltaError> {
    let first_state = words(200, 1);
    let second_state = words(150, 50);
    let third_state = words(260, 90);
    let mut tip = first_state.clone();
    let older = BlockDelta::advance(&mut tip, &second_state);
    let newer = BlockDelta::advance(&mut tip, &third_state);
    let fused = BlockDelta::compose(&newer, &older);
    let mut restored = third_state.clone();
    fused.revert(&mut restored)?;
    assert_eq!(restored, first_state);
    Ok(())
}

#[test]
fn tail_delta_truncates_appends_and_keeps_replaced_content() {
    let mut tip = String::from("abc");
    let append = TailDelta::advance(&mut tip, &String::from("abcdef"));
    assert_eq!(append.copied_slots(), 0);
    let mut current = String::from("abcdef");
    append.revert(&mut current);
    assert_eq!(current, "abc");

    let mut compacted_tip = String::from("abcdef");
    let rewritten = TailDelta::advance(&mut compacted_tip, &String::from("xyz"));
    assert_eq!(compacted_tip, "xyz");
    assert_eq!(rewritten.copied_slots(), 6);
    let mut after = String::from("xyz");
    rewritten.revert(&mut after);
    assert_eq!(after, "abcdef");
}

#[test]
fn composed_tail_deltas_cover_append_then_rewrite() {
    let mut tip = vec![1, 2, 3];
    let older = TailDelta::advance(&mut tip, &vec![1, 2, 3, 4]);
    let newer = TailDelta::advance(&mut tip, &vec![9, 9]);
    let fused = TailDelta::compose(&newer, &older);
    let mut current = vec![9, 9];
    fused.revert(&mut current);
    assert_eq!(current, vec![1, 2, 3]);
}

#[test]
fn map_delta_restores_changed_added_and_removed_entries() {
    let mut tip: BTreeMap<u32, u32> = BTreeMap::from([(1, 10), (2, 20), (3, 30)]);
    let original = tip.clone();
    let live = BTreeMap::from([(1, 10), (2, 99), (4, 40)]);
    let delta = MapDelta::advance(&mut tip, &live);
    assert_eq!(tip, live);
    assert_eq!(delta.copied_entries(), 3);
    let mut restored = live.clone();
    delta.revert(&mut restored);
    assert_eq!(restored, original);
}

#[test]
fn heap_delta_round_trips_and_composes() -> Result<(), String> {
    let mut live = Heap::new(MemoryOptions::default());
    let mut tip = live.clone();
    let first = tip.clone();
    let handle = new_array(&mut live, ValueKind::Integer, &[300], &[])
        .map_err(|error| format!("{error:?}"))?;
    let second = live.clone();
    let older = advance_heap(&mut tip, &live);
    assert_eq!(tip, live);
    write_element(&mut live, handle, (&[5], 77)).map_err(|error| format!("{error:?}"))?;
    let newer = advance_heap(&mut tip, &live);
    assert!(newer.copied_slots() < 300);

    let mut stepped = live.clone();
    revert_heap(&mut stepped, &newer).map_err(|error| format!("{error:?}"))?;
    assert_eq!(stepped, second);

    let fused = compose_heap_deltas(&newer, &older);
    let mut restored = live.clone();
    revert_heap(&mut restored, &fused).map_err(|error| format!("{error:?}"))?;
    assert_eq!(restored, first);
    Ok(())
}

#[test]
fn heap_delta_reverts_block_removal_and_keeps_only_used_words() -> Result<(), String> {
    let mut live = Heap::new(MemoryOptions::default());
    let retained = new_array(&mut live, ValueKind::Integer, &[160], &[])
        .map_err(|error| format!("{error:?}"))?;
    let discarded = new_array(&mut live, ValueKind::Reference, &[32], &[retained])
        .map_err(|error| format!("{error:?}"))?;
    let before_collection = live.clone();
    live.collect(&[retained])
        .map_err(|error| format!("{error:?}"))?;
    assert!(!live_allocation_handles(&live).contains(&discarded));
    assert_eq!(heap_words(&live).len(), heap_used_words(&live));

    let mut tip = before_collection.clone();
    let delta = advance_heap(&mut tip, &live);
    assert_eq!(tip, live);
    let mut restored = live.clone();
    revert_heap(&mut restored, &delta).map_err(|error| format!("{error:?}"))?;
    assert_eq!(restored, before_collection);
    assert!(live_allocation_handles(&restored).contains(&discarded));
    Ok(())
}
