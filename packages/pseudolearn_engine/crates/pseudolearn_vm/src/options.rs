#![forbid(unsafe_code)]

use pseudolearn_runtime::MemoryOptions;
use std::sync::Arc;
use std::sync::atomic::AtomicBool;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum TwinMode {
    Fast,
    Probed,
    Differential,
}

#[derive(Clone, Debug)]
pub struct RunOptions {
    pub seed: i64,
    pub depth: usize,
    pub memory: MemoryOptions,
    pub inspect_memory: bool,
    pub twin_mode: TwinMode,
    pub statement_limit: Option<u64>,
    pub inputs: Vec<String>,
    pub cancel_at_statement: Option<u64>,
    pub cancel_at_poll: Option<u64>,
    pub cancelled: Option<Arc<AtomicBool>>,
    pub task_limit: u64,
    pub channel_capacity_limit: usize,
}

impl Default for RunOptions {
    fn default() -> Self {
        Self {
            seed: 42,
            inspect_memory: false,
            depth: 100_000,
            memory: MemoryOptions::default(),
            twin_mode: TwinMode::Fast,
            statement_limit: None,
            inputs: Vec::new(),
            cancel_at_statement: None,
            cancel_at_poll: None,
            cancelled: None,
            task_limit: pseudolearn_runtime::DEFAULT_TASK_LIMIT,
            channel_capacity_limit: 65_536,
        }
    }
}

impl PartialEq for RunOptions {
    fn eq(&self, other: &Self) -> bool {
        self.seed == other.seed
            && self.depth == other.depth
            && self.memory == other.memory
            && self.inspect_memory == other.inspect_memory
            && self.twin_mode == other.twin_mode
            && self.statement_limit == other.statement_limit
            && self.inputs == other.inputs
            && self.cancel_at_statement == other.cancel_at_statement
            && self.cancel_at_poll == other.cancel_at_poll
            && self.task_limit == other.task_limit
            && self.channel_capacity_limit == other.channel_capacity_limit
    }
}
