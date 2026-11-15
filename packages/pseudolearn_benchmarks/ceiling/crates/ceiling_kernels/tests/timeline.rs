use ceiling_kernels::paged_heap::PagedHeap;
use ceiling_kernels::timeline::{ExecutionState, Timeline};
use std::time::Duration;

#[test]
fn zero_interval_records_after_clock_poll() {
    let mut heap = PagedHeap::default();
    let mut timeline = Timeline::new(Duration::ZERO);
    for _ in 0..4096 {
        timeline.tick(
            &mut heap,
            ExecutionState {
                scalars: &[42],
                references: &[7],
                depth: 1,
                ordinal: 4,
            },
        );
    }
    assert_eq!(timeline.taken(), 1);
    let checkpoint = timeline.latest().ok_or("Missing checkpoint");
    assert!(checkpoint.is_ok());
    if let Ok(checkpoint) = checkpoint {
        assert_eq!(checkpoint.scalars, vec![42]);
        assert_eq!(checkpoint.references, vec![7]);
        assert_eq!(checkpoint.ordinal, 4);
        assert_eq!(checkpoint.depth, 1);
        assert!(checkpoint.heap.pages.is_empty());
    }
}
