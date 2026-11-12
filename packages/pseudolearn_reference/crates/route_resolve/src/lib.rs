#![forbid(unsafe_code)]

mod catalog;
mod context;
mod evaluation;
mod evaluation_order;
mod exercise;
mod exercise_runs;
mod laps;
mod lesson;
mod lesson_blocks;
mod ordering;
mod route_callouts;
mod zones;

pub use catalog::{ExerciseSummary, RouteCatalog, TermCard, build_catalog};
pub use context::RouteContext;
pub use evaluation_order::{assertion_keys, program_blocks};
pub use exercise::{ResolvedExercise, resolve_exercise};
pub use laps::{LAP_CLOSE, LAP_OPEN, instrument, observed_rows};
pub use lesson::{ResolvedLesson, resolve_lesson};
pub use ordering::shuffled_order;
