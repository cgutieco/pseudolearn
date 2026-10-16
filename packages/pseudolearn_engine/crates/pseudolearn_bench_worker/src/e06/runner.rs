use pseudolearn_vm::{Fuel, Machine, RunExit, TwinMode, create_machine};

use super::programs::{CompiledCase, options};

pub fn machine_for(case: &CompiledCase, mode: TwinMode) -> Result<Machine<'_>, String> {
    create_machine(
        &case.program,
        Fuel::unlimited(),
        options(mode, &case.inputs),
    )
    .map_err(|trap| format!("{}: {}", case.name, trap.code))
}

pub fn run_to_end<Observer>(machine: &mut Machine<'_>, mut observe: Observer) -> Result<u64, String>
where
    Observer: FnMut(&Machine<'_>, u64) -> Result<(), String>,
{
    let mut steps = 0_u64;
    loop {
        match machine.step_instruction() {
            None => {
                steps = steps.saturating_add(1);
                observe(machine, steps)?;
            }
            Some(RunExit::Completed(_)) => return Ok(steps),
            Some(other) => return Err(format!("Unexpected exit: {other:?}")),
        }
    }
}

pub const CHUNK_STEPS: u64 = 1024;

pub fn run_chunked<Observer>(
    machine: &mut Machine<'_>,
    mut observe: Observer,
) -> Result<u64, String>
where
    Observer: FnMut(&Machine<'_>, u64) -> Result<bool, String>,
{
    let mut steps = 0_u64;
    loop {
        for _ in 0..CHUNK_STEPS {
            match machine.step_instruction() {
                None => steps = steps.saturating_add(1),
                Some(RunExit::Completed(_)) => return Ok(steps),
                Some(other) => return Err(format!("Unexpected exit: {other:?}")),
            }
        }
        if !observe(machine, steps)? {
            return Ok(steps);
        }
    }
}

pub fn nanoseconds(started: std::time::Instant) -> f64 {
    super::stats::to_float(u64::try_from(started.elapsed().as_nanos()).unwrap_or(u64::MAX))
}
