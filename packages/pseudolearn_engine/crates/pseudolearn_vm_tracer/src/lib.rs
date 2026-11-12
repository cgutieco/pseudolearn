#![forbid(unsafe_code)]

mod measure;
mod workload;

pub use measure::{
    MeasuredSample, measure_workload, prepare_workload, prepare_workload_with_superinstructions,
    profile_workload,
};
pub use workload::{Workload, load_workload};
