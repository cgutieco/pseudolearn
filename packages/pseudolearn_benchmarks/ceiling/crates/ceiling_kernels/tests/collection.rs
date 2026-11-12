use ceiling_kernels::collection::{CollectionMachine, Collector, run};
use ceiling_kernels::machine::{Calls, Handle, Heap, Shape, Trap};

const COLLECTORS: [Collector; 3] = [
    Collector::SizeClasses,
    Collector::Lines,
    Collector::ReferenceCounts,
];

#[test]
fn collectors_preserve_churn_under_forced_reclamation() {
    for collector in COLLECTORS {
        for forced in [false, true] {
            let result = run("list-churn", 256, collector, forced);
            assert!(
                result
                    .as_ref()
                    .is_ok_and(|(output, statistics)| output == "256"
                        && statistics.collections > 0
                        && !statistics.changed_blocks.is_empty())
            );
        }
    }
}

#[test]
fn collectors_preserve_recursive_storage_and_empty_workloads() {
    for collector in COLLECTORS {
        for (kernel, size, expected) in [("storage-deep", 4, "85"), ("list-churn", 0, "0")] {
            assert!(run(kernel, size, collector, true).is_ok_and(|result| result.0 == expected));
        }
        assert!(run("storage", 4, collector, true).is_ok_and(|result| result.0 == "85"));
    }
}

#[test]
fn collectors_release_cycles_and_preserve_live_links() {
    for collector in COLLECTORS {
        let mut machine = CollectionMachine::new(collector, false);
        assert_eq!(machine.enter(&[], &[]), Ok(()));
        let first = machine.object(Shape { links: 1, words: 0 });
        assert!(first.is_ok());
        let first = first.unwrap_or(Handle(0));
        assert_eq!(machine.set_link(first, 0, first), Ok(()));
        assert_eq!(machine.collect(), Ok(()));
        assert_eq!(machine.link(first, 0), Ok(first));
        machine.leave();
        assert_eq!(machine.collect(), Ok(()));
        assert_eq!(machine.link(first, 0), Err(Trap::InvalidHandle));
    }
}

#[test]
fn collectors_reject_negative_sizes_and_invalid_accesses() {
    for collector in COLLECTORS {
        let mut machine = CollectionMachine::new(collector, true);
        assert_eq!(machine.array(-1), Err(Trap::NegativeSize));
        let array = machine.array(0).unwrap_or(Handle(0));
        assert_eq!(machine.read(array, 0), Err(Trap::IndexOutOfRange));
        assert_eq!(machine.read(Handle(u32::MAX), 0), Err(Trap::InvalidHandle));
    }
}
