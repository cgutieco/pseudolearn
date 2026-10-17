use pseudolearn_bytecode::compile_text;
use pseudolearn_runtime::{ValueKind, allocation_ordinal, new_array, write_element};
use pseudolearn_timeline::{
    ArraySliceRange, CheckpointStore, ExecutionTimeline, SchedulerOptions, StoreBudget,
    TimelineError, VariableValue, timeline_horizon,
};
use pseudolearn_vm::{
    Fuel, RunOptions, TwinMode, create_machine, load, machine_event_count, machine_events,
    snapshot_machine,
};

fn program() -> Result<pseudolearn_vm::LoadedProgram, String> {
    let source = "module Replay es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:5\n  %0 = const.i64 37\n  out.write %0, newline @2:1-2:5\n  stmt.exit @2:1-2:5\n  return\n}\n";
    let bytecode = compile_text(source).map_err(|error| format!("{error:?}"))?;
    load(&bytecode).map_err(|error| format!("{error:?}"))
}

#[test]
fn historical_queries_restore_real_event_boundaries() -> Result<(), String> {
    let program = program()?;
    let options = RunOptions {
        twin_mode: TwinMode::Probed,
        ..Default::default()
    };
    let mut machine = create_machine(&program, Fuel::unlimited(), options.clone())
        .map_err(|error| format!("{error:?}"))?;
    let mut timeline = ExecutionTimeline::new(&program, options, SchedulerOptions::default(), 4);
    while machine.step_instruction().is_none() {
        let count = machine_events(&machine).len();
        if count > 0 {
            timeline
                .record_step(&machine, count.saturating_sub(1))
                .map_err(|error| error.to_string())?;
        }
    }
    let before = snapshot_machine(&machine);
    let earlier = timeline.query_state(0).map_err(|error| error.to_string())?;
    assert!(earlier.output_text.is_empty());
    assert_eq!(
        timeline
            .query_state(1)
            .map_err(|error| error.to_string())?
            .output_text,
        "37\n"
    );
    assert_eq!(snapshot_machine(&machine), before);
    assert_eq!(
        timeline
            .query_frames(0)
            .map_err(|error| error.to_string())?
            .len(),
        1
    );
    assert!(timeline.query_variables(0, 0).is_ok());
    assert!(matches!(
        timeline.query_variables(0, 1),
        Err(TimelineError::InvalidFrame {
            frame_position: 1,
            total_frames: 1,
        })
    ));
    Ok(())
}

#[test]
fn array_slice_queries_restore_the_requested_historical_event() -> Result<(), String> {
    let program = program()?;
    let options = RunOptions {
        twin_mode: TwinMode::Probed,
        ..Default::default()
    };
    let mut machine = create_machine(&program, Fuel::unlimited(), options.clone())
        .map_err(|error| format!("{error:?}"))?;
    let array = new_array(machine.heap_mut(), ValueKind::Integer, &[2], &[])
        .map_err(|error| format!("{error:?}"))?;
    write_element(machine.heap_mut(), array, (&[0], 7)).map_err(|error| format!("{error:?}"))?;
    let ordinal =
        allocation_ordinal(machine.heap(), array).map_err(|error| format!("{error:?}"))?;
    let scheduler = SchedulerOptions {
        minimum_distance: 0,
        kappa_factor: 0,
        maximum_distance: 0,
    };
    let mut timeline = ExecutionTimeline::new(&program, options, scheduler, 8);
    while machine_event_count(&machine) == 0 {
        if machine.step_instruction().is_some() {
            return Err("Program ended before the first event".to_owned());
        }
    }
    timeline
        .record_step(&machine, 0)
        .map_err(|error| error.to_string())?;
    write_element(machine.heap_mut(), array, (&[0], 19)).map_err(|error| format!("{error:?}"))?;
    while machine_event_count(&machine) < 2 {
        if machine.step_instruction().is_some() {
            return Err("Program ended before the second event".to_owned());
        }
    }
    timeline
        .record_step(&machine, 1)
        .map_err(|error| error.to_string())?;
    let range = ArraySliceRange {
        start_index: 0,
        slice_length: 1,
    };
    assert_eq!(
        timeline
            .query_array_slice(0, ordinal, range)
            .map_err(|error| error.to_string())?,
        vec![VariableValue::Integer(7)]
    );
    assert_eq!(
        timeline
            .query_array_slice(1, ordinal, range)
            .map_err(|error| error.to_string())?,
        vec![VariableValue::Integer(19)]
    );
    assert!(matches!(
        timeline.query_array_slice(
            1,
            ordinal.saturating_add(1),
            ArraySliceRange {
                start_index: 0,
                slice_length: 0,
            }
        ),
        Err(TimelineError::InvalidArray { .. })
    ));
    Ok(())
}

