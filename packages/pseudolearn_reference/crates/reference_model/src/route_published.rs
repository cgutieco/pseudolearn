use crate::{Block, ExerciseKind, ExerciseLevel, LessonKind, Run, SectionLink};
use serde::Serialize;

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct LessonReference {
    pub id: String,
    pub number: String,
    pub title: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct RoleEntry {
    pub name: String,
    pub description: Vec<Run>,
    pub figure: Block,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PracticeEntry {
    pub id: String,
    pub title: Vec<Run>,
    pub kind: ExerciseKind,
    pub level: ExerciseLevel,
    pub required: bool,
}

#[derive(Clone, Debug, Default, Eq, PartialEq, Serialize)]
pub struct BriefZones {
    pub inputs: Vec<Run>,
    pub outputs: Vec<Run>,
    pub relation: Vec<Run>,
    pub examples: Vec<Vec<Run>>,
}

#[derive(Clone, Debug, Default, Eq, PartialEq, Serialize)]
pub struct ParadigmZones {
    pub question: Vec<Run>,
    pub metaphor: Vec<Run>,
    pub history: Vec<Run>,
    pub cost: Vec<Run>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum RouteBlock {
    Phrase {
        runs: Vec<Run>,
    },
    Problem {
        blocks: Vec<LessonBlock>,
    },
    Attempt {
        prompt: Vec<LessonBlock>,
        answer: Vec<LessonBlock>,
    },
    Cycle {
        phases: Vec<u8>,
    },
    PhaseHeading {
        id: String,
        phases: Vec<u8>,
        runs: Vec<Run>,
    },
    Brief(BriefZones),
    Roles {
        roles: Vec<RoleEntry>,
    },
    Paradigm(ParadigmZones),
    Recall {
        term: String,
        label: String,
        runs: Vec<Run>,
        lesson: LessonReference,
    },
    SpecLinks {
        links: Vec<SectionLink>,
    },
    Deepen {
        title: String,
        blocks: Vec<LessonBlock>,
    },
    Practice {
        exercises: Vec<PracticeEntry>,
    },
    Next {
        #[serde(skip_serializing_if = "Option::is_none")]
        lesson: Option<LessonReference>,
        runs: Vec<Run>,
    },
    SpecFigure {
        section: String,
        number: String,
        figure: Block,
    },
    Callout {
        kind: crate::CalloutKind,
        collapsible: bool,
        blocks: Vec<LessonBlock>,
    },
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(untagged)]
pub enum LessonBlock {
    Shared(Block),
    Route(RouteBlock),
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct TermEntry {
    pub id: String,
    pub label: String,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PublishedLesson {
    pub id: String,
    pub number: String,
    pub part: String,
    pub kind: LessonKind,
    pub title: Vec<Run>,
    pub minutes: u32,
    pub levels: Vec<ExerciseLevel>,
    pub needs: Vec<LessonReference>,
    pub introduces: Vec<TermEntry>,
    pub brief_problem: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub previous: Option<LessonReference>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub next: Option<LessonReference>,
    pub blocks: Vec<LessonBlock>,
}
