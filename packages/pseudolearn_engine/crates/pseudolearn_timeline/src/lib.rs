#![forbid(unsafe_code)]

mod array_view;
mod cell_view;
mod checkpoint;
mod deltas;
mod error;
mod inspect;
mod model;
mod query_views;
mod replay;
mod scheduler;
mod store;
mod thinning;
mod timeline;
mod views;

pub use checkpoint::Checkpoint;
pub use deltas::{
    FieldChange, FrameChange, StateDelta, VariableChange, apply_delta_forward, compute_delta,
};
pub use error::TimelineError;
pub use replay::replay_to_event;
pub use scheduler::{CostScheduler, SchedulerOptions};
pub use store::{CaptureCost, CheckpointStore, StoreBudget, StoreStats};
pub use timeline::{
    ArraySliceRange, ExecutionTimeline, timeline_checkpoints_count, timeline_horizon,
};
pub use views::{
    AliasDestination, FrameView, ObjectView, StateSnapshot, VariableValue, VariableView,
    capture_snapshot, format_real,
};

pub use query_views::{capture_array_slice, capture_frame};
