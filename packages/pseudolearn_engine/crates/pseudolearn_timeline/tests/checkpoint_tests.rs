use pseudolearn_bytecode::compile_text;
use pseudolearn_runtime::{Handle, ValueKind, new_array, write_element};
use pseudolearn_timeline::{
    CheckpointStore, CostScheduler, SchedulerOptions, StoreBudget, TimelineError,
};
use pseudolearn_vm::{
    Fuel, LoadedProgram, Machine, MachineImage, RunOptions, create_machine, load,
    snapshot_machine_lean,
};

fn program() -> Result<LoadedProgram, String> {
    let mut source = String::from("module P es\nfunc @main() -> unit {\nb0() mass 12:\n");
    for line in 2_usize..14 {
        let register = line.saturating_sub(2);
        source.push_str(&format!(
            "  stmt.enter @{line}:1-{line}:5\n  %{register} = const.i64 {line}\n  out.write %{register}, newline @{line}:1-{line}:5\n  stmt.exit @{line}:1-{line}:5\n"
        ));
    }
    source.push_str("  return\n}\n");
    let bytecode = compile_text(&source).map_err(|error| format!("{error:?}"))?;
    load(&bytecode).map_err(|error| format!("{error:?}"))
}

fn machine(program: &LoadedProgram) -> Result<Machine<'_>, String> {
    create_machine(program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))
}

fn mutate_heap(
    machine: &mut Machine<'_>,
    step: usize,
    arrays: &mut Vec<Handle>,
) -> Result<(), String> {
    let heap = machine.heap_mut();
    if step.is_multiple_of(3) {
        let handle = new_array(heap, ValueKind::Integer, &[200], arrays.as_slice())
            .map_err(|error| format!("{error:?}"))?;
        arrays.push(handle);
    } else if let Some(handle) = arrays.first() {
        write_element(heap, *handle, (&[1], u64::try_from(step).unwrap_or(0)))
            .map_err(|error| format!("{error:?}"))?;
    }
    Ok(())
}

fn record_every_step(
    store: &mut CheckpointStore,
    machine: &mut Machine<'_>,
) -> Result<Vec<(usize, MachineImage)>, String> {
    let mut saved = Vec::new();
    let mut event_index = 0;
    let mut arrays = Vec::new();
    while machine.step_instruction().is_none() {
        mutate_heap(machine, event_index, &mut arrays)?;
        store
            .record(machine, event_index)
            .map_err(|error| error.to_string())?;
        saved.push((event_index, snapshot_machine_lean(machine)));
        event_index = event_index.saturating_add(1);
    }
    Ok(saved)
}

#[test]
fn every_retained_checkpoint_reproduces_its_saved_image_bit_for_bit() -> Result<(), String> {
    let program = program()?;
    let mut machine = machine(&program)?;
    let mut store = CheckpointStore::new(100);
    let saved = record_every_step(&mut store, &mut machine)?;
    assert!(saved.len() > 10);
    for (event_index, expected) in &saved {
        let (image, restored_event) = store
            .image_at(*event_index)
            .map_err(|error| error.to_string())?;
        assert_eq!(restored_event, *event_index);
        assert_eq!(&image, expected);
    }
    Ok(())
}

#[test]
fn thinning_fuses_segments_without_changing_reconstruction() -> Result<(), String> {
    let program = program()?;
    let mut machine = machine(&program)?;
    let mut store = CheckpointStore::new(4);
    let saved = record_every_step(&mut store, &mut machine)?;
    assert_eq!(store.stats().checkpoints, 4);
    let mut verified = 0;
    for (event_index, expected) in &saved {
        let (image, restored_event) = store
            .image_at(*event_index)
            .map_err(|error| error.to_string())?;
        if restored_event == *event_index {
            assert_eq!(&image, expected);
            verified += 1;
        }
    }
    assert_eq!(verified, 4);
    Ok(())
}

#[test]
fn slot_budget_forces_thinning_and_advances_horizon_when_exhausted() -> Result<(), String> {
    let program = program()?;
    let mut machine = machine(&program)?;
    let mut store = CheckpointStore::with_budget(StoreBudget {
        max_checkpoints: 100,
        max_retained_slots: 0,
    });
    record_every_step(&mut store, &mut machine)?;
    assert_eq!(store.stats().checkpoints, 1);
    assert!(store.stats().horizon > 0);
    assert_eq!(store.stats().retained_slots, 0);
    Ok(())
}

#[test]
fn capture_cost_counts_only_changed_regions() -> Result<(), String> {
    let program = program()?;
    let mut machine = machine(&program)?;
    let mut store = CheckpointStore::new(100);
    let _ = machine.step_instruction();
    store
        .record(&machine, 0)
        .map_err(|error| error.to_string())?;
    assert_eq!(store.stats().last_cost.copied_slots, 0);
    let handle = new_array(machine.heap_mut(), ValueKind::Integer, &[20_000], &[])
        .map_err(|error| format!("{error:?}"))?;
    store
        .record(&machine, 1)
        .map_err(|error| error.to_string())?;
    assert!(store.stats().last_cost.copied_slots < 500);
    write_element(machine.heap_mut(), handle, (&[7], 99)).map_err(|error| format!("{error:?}"))?;
    store
        .record(&machine, 2)
        .map_err(|error| error.to_string())?;
    let cost = store.stats().last_cost;
    assert!(cost.copied_slots > 0);
    assert!(cost.copied_slots < 500);
    assert!(store.stats().live_words > 20_000);
    Ok(())
}

#[test]
fn image_before_the_first_checkpoint_is_rejected() -> Result<(), String> {
    let program = program()?;
    let mut machine = machine(&program)?;
    let mut store = CheckpointStore::new(4);
    assert!(matches!(
        store.image_at(0),
        Err(TimelineError::ReplayFailure)
    ));
    let _ = machine.step_instruction();
    store
        .record(&machine, 5)
        .map_err(|error| error.to_string())?;
    assert!(store.image_at(4).is_err());
    assert!(store.image_at(5).is_ok());
    Ok(())
}

#[test]
fn cost_scheduler_calculates_distance_proportional_to_state_size() {
    let options = SchedulerOptions {
        minimum_distance: 100,
        kappa_factor: 2,
        maximum_distance: u64::MAX,
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
fn cost_scheduler_caps_the_proportional_distance_but_never_below_the_minimum() {
    let options = SchedulerOptions {
        minimum_distance: 100,
        kappa_factor: 16,
        maximum_distance: 1_000,
    };
    let mut scheduler = CostScheduler::new(options);
    scheduler.record_checkpoint(0, 1_000_000);
    assert_eq!(scheduler.next_checkpoint_statements, 1_000);
    let inverted = SchedulerOptions {
        minimum_distance: 500,
        kappa_factor: 1,
        maximum_distance: 10,
    };
    let mut floor = CostScheduler::new(inverted);
    floor.record_checkpoint(0, 1_000_000);
    assert_eq!(floor.next_checkpoint_statements, 500);
}
