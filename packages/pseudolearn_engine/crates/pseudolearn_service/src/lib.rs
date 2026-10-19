#![forbid(unsafe_code)]

pub mod block_layout;
pub mod completion;
pub mod completion_keywords;
pub mod completion_members;
pub mod completion_pool;
pub mod completion_probes;
pub mod completion_scope;
pub mod completion_sources;
pub mod completion_symbols;
pub mod completion_templates;
pub mod completion_types;
pub mod cursor_context;
pub mod document_session;
pub mod edit_probe;
pub mod formatter;
pub mod hover;
pub mod identifier_roles;
pub mod keyword_help;
pub mod line_renderer;
pub mod lsp_changes;
pub mod lsp_documents;
pub mod lsp_protocol;
pub mod lsp_queries;
pub mod lsp_session;
pub mod marked_text;
pub mod navigation;
pub mod node_identity;
pub mod positions;
pub mod query_context;
pub mod source_lines;
pub mod spelling;
pub mod symbol_index;
pub mod symbol_queries;
pub mod template_validity;
pub mod translator;
pub mod type_names;
pub mod unit_partition;

pub use completion::{CompletionEntry, CompletionKind, CompletionQuery, complete_at_position};
pub use completion_templates::{get_template, template_constructions};
pub use document_session::{DocumentOptions, DocumentSession, LanguageService, TextEdit};
pub use edit_probe::{IdentityCheck, IncrementalProbe};
pub use formatter::{FormatOptions, format_checked, format_source};
pub use hover::{HoverCategory, HoverOutcome, SignatureHelp};
pub use lsp_session::LspServer;
pub use navigation::{
    DocumentHighlight, DocumentSymbolEntry, HighlightKind, Position, Range, SymbolCategory,
};
pub use node_identity::{SyntaxNodeId, compute_node_identities, compute_unit_name};
pub use pseudolearn_lexicon::Profile;
pub use template_validity::{template_parses_cleanly, template_program};
pub use translator::{TranslationError, translate_source};
pub use unit_partition::{PartitionReport, UnitFingerprint, compare_partitions, partition_units};
