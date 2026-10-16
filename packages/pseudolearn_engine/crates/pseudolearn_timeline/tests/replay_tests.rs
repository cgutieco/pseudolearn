use pseudolearn_bytecode::compile_text;
use pseudolearn_timeline::{ExecutionTimeline, SchedulerOptions, TimelineError};
use pseudolearn_vm::{
    Fuel, RunOptions, TwinMode, create_machine, load, machine_events, snapshot_machine,
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
