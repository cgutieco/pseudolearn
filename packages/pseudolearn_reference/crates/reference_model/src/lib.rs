#![forbid(unsafe_code)]

mod callout;
mod category;
mod engine_port;
mod header;
mod inline;
mod published;
mod published_program;
mod published_run;
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
pub use header::{Profile, RailRequest, SectionHeader};
pub use inline::Inline;
pub use published::{
    Block, FigureLayer, FigureStep, PanelEntry, PublishedSection, SectionLink, TableBlock,
    TraceLine,
};
pub use published_program::{FormSegment, ProgramBlock, PublishedDiagnostic};
pub use published_run::{Run, Token};
pub use section_kind::SectionKind;
pub use source_block::{SourceBlock, SourceDocument};
pub use source_figure::{FigurePanelSource, FigureSource, FigureStepSource};
pub use source_program::{ExampleCheck, ProgramPromise, ProgramSource};
pub use violation::{RuleId, Violation};