#[test]
fn evicted_horizon_rejects_older_events_and_accepts_the_exact_boundary() -> Result<(), String> {
    let source = "module Replay es\nfunc @main() -> unit {\nb0() mass 3:\n  stmt.enter @2:1-2:5\n  %0 = const.i64 1\n  stmt.exit @2:1-2:5\n  stmt.enter @3:1-3:5\n  %1 = const.i64 2\n  stmt.exit @3:1-3:5\n  stmt.enter @4:1-4:5\n  %2 = const.i64 3\n  stmt.exit @4:1-4:5\n  return\n}\n";
    let bytecode = compile_text(source).map_err(|error| format!("{error:?}"))?;
    let program = load(&bytecode).map_err(|error| format!("{error:?}"))?;
    let options = RunOptions {
        twin_mode: TwinMode::Probed,
        ..Default::default()
    };
    let mut machine = create_machine(&program, Fuel::unlimited(), options.clone())
        .map_err(|error| format!("{error:?}"))?;
    let array = new_array(machine.heap_mut(), ValueKind::Integer, &[1], &[])
        .map_err(|error| format!("{error:?}"))?;
    write_element(machine.heap_mut(), array, (&[0], 7)).map_err(|error| format!("{error:?}"))?;
    let scheduler = SchedulerOptions {
        minimum_distance: 1,
        kappa_factor: 1,
        maximum_distance: 1,
    };
    let mut timeline = ExecutionTimeline::new(&program, options, scheduler, 8);
    timeline.store = CheckpointStore::with_budget(StoreBudget {
        max_checkpoints: 8,
        max_retained_slots: 0,
    });
    let mut array_changed = false;
    while machine.step_instruction().is_none() {
        let count = machine_event_count(&machine);
        if count > 0 {
            timeline
                .record_step(&machine, count.saturating_sub(1))
                .map_err(|error| error.to_string())?;
            if !array_changed {
                write_element(machine.heap_mut(), array, (&[0], 11))
                    .map_err(|error| format!("{error:?}"))?;
                array_changed = true;
            }
        }
    }
    let horizon = timeline_horizon(&timeline);
    assert!(horizon > 0);
    assert!(matches!(
        timeline.query_state(horizon.saturating_sub(1)),
        Err(TimelineError::PastHorizon {
            requested,
            horizon: expected_horizon,
        }) if requested.saturating_add(1) == horizon && expected_horizon == horizon
    ));
    assert!(timeline.query_state(horizon).is_ok());
    Ok(())
}

#[test]
fn unreachable_events_and_false_recorded_indices_are_rejected() -> Result<(), String> {
    let program = program()?;
    let options = RunOptions {
        twin_mode: TwinMode::Probed,
        ..Default::default()
    };
    let mut machine = create_machine(&program, Fuel::unlimited(), options.clone())
        .map_err(|error| format!("{error:?}"))?;
    let mut timeline = ExecutionTimeline::new(&program, options, SchedulerOptions::default(), 4);
    assert!(timeline.record_step(&machine, 5).is_err());
    let _ = machine.step_instruction();
    timeline
        .record_step(&machine, 0)
        .map_err(|error| error.to_string())?;
    assert!(matches!(
        timeline.query_state(9),
        Err(TimelineError::FutureEvent { requested: 9, .. })
    ));
    assert!(timeline.query_state(usize::MAX).is_err());
    Ok(())
}
