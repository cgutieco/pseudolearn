#![forbid(unsafe_code)]

pub mod block_layout;
pub mod block_matching;
pub mod completion;
pub mod completion_assignment;
pub mod completion_expected;
pub mod completion_inline;
pub mod completion_keywords;
pub mod completion_members;
pub mod completion_pool;
pub mod completion_probes;
pub mod completion_scope;
pub mod completion_sources;
pub mod completion_symbols;
pub mod completion_templates;
pub mod completion_types;
mod contextual_tokens;
pub mod cursor_context;
pub mod document_session;
pub mod edit_probe;
pub mod edit_session;
pub mod expected_slot;
pub mod formatter;
pub mod help_catalog;
pub mod help_content;
pub mod help_rendering;
mod help_resolution;
pub mod hover;
pub mod identifier_roles;
pub mod insertion;
pub mod line_renderer;
pub mod lsp_changes;
mod lsp_configuration;
mod lsp_diagnostics;
pub mod lsp_documents;
pub mod lsp_help;
mod lsp_initialization;
mod lsp_project_queries;
mod lsp_project_rename;
mod lsp_project_selection;
pub mod lsp_protocol;
pub mod lsp_queries;
mod lsp_rename;
mod lsp_request_routing;
mod lsp_semantic_tokens;
pub mod lsp_session;
pub mod lsp_workspace;
mod lsp_workspace_symbols;
pub mod marked_text;
pub mod navigation;
pub mod node_identity;
pub mod on_type;
pub mod on_type_enter;
pub mod on_type_pairs;
pub mod on_type_realign;
pub mod positions;
pub mod query_context;
pub mod request_cancellation;
pub mod source_lines;
pub mod spelling;
pub mod symbol_index;
pub mod symbol_queries;
pub mod template_catalog;
pub mod template_insertion;
pub mod template_markers;
pub mod template_model;
pub mod template_render;
pub mod template_reuse;
pub mod template_session;
pub mod template_validity;
pub mod translator;
pub mod type_names;
pub mod typing_lines;
pub mod typing_plan;
pub mod unit_partition;
mod workspace_analysis;
mod workspace_index;
mod workspace_invalidation;
pub mod workspace_model;
mod workspace_parse;
pub mod workspace_session;
mod workspace_snapshot;

pub use completion::{
    CompletionAction, CompletionEntry, CompletionKind, CompletionQuery, CompletionResult,
    CompletionTextEdit, complete_at_position, complete_at_position_with_edit,
};
pub use completion_templates::{
    StopOutline, TemplateOutline, get_template, template_constructions, template_outline,
};
pub use document_session::{DocumentOptions, DocumentSession, LanguageService, TextEdit};
pub use edit_probe::{IdentityCheck, IncrementalProbe};
pub use edit_session::{Acceptance, Accepted, EditError, EditSession};
pub use formatter::{FormatOptions, format_checked, format_source};
pub use help_catalog::HelpLocale;
pub use help_content::{HelpContent, help_content};
pub use help_rendering::{HelpFormat, HelpRenderError, render_help};
pub use help_resolution::{
    HelpCertainty, HelpIdentity, HelpIdentityKind, HelpQueryOutcome, HelpResolution, HelpSymbol,
    resolve_help_at_position, resolve_help_with_locale,
};
pub use hover::{HoverCategory, HoverOutcome, SignatureHelp};
pub use insertion::{Insertion, StopRange, TextChange, apply_change, build_insertion};
pub use lsp_session::LspServer;
pub use navigation::{
    DocumentHighlight, DocumentSymbolEntry, HighlightKind, Position, Range, SymbolCategory,
};
pub use node_identity::{SyntaxNodeId, compute_node_identities, compute_unit_name};
pub use on_type::{OnTypeOutcome, apply_changes, on_type};
pub use pseudolearn_lexicon::Profile;
pub use request_cancellation::RequestCancellation;
pub use template_model::StopRole;
pub use template_session::{StopDirection, StopNavigation};
pub use template_validity::{template_parses_cleanly, template_program, template_stops_valid};
pub use translator::{TranslationError, translate_source};
pub use unit_partition::{PartitionReport, UnitFingerprint, compare_partitions, partition_units};
pub use workspace_model::{
    WorkspaceError, WorkspaceInvalidation, WorkspaceOptions, WorkspaceResult, WorkspaceSnapshot,
};
pub use workspace_session::{SnapshotUpdateMode, WorkspaceSession};
