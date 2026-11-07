use crate::{ExerciseKind, ExerciseLevel, LessonBlock, ProgramBlock, Run};
use serde::Serialize;
use std::collections::BTreeMap;

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PublishedCase {
    pub inputs: Vec<String>,
    pub expected: String,
    pub hidden: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct LapCell {
    pub value: String,
    pub editable: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct LapRow {
    pub label: String,
    pub cells: Vec<LapCell>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct ChoiceEntry {
    pub runs: Vec<Run>,
    pub justification: Vec<Run>,
    pub correct: bool,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct ClassifiedElement {
    pub runs: Vec<Run>,
    pub category: usize,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum Evaluation {
    Predict {
        output: String,
    },
    Trace {
        columns: Vec<String>,
        rows: Vec<LapRow>,
    },
    OrderProgram {
        head: String,
        tail: String,
        blocks: Vec<String>,
        cases: Vec<PublishedCase>,
    },
    OrderSteps {
        steps: Vec<Vec<Run>>,
        solution: Vec<usize>,
    },
    Cases {
        cases: Vec<PublishedCase>,
        assertions: Vec<BTreeMap<String, String>>,
    },
    Break {
        defective: String,
        reference: String,
        reads: usize,
        cases: Vec<PublishedCase>,
    },
    DesignTests {
        reference: String,
        mutants: Vec<String>,
        reads: usize,
        minimum: usize,
        maximum: usize,
    },
    Classify {
        categories: Vec<String>,
        elements: Vec<ClassifiedElement>,
    },
    Choice {
        options: Vec<ChoiceEntry>,
    },
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize)]
pub struct PublishedExercise {
    pub id: String,
    pub lesson: String,
    pub kind: ExerciseKind,
    pub level: ExerciseLevel,
    pub required: bool,
    pub title: Vec<Run>,
    pub statement: Vec<LessonBlock>,
    pub restriction: Vec<LessonBlock>,
    pub hints: Vec<Vec<Run>>,
    pub variant: Vec<LessonBlock>,
    pub explanation: Vec<LessonBlock>,
    pub teachers: Vec<LessonBlock>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub program: Option<ProgramBlock>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub starter_code: Option<String>,
    pub evaluation: Evaluation,
}
