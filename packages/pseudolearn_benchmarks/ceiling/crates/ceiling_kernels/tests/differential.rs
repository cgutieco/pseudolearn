use ceiling_kernels::differential::{Differential, Recording};
use ceiling_kernels::frame_banks::FrameBanks;

#[test]
fn undo_restores_changed_words_and_excludes_new_allocations() {
    let mut recording = Differential::default();
    let banks = FrameBanks::default();
    let before = vec![7; 100];
    recording.capture(&before, &banks, 1);
    let mut after = before.clone();
    if let Some(word) = after.get_mut(4) {
        *word = 42;
    }
    after.extend([9; 60]);
    recording.capture(&after, &banks, 2);
    let point = recording.points.back();
    assert!(point.is_some());
    if let Some(point) = point {
        let mut restored = recording.shadow.clone();
        for (start, previous) in &point.undo {
            let ending = start.saturating_add(previous.len());
            if let Some(target) = restored.get_mut(*start..ending) {
                target.copy_from_slice(previous);
            }
        }
        restored.truncate(point.previous_top);
        assert_eq!(restored, before);
        assert_eq!(point.ordinal, 2);
    }
    for _ in 0..100 {
        recording.capture(&after, &banks, 2);
    }
    assert_eq!(recording.points.len(), 64);
    assert!(
        recording
            .points
            .back()
            .is_some_and(|point| point.undo.is_empty())
    );
}
