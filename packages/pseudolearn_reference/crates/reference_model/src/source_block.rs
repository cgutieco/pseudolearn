use crate::{CalloutKind, FigureSource, Inline, ProgramSource, RouteFence, SectionHeader};
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum SourceBlock {
    Heading {
        id: String,
        phase: Option<String>,
        text: Vec<Inline>,
    },
    Paragraph(Vec<Inline>),
    List {
        ordered: bool,
        entries: Vec<Vec<Inline>>,
    },
    Table {
        header: Vec<Vec<Inline>>,
        rows: Vec<Vec<Vec<Inline>>>,
    },
    Form(String),
    Anatomy(Vec<AnatomySource>),
    Program(ProgramSource),
    Figure(FigureSource),
    Callout {
        kind: CalloutKind,
        attributes: BTreeMap<String, String>,
        blocks: Vec<SourceBlock>,
    },
    Intermediate {
        program: String,
    },
    Trace {
        program: String,
    },
    Generated {
        catalog: String,
    },
    Route(RouteFence),
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct AnatomySource {
    pub code: String,
    pub label: Vec<Inline>,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceDocument {
    pub path: String,
    pub header: SectionHeader,
    pub title: Vec<Inline>,
    pub blocks: Vec<SourceBlock>,
}
