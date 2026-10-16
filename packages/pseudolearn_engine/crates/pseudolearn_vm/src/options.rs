use pseudolearn_runtime::{CollectionPolicy, MemoryOptions};

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct RunOptions {
    pub seed: i64,
    pub depth: usize,
    pub memory: MemoryOptions,
    pub inspect_memory: bool,
}

impl Default for RunOptions {
    fn default() -> Self {
        Self {
            seed: 42,
            inspect_memory: false,
            depth: 100_000,
            memory: MemoryOptions {
                cells: 1 << 22,
                collection: CollectionPolicy::Automatic,
            },
        }
    }
}
