#![forbid(unsafe_code)]

mod callout;
mod category;
mod engine_port;
mod header;
mod inline;
mod program_view;
mod published;
mod published_program;
mod published_run;
mod route_check;
mod route_exercise;
mod route_header;
mod route_published;
mod route_source;
mod section_kind;
mod source_block;
mod source_figure;
mod source_program;
mod violation;

pub use callout::CalloutKind;
pub use category::TokenCategory;
pub use engine_port::{
    CodeEngine, EngineDiagnostic, ExecutionReport, ExecutionRequest, RawToken, TraceRecord,
};
pub use header::{Profile, SectionHeader};
pub use inline::Inline;
pub use program_view::{MemberView, ProgramView, SubprogramView};
pub use published::{
    Block, FigureLayer, FigureStep, PanelEntry, PublishedSection, SectionLink, TableBlock,
    TraceLine,
};
pub use published_program::{AnatomyPart, FormSegment, ProgramBlock, PublishedDiagnostic};
pub use published_run::{Run, Token};
pub use route_check::{ExerciseCheck, LapCheck, RoleRuns, RunRecord, StructureCheck};
pub use route_exercise::{
    ChoiceEntry, ClassifiedElement, Evaluation, LapCell, LapRow, PublishedCase, PublishedExercise,
};
pub use route_header::{
    ExerciseDocument, ExerciseHeader, ExerciseKind, ExerciseLevel, LessonDocument, LessonHeader,
    LessonKind, TermDefinition,
};
pub use route_published::{
    BriefZones, LessonBlock, LessonReference, ParadigmZones, PracticeEntry, PublishedLesson,
    RoleEntry, RouteBlock, TermEntry,
};
pub use route_source::{
    AssertionSource, CaseSource, ChoiceSource, ElementSource, LapSource, LapTable, RouteDocument,
    RouteFence,
};
pub use section_kind::SectionKind;
pub use source_block::{AnatomySource, SourceBlock, SourceDocument};
pub use source_figure::{FigurePanelSource, FigureSource, FigureStepSource};
pub use source_program::{ExampleCheck, ProgramPromise, ProgramSource};
pub use violation::{RuleId, Violation};
