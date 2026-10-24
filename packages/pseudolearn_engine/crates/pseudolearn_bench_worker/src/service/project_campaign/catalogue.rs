use crate::service::project_campaign::datasets::{Dataset, Edit, GraphPlan, graph};
use crate::service::project_campaign::shapes::Shape;

pub const PROTOCOL: &str = "e-pg-13/1";
pub const COUNTS: [usize; 3] = [10, 100, 1000];
pub const FIXED_TOTAL_LINES: usize = 10_000;
pub const GROWING_LINES_PER_FILE: usize = 100;

#[derive(Clone, Copy, Eq, PartialEq)]
pub enum Case {
    Cold,
    Same,
    Body,
    Signature,
}

impl Case {
    pub fn name(self) -> &'static str {
        match self {
            Case::Cold => "cold",
            Case::Same => "same-revision",
            Case::Body => "body-edit",
            Case::Signature => "signature-edit",
        }
    }

    pub fn edit(self) -> Edit {
        match self {
            Case::Body => Edit::Body,
            Case::Signature => Edit::Signature,
            _ => Edit::None,
        }
    }
}

pub struct Entry {
    pub name: String,
    pub shape: Shape,
    pub count: usize,
    pub lines_per_file: usize,
    pub case: Case,
}

impl Entry {
    pub fn base(&self) -> Dataset {
        self.dataset(Edit::None)
    }

    pub fn edited(&self) -> Dataset {
        self.dataset(self.case.edit())
    }

    fn dataset(&self, edit: Edit) -> Dataset {
        graph(&GraphPlan {
            shape: self.shape,
            count: self.count,
            lines_per_file: self.lines_per_file,
            edit,
        })
    }
}

pub fn entries() -> Vec<Entry> {
    let mut found = Vec::new();
    for shape in Shape::ALL {
        for count in COUNTS {
            let lines = FIXED_TOTAL_LINES.checked_div(count).unwrap_or(3).max(3);
            for case in [Case::Cold, Case::Same, Case::Body, Case::Signature] {
                found.push(entry("fixed-total", shape, (count, lines), case));
            }
        }
    }
    for count in COUNTS {
        found.push(entry(
            "growing",
            Shape::Star,
            (count, GROWING_LINES_PER_FILE),
            Case::Cold,
        ));
    }
    found
}

fn entry(series: &'static str, shape: Shape, size: (usize, usize), case: Case) -> Entry {
    Entry {
        name: format!(
            "{series}-{}-{}x{}-{}",
            shape.name(),
            size.0,
            size.1,
            case.name()
        ),
        shape,
        count: size.0,
        lines_per_file: size.1,
        case,
    }
}
