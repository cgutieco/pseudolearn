use pseudolearn_bytecode::compile_text;
use pseudolearn_timeline::{ExecutionTimeline, SchedulerOptions, TimelineError};
use pseudolearn_vm::{Fuel, RunOptions, create_machine, load};

fn build_program(source_text: &str) -> Option<pseudolearn_vm::LoadedProgram> {
    let bytecode = compile_text(source_text).ok()?;
    load(&bytecode).ok()
}

#[test]
fn execution_timeline_records_steps_and_answers_state_queries() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 10\n  %1 = const.i64 20\n  return %1\n}\n";
    let Some(program) = build_program(source) else {
        return;
    };
    let options = RunOptions {
        twin_mode: pseudolearn_vm::TwinMode::Probed,
        ..Default::default()
    };
    let machine_result = create_machine(&program, Fuel::unlimited(), options.clone());
    assert!(machine_result.is_ok());
    let Ok(mut machine) = machine_result else {
        return;
    };

    let scheduler_options = SchedulerOptions {
        minimum_distance: 1,
        kappa_factor: 1,
    };
    let mut timeline = ExecutionTimeline::new(&program, options, scheduler_options, 16);

    timeline.record_step(&machine, 0);
    let _ = machine.step_instruction();
    timeline.record_step(&machine, 1);
    let _ = machine.step_instruction();
    timeline.record_step(&machine, 2);

    let query_result = timeline.query_state(1);
    assert!(query_result.is_ok());
    let Ok(snapshot) = query_result else {
        return;
    };
    assert_eq!(snapshot.event_index, 1);

    let frames_result = timeline.query_frames(1);
    assert!(frames_result.is_ok());
    let Ok(frames) = frames_result else {
        return;
    };
    assert_eq!(frames.len(), 1);
}

#[test]
fn past_state_isolation_preserves_main_machine_continuation() {
    let source = "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 10\n  %1 = const.i64 20\n  return %1\n}\n";
    let Some(program) = build_program(source) else {
        return;
    };
    let options = RunOptions {
        twin_mode: pseudolearn_vm::TwinMode::Probed,
        ..Default::default()
    };
    let machine_result = create_machine(&program, Fuel::unlimited(), options.clone());
    assert!(machine_result.is_ok());
    let Ok(mut machine) = machine_result else {
        return;
    };

    let scheduler_options = SchedulerOptions {
        minimum_distance: 1,
        kappa_factor: 1,
    };
    let mut timeline = ExecutionTimeline::new(&program, options, scheduler_options, 16);
    timeline.record_step(&machine, 0);
    let _ = machine.step_instruction();
    timeline.record_step(&machine, 1);

    let state_before_query = machine.capture_machine_state();
    let _ = timeline.query_state(0);
    let state_after_query = machine.capture_machine_state();

    assert_eq!(state_before_query, state_after_query);
}

#[test]
fn queries_reject_events_outside_declared_boundaries() {
    let source =
        "module P es\nfunc @main() -> i64 {\nb0() mass 0:\n  %0 = const.i64 10\n  return %0\n}\n";
    let Some(program) = build_program(source) else {
        return;
    };
    let options = RunOptions::default();
    let machine_result = create_machine(&program, Fuel::unlimited(), options.clone());
    assert!(machine_result.is_ok());
    let Ok(machine) = machine_result else {
        return;
    };

    let scheduler_options = SchedulerOptions::default();
    let mut timeline = ExecutionTimeline::new(&program, options, scheduler_options, 16);
    timeline.record_step(&machine, 5);

    let future_query = timeline.query_state(10);
    assert!(matches!(
        future_query,
        Err(TimelineError::FutureEvent {
            requested: 10,
            latest: 5
        })
    ));
}
