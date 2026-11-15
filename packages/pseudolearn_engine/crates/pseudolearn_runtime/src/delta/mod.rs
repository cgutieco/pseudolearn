mod block;
mod heap;
mod map;
mod tail;

pub use block::{BLOCK_WORDS, BlockDelta, DeltaError};
pub use heap::{HeapDelta, advance_heap, compose_heap_deltas, revert_heap};
pub use map::MapDelta;
pub use tail::{Sequence, TailDelta};
