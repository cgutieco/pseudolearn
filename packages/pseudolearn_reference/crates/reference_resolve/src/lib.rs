#![forbid(unsafe_code)]

mod blocks;
mod cached_engine;
mod callouts;
mod categories;
mod figures;
mod forms;
mod generated;
mod generated_tables;
mod language_pack;
mod programs;
mod rails;
mod resolution;
mod runs;
mod section;
mod section_index;
mod spelling;
mod trace;

pub use blocks::resolve_blocks;
pub use cached_engine::CachedEngine;
pub use categories::CategoryTable;
pub use figures::figure_block;
pub use language_pack::LanguagePack;
pub use programs::{program_block, published_diagnostics, target_code, with_final_newline};
pub use resolution::{Collector, Resolution, ResolvedSection, SpanishReuse};
pub use runs::runs as resolve_runs;
pub use section::resolve_section;
pub use section_index::{IndexedSection, SectionIndex};
pub use spelling::canonical_spelling;
