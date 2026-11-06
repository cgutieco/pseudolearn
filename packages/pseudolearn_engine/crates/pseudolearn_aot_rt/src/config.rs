use std::io::{BufRead, Write};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct AotLimits {
    pub frames: u32,
    pub instruction_units: Option<u64>,
    pub cells: u64,
    pub root_capacity: u32,
    pub tasks: u64,
    pub channel_capacity: u64,
}

impl Default for AotLimits {
    fn default() -> Self {
        Self {
            frames: 1_000,
            instruction_units: None,
            cells: 1 << 22,
            root_capacity: 1 << 16,
            tasks: pseudolearn_runtime::DEFAULT_TASK_LIMIT,
            channel_capacity: 65_536,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct BooleanWords {
    pub truth: String,
    pub falsity: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AotConfig {
    pub limits: AotLimits,
    pub seed: i64,
    pub boolean_words: BooleanWords,
}

pub struct AotStreams {
    pub input: Box<dyn BufRead>,
    pub output: Box<dyn Write>,
}
