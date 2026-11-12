use crate::service::project_campaign::datasets::{Dataset, Edit, GraphPlan, graph};
use crate::service::project_campaign::shapes::Shape;
use crate::service::workspace_campaign::scenario::DIAGNOSTIC_THRESHOLD_MILLIS;

pub const CONTROL_TOTAL_LINES: usize = 10_000;
pub const EXTENDED_LINES_PER_FILE: usize = 100;
pub const EXTENDED_DIAGNOSTIC_THRESHOLD_MILLIS: f64 = 300.0;

#[derive(Clone, Copy, Debug)]
pub struct Load {
    pub name: &'static str,
    pub files: usize,
    pub lines_per_file: usize,
    pub diagnostic_threshold_millis: f64,
}

pub const LOADS: [Load; 4] = [
    Load {
        name: "files-10",
        files: 10,
        lines_per_file: CONTROL_TOTAL_LINES / 10,
        diagnostic_threshold_millis: DIAGNOSTIC_THRESHOLD_MILLIS,
    },
    Load {
        name: "files-100",
        files: 100,
        lines_per_file: CONTROL_TOTAL_LINES / 100,
        diagnostic_threshold_millis: DIAGNOSTIC_THRESHOLD_MILLIS,
    },
    Load {
        name: "files-1000",
        files: 1000,
        lines_per_file: CONTROL_TOTAL_LINES / 1000,
        diagnostic_threshold_millis: DIAGNOSTIC_THRESHOLD_MILLIS,
    },
    Load {
        name: "files-1000-extended",
        files: 1000,
        lines_per_file: EXTENDED_LINES_PER_FILE,
        diagnostic_threshold_millis: EXTENDED_DIAGNOSTIC_THRESHOLD_MILLIS,
    },
];

pub fn diagnostic_threshold(load: &str) -> f64 {
    LOADS
        .iter()
        .find(|candidate| candidate.name == load)
        .map_or(DIAGNOSTIC_THRESHOLD_MILLIS, |candidate| {
            candidate.diagnostic_threshold_millis
        })
}

pub fn dataset(load: &Load, edit: Edit) -> Dataset {
    graph(&GraphPlan {
        shape: Shape::Library,
        count: load.files,
        lines_per_file: load.lines_per_file,
        edit,
    })
}
