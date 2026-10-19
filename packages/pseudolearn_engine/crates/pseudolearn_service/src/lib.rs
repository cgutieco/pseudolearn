#![forbid(unsafe_code)]

pub mod completion;
pub mod completion_templates;
pub mod completion_types;
pub mod document_session;
pub mod format_rules;
pub mod formatter;
pub mod hover;
pub mod lsp_changes;
pub mod lsp_protocol;
pub mod lsp_session;
pub mod navigation;
pub mod node_identity;
pub mod translator;
pub mod unit_partition;

pub use completion::{CompletionEntry, CompletionKind, CompletionQuery, complete_at_position};
pub use completion_templates::get_template;
pub use document_session::{DocumentOptions, DocumentSession, LanguageService};
pub use formatter::{FormatOptions, format_source};
pub use hover::{HoverOutcome, SignatureHelp, hover_at_position, signature_help_at_position};
pub use lsp_protocol::{LspDiagnostic, LspLocation, LspPosition, LspRange};
pub use lsp_session::LspServer;
pub use navigation::{
    DocumentHighlight, HighlightKind, Position, Range, document_highlights, find_definition,
    find_references,
};
pub use node_identity::{SyntaxNodeId, compute_node_identities, compute_unit_name};
pub use pseudolearn_lexicon::Profile;
pub use translator::{TranslationError, translate_source};
pub use unit_partition::{PartitionReport, UnitFingerprint, compare_partitions, partition_units};
