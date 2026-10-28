use pseudolearn_bytecode::compile_text;
use pseudolearn_vm::{
    Fuel, Machine, RunExit, RunOptions, advance_image, create_machine, load, machine_output,
    restore_machine_image, resume_machine, revert_image, snapshot_machine, snapshot_machine_lean,
    suspend_machine,
};

fn program() -> Result<pseudolearn_vm::LoadedProgram, String> {
    let source = "module P es\nfunc suspendible @main() -> unit {\nb0() mass 0:\n %0 = const.str \"kept\" @1:1-1:5\n %1 = task.scope_open @1:1-1:5\n %2 = task.spawn %1, @worker() @2:1-2:5\n %3 = task.await %2, i64 @3:1-3:5\n task.scope_join %1 @4:1-4:5\n out.write %0, newline @5:1-5:5\n out.write %3, newline @6:1-6:5\n return\n}\nfunc suspendible @worker() -> i64 {\nb0() mass 0:\n %0 = const.i64 42\n return %0\n}\n";
    let bytecode = compile_text(source).map_err(|error| format!("{error:?}"))?;
    load(&bytecode).map_err(|error| format!("{error:?}"))
}

fn finish(machine: &mut Machine<'_>) -> Result<(), String> {
    for _ in 0..100 {
        if let Some(exit) = machine.step_instruction() {
            assert_eq!(exit, RunExit::Completed(None));
            assert_eq!(machine_output(machine), "kept\n42\n");
            return Ok(());
        }
    }
    Err("Task execution did not complete".to_owned())
}

#[test]
fn images_preserve_ready_suspended_and_completed_tasks() -> Result<(), String> {
    let program = program()?;
    for prefix in 0..8 {
        let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
            .map_err(|error| format!("{error:?}"))?;
        for _ in 0..prefix {
            assert!(machine.step_instruction().is_none());
        }
        let image = snapshot_machine(&machine);
        let lean = snapshot_machine_lean(&machine);
        let owned = suspend_machine(machine);
        for image in [image, lean, owned] {
            let mut resumed = resume_machine(&program, image, RunOptions::default())
                .map_err(|error| format!("{error:?}"))?;
            finish(&mut resumed)?;
        }
    }
    Ok(())
}

#[test]
fn inverse_deltas_restore_the_task_agenda_and_continuations() -> Result<(), String> {
    let program = program()?;
    let mut machine = create_machine(&program, Fuel::unlimited(), RunOptions::default())
        .map_err(|error| format!("{error:?}"))?;
    let original = snapshot_machine_lean(&machine);
    let mut tip = original.clone();
    let mut deltas = Vec::new();
    for _ in 0..7 {
        assert!(machine.step_instruction().is_none());
        deltas.push(advance_image(&mut tip, &machine));
    }
    for delta in deltas.iter().rev() {
        revert_image(&mut tip, delta).map_err(|error| format!("{error:?}"))?;
    }
    assert_eq!(tip, original);
    restore_machine_image(&mut machine, &tip);
    finish(&mut machine)
}
