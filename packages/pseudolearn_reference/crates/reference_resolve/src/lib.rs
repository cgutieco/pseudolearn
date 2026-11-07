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

pub use cached_engine::CachedEngine;
pub use categories::CategoryTable;
pub use language_pack::LanguagePack;
pub use resolution::{Resolution, ResolvedSection, SpanishReuse};
pub use section::resolve_section;
pub use section_index::{IndexedSection, SectionIndex};
pub use spelling::canonical_spelling;
