use crate::clepsydra::ClepsydraMachine;
use crate::direct::DirectMachine;
use crate::machine::{Machine, Outcome};
use crate::timeline::Timeline;
use std::time::Duration;

pub const KERNELS: [&str; 10] = [
    "sieve",
    "permute",
    "queens",
    "towers",
    "list",
    "storage",
    "bounce",
    "mandelbrot",
    "nbody",
    "richards",
];

pub enum Experiment {
    Idiomatic,
    Direct(DirectMachine),
    Paged(Box<ClepsydraMachine>),
}

impl Experiment {
    pub fn new(variant: u8) -> Outcome<Self> {
        match variant {
            0 => Ok(Self::Idiomatic),
            1 => Ok(Self::Direct(DirectMachine::default())),
            2 | 3 => {
                let timeline = (variant == 3).then(|| Timeline::new(Duration::from_millis(1)));
                Ok(Self::Paged(Box::new(ClepsydraMachine::new(timeline)?)))
            }
            _ => Err(crate::machine::Trap::InvalidHandle),
        }
    }

    pub fn run(&mut self, kernel: &str, size: i64) -> Outcome<String> {
        match self {
            Self::Idiomatic => idiomatic(kernel, usize::try_from(size).unwrap_or_default()),
            Self::Direct(machine) => {
                machine.reset();
                checked(kernel, machine, size)
            }
            Self::Paged(machine) => {
                machine.reset();
                checked(kernel, machine.as_mut(), size)
            }
        }
    }

    pub fn checkpoints(&self) -> u64 {
        match self {
            Self::Paged(machine) => machine.checkpoints(),
            _ => 0,
        }
    }
}

pub fn run(kernel: &str, variant: u8, size: i64) -> Outcome<String> {
    Experiment::new(variant)?.run(kernel, size)
}

fn checked<Implementation: Machine>(
    kernel: &str,
    machine: &mut Implementation,
    size: i64,
) -> Outcome<String> {
    match kernel {
        "sieve" => crate::checked::sieve::run(machine, size),
        "permute" => crate::checked::permute::run(machine, size),
        "queens" => crate::checked::queens::run(machine, size),
        "towers" => crate::checked::towers::run(machine, size),
        "list" => crate::checked::list::run(machine, size),
        "storage" => crate::checked::storage::run(machine, size),
        "bounce" => crate::checked::bounce::run(machine, size),
        "mandelbrot" => crate::checked::mandelbrot::run(machine, size),
        "nbody" => crate::checked::nbody::run(machine, size),
        "richards" => crate::checked::richards::run(machine, size),
        _ => Err(crate::machine::Trap::InvalidHandle),
    }
}

fn idiomatic(kernel: &str, size: usize) -> Outcome<String> {
    match kernel {
        "sieve" => Ok(crate::idiomatic::sieve::run(size)),
        "permute" => Ok(crate::idiomatic::permute::run(size)),
        "queens" => Ok(crate::idiomatic::queens::run(size)),
        "towers" => Ok(crate::idiomatic::towers::run(size)),
        "list" => Ok(crate::idiomatic::list::run(size)),
        "storage" => Ok(crate::idiomatic::storage::run(size)),
        "bounce" => Ok(crate::idiomatic::bounce::run(size)),
        "mandelbrot" => Ok(crate::idiomatic::mandelbrot::run(size)),
        "nbody" => Ok(crate::idiomatic::nbody::run(size)),
        "richards" => Ok(crate::idiomatic::richards::run(size)),
        _ => Err(crate::machine::Trap::InvalidHandle),
    }
}
