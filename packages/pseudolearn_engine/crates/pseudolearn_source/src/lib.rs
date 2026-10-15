#![forbid(unsafe_code)]

pub mod line_index;
pub mod normalizer;
pub mod source_text;
pub mod span;

pub use line_index::LineIndex;
pub use normalizer::IdentifierNormalizer;
pub use source_text::{SourceFailure, SourceText};
pub use span::Span;
