use crate::{
    AnatomyPart, CalloutKind, FormSegment, ProgramBlock, PublishedDiagnostic, Run, SectionKind,
};
use serde::Serialize;

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PanelEntry {
    pub zone: String,
    pub from_step: usize,
    pub runs: Vec<Run>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct FigureStep {
    pub runs: Vec<Run>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct FigureLayer {
    pub from_step: usize,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub until_step: Option<usize>,
    pub svg: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct SectionLink {
    pub section: String,
    pub number: String,
    pub title: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct TraceLine {
    pub line: u64,
    pub class: String,
    pub detail: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct TableBlock {
    pub header: Vec<Vec<Run>>,
    pub rows: Vec<Vec<Vec<Run>>>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Block {
    Heading {
        id: String,
        number: String,
        runs: Vec<Run>,
    },
    Paragraph {
        runs: Vec<Run>,
    },
    List {
        ordered: bool,
        entries: Vec<Vec<Run>>,
    },
    Table(TableBlock),
    Form {
        lines: Vec<Vec<FormSegment>>,
    },
    Anatomy {
        parts: Vec<AnatomyPart>,
    },
    Program(ProgramBlock),
    Figure {
        id: String,
        number: String,
        alt: String,
        description: String,
        caption: Vec<Run>,
        svg: String,
        layers: Vec<FigureLayer>,
        steps: Vec<FigureStep>,
        panels: Vec<PanelEntry>,
    },
    Callout {
        kind: CalloutKind,
        collapsible: bool,
        blocks: Vec<Block>,
    },
    Summary {
        points: Vec<Vec<Run>>,
    },
    SeeAlso {
        links: Vec<SectionLink>,
    },
    Diagnostic(PublishedDiagnostic),
    Intermediate {
        program: String,
        lines: Vec<String>,
    },
    Trace {
        program: String,
        events: Vec<TraceLine>,
    },
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PublishedSection {
    pub id: String,
    pub number: String,
    pub kind: SectionKind,
    pub title: Vec<Run>,
    pub phrase: Vec<Run>,
    pub blocks: Vec<Block>,
}
