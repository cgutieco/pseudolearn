use pseudolearn_bytecode::compile_text;
use pseudolearn_timeline::{
    BLOCK_WORDS, CostScheduler, SchedulerOptions, ShadowHeap, ThinningManager, UndoSegment,
    capture_checkpoint, fuse_undo_segments, restore_checkpoint,
};
use pseudolearn_vm::{Fuel, RunOptions, create_machine, load};

fn build_program(source_text: &str) -> Option<pseudolearn_vm::LoadedProgram> {
    let bytecode = compile_text(source_text).ok()?;
    load(&bytecode).ok()
}

#[test]
fn restore_checkpoint_reproduces_bit_for_bit_state() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 100\n  %1 = const.i64 200\n  return %1\n}\n";
    let program = build_program(source);
    assert!(program.is_some());
    let Some(loaded_program) = program else {
        return;
    };
    let machine_result = create_machine(&loaded_program, Fuel::unlimited(), RunOptions::default());
    assert!(machine_result.is_ok());
    let Ok(mut machine) = machine_result else {
        return;
    };
    let mut shadow = ShadowHeap::new();
    let checkpoint = capture_checkpoint(&machine, 0, &mut shadow);

    let _ = machine.step_instruction();
    let _ = machine.step_instruction();

    let restore_result = restore_checkpoint(&mut machine, &checkpoint);
    assert!(restore_result.is_ok());

    let state_after_restore = machine.capture_machine_state();
    assert_eq!(
        state_after_restore.cursor_pc,
        checkpoint.machine_state.cursor_pc
    );
    assert_eq!(
        state_after_restore.scalars,
        checkpoint.machine_state.scalars
    );
}

#[test]
fn fuse_undo_segments_preserves_older_content_for_shared_blocks() {
    let mut older_segment = UndoSegment::new();
    let older_block = vec![111u64; BLOCK_WORDS];
    older_segment.blocks.insert(0, older_block.clone());

    let mut newer_segment = UndoSegment::new();
    let newer_block = vec![999u64; BLOCK_WORDS];
    newer_segment.blocks.insert(0, newer_block);
    let second_block = vec![222u64; BLOCK_WORDS];
    newer_segment.blocks.insert(1, second_block.clone());

    let fused = fuse_undo_segments(&older_segment, &newer_segment);
    assert_eq!(fused.changed_blocks_count(), 2);
    let block_zero = fused.blocks.get(&0);
    assert_eq!(block_zero, Some(&older_block));

    let block_one = fused.blocks.get(&1);
    assert_eq!(block_one, Some(&second_block));
}

#[test]
fn cost_scheduler_calculates_distance_proportional_to_state_size() {
    let options = SchedulerOptions {
        minimum_distance: 100,
        kappa_factor: 2,
    };
    let mut scheduler = CostScheduler::new(options);
    assert!(!scheduler.should_checkpoint(50));
    assert!(scheduler.should_checkpoint(100));

    scheduler.record_checkpoint(100, 200);
    assert_eq!(scheduler.last_checkpoint_statements, 100);
    assert_eq!(scheduler.next_checkpoint_statements, 500);
    assert!(!scheduler.should_checkpoint(499));
    assert!(scheduler.should_checkpoint(500));
}

#[test]
fn thinning_manager_advances_declared_horizon_and_respects_budget() {
    let mut manager = ThinningManager::new(4);
    let machine_state = pseudolearn_vm::MachineStateRecord {
        cursor_pc: 0,
        cursor_scalar_base: 0,
        cursor_reference_base: 0,
        current_function_index: 0,
        frames: Vec::new(),
        scalar_watermark: 0,
        reference_watermark: 0,
        scalars: Vec::new(),
        references: Vec::new(),
        defined: Vec::new(),
        cells: Vec::new(),
        random: pseudolearn_runtime::RandomState::seeded(0),
        arena_used: 0,
        output_length: 0,
        input_index: 0,
        statements_executed: 0,
        polls_executed: 0,
        event_count: 0,
        heap_used: 0,
        heap_ordinal: 0,
        heap_allocated_cells: 0,
        heap_live_cells: 0,
    };

    for index in 0..10 {
        let checkpoint = pseudolearn_timeline::Checkpoint {
            event_index: index,
            statement_index: u64::try_from(index).unwrap_or(0),
            machine_state: machine_state.clone(),
            heap_words: Vec::new(),
            undo_segment: UndoSegment::new(),
        };
        manager.push_checkpoint(checkpoint);
    }

    assert!(manager.checkpoints_count() <= 4);
    assert!(manager.horizon() > 0);
}
