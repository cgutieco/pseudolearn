use ceiling_kernels::card_recording::CardRecording;
use ceiling_kernels::differential::Recording;
use ceiling_kernels::frame_banks::FrameBanks;

#[test]
fn dirty_cards_preserve_old_blocks_and_reset_independently() {
    let mut recording = CardRecording::default();
    let banks = FrameBanks::default();
    recording.capture(&[7; 100], &banks, 0);
    recording.written(75);
    recording.capture(&[9; 100], &banks, 1);
    let point = recording.differential.points.back();
    assert!(point.is_some_and(|point| point.undo.len() == 1));
    if let Some(point) = point {
        assert_eq!(point.undo.first().map(|block| block.0), Some(64));
    }
    recording.reset();
    assert!(recording.differential.shadow.is_empty());
    assert_eq!(recording.taken(), 2);
}
