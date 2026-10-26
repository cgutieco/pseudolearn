#![forbid(unsafe_code)]

mod array_view;
mod cell_view;
mod checkpoint;
mod effect_tape;
mod error;
mod inspect;
mod model;
mod query_views;
mod replay;
mod scheduler;
mod store;
mod tape_privacy;
mod tape_replay;
mod thinning;
mod timeline;
mod views;

pub use checkpoint::Checkpoint;
pub use effect_tape::{EffectTape, ExecutionIdentity, TAPE_SCHEMA_V1, TapeEntry};
pub use error::TimelineError;
pub use tape_privacy::{DEFAULT_MAX_TAPE_BYTES, SecretHandle, TapeBudget};
pub use replay::{replay_machine_to_event, replay_to_event};
pub use scheduler::{CostScheduler, SchedulerOptions};
pub use store::{CaptureCost, CheckpointStore, StoreBudget, StoreStats};
pub use tape_replay::{ExecutionMode, ReplayError, TapeReplayProvider};
pub use timeline::{
    ArraySliceRange, ExecutionTimeline, timeline_checkpoints_count, timeline_horizon,
};
pub use views::{
    AliasDestination, FrameView, StateSnapshot, VariableValue, VariableView, capture_snapshot,
    format_real,
};

pub use query_views::{capture_array_slice, capture_frame};
