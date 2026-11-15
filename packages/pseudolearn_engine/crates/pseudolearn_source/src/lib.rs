#![forbid(unsafe_code)]

pub mod identity;
pub mod line_index;
pub mod normalizer;
pub mod source_table;
pub mod source_text;
pub mod span;

pub use identity::{NodeId, ProjectId, RevisionId, SourceIdentity, SourceLocation};
pub use line_index::LineIndex;
pub use normalizer::IdentifierNormalizer;
pub use source_table::{
    SourceFile, SourceFileInput, SourceLookupFailure, SourceNodeInput, SourceTable,
    SourceTableFailure,
};
pub use source_text::{
    SourceFailure, SourceText, byte_offset_from_line_column, byte_offset_from_scalar,
    byte_offset_from_utf16, is_valid_span, line_and_column_utf16, scalar_offset, source_id,
    source_identity, source_text_with_identity, source_text_with_source_id, utf16_offset,
};
pub use span::{SourceId, Span};
