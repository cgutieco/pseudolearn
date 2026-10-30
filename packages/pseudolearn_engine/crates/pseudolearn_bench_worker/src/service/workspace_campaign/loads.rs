use crate::service::project_campaign::datasets::{Dataset, Edit, GraphPlan, graph};
use crate::service::project_campaign::shapes::Shape;

pub const CONTROL_TOTAL_LINES: usize = 10_000;
pub const EXTENDED_LINES_PER_FILE: usize = 100;

#[derive(Clone, Copy, Debug)]
pub struct Load {
    pub name: &'static str,
    pub files: usize,
    pub lines_per_file: usize,
}

pub const LOADS: [Load; 4] = [
    Load {
        name: "files-10",
        files: 10,
        lines_per_file: CONTROL_TOTAL_LINES / 10,
    },
    Load {
        name: "files-100",
        files: 100,
        lines_per_file: CONTROL_TOTAL_LINES / 100,
    },
    Load {
        name: "files-1000",
        files: 1000,
        lines_per_file: CONTROL_TOTAL_LINES / 1000,
    },
    Load {
        name: "files-1000-extended",
        files: 1000,
        lines_per_file: EXTENDED_LINES_PER_FILE,
    },
];

pub fn dataset(load: &Load, edit: Edit) -> Dataset {
    graph(&GraphPlan {
        shape: Shape::Library,
        count: load.files,
        lines_per_file: load.lines_per_file,
        edit,
    })
}
