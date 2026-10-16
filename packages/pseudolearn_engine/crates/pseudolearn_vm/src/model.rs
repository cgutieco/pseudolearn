#![forbid(unsafe_code)]

use crate::VmTrap;
use crate::events::TraceEvent;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Fuel {
    pub statements: u64,
    pub probes: u64,
}

impl Fuel {
    pub const fn unlimited() -> Self {
        Self {
            statements: u64::MAX,
            probes: u64::MAX,
        }
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum ServiceReason {
    Statements,
    Probe,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum LimitKind {
    Statements,
    Time,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum RuntimeValue {
    Scalar(u64),
    Reference(u32),
}

#[derive(Clone, Debug, PartialEq)]
pub enum RunExit {
    Completed(Option<RuntimeValue>),
    AwaitingInput,
    Cancelled,
    LimitReached { kind: LimitKind },
    Service(ServiceReason),
    Trap(VmTrap),
}

#[derive(Clone, Debug, PartialEq)]
pub struct RunResult {
    pub exit: RunExit,
    pub output: String,
    pub consumed_statements: u64,
    pub consumed_probes: u64,
    pub memory_counts: Vec<MemoryCount>,
    pub events: Vec<TraceEvent>,
    pub inputs_consumed: usize,
    pub diagnostics: Vec<VmTrap>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct MemoryCount {
    pub function: String,
    pub program_counter: usize,
    pub cells: u64,
}
