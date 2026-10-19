use crate::completion::{CompletionQuery, CompletionResult, complete_at_position_with_edit};
use crate::formatter::{FormatOptions, format_source};
use crate::hover::{HoverOutcome, SignatureHelp, hover_at_position, signature_help_at_position};
use crate::navigation::{
    DocumentHighlight, DocumentSymbolEntry, Position, Range, document_highlights, document_symbols,
    find_definition, find_references,
};
use crate::positions::offset_at;
use crate::query_context::QueryContext;
use crate::symbol_index::SymbolIndex;
use crate::unit_partition::{
    PartitionReport, UnitFingerprint, compare_partitions, partition_units,
};
use pseudolearn_diagnostics::{Diagnostic, render::sort_diagnostics};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, ServiceAnalysis, analyze_for_service};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, parse_source};
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct DocumentOptions {
    pub profile: Profile,
    pub strict: bool,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct TextEdit {
    pub range: Range,
    pub new_text: String,
}

pub struct DocumentSession {
    pub source: SourceText,
    pub tree: SyntaxTree,
    pub syntax_diagnostics: Vec<Diagnostic>,
    pub analysis: ServiceAnalysis,
    pub index: SymbolIndex,
    pub units: Vec<UnitFingerprint>,
    pub profile: Profile,
    pub strict: bool,
}

impl DocumentSession {
    pub fn new(text: String, profile: Profile, strict: bool) -> Self {
        let source = SourceText::new(text);
        let (tree, syntax_diagnostics) = parse_source(&source, profile);
        let analysis = analyze_for_service(&tree, &source, SemanticOptions { profile, strict });
        let index = SymbolIndex::build(&tree, &analysis);
        let units = partition_units(&tree, &source);
        Self {
            source,
            tree,
            syntax_diagnostics,
            analysis,
            index,
            units,
            profile,
            strict,
        }
    }

    pub fn text(&self) -> &str {
        self.source.as_str()
    }

    pub fn apply_edit(&mut self, new_text: String) -> PartitionReport {
        if new_text == self.source.as_str() {
            return PartitionReport {
                units: self.units.clone(),
                signature_invalidated: false,
                unchanged_count: self.units.len(),
                affected_count: 0,
            };
        }
        let fresh = Self::new(new_text, self.profile, self.strict);
        let report = compare_partitions(&self.units, &fresh.units);
        *self = fresh;
        report
    }

    pub fn apply_text_edits(&mut self, edits: &[TextEdit]) -> PartitionReport {
        let mut text = self.source.as_str().to_owned();
        for edit in edits {
            let start = offset_at(&text, edit.range.start);
            let ending = offset_at(&text, edit.range.end).max(start);
            let head = text.get(..start).unwrap_or("");
            let tail = text.get(ending..).unwrap_or("");
            text = format!("{head}{}{tail}", edit.new_text);
        }
        self.apply_edit(text)
    }

    pub fn matches_cold_analysis(&self) -> bool {
        let cold = Self::new(self.source.as_str().to_owned(), self.profile, self.strict);
        self.tree == cold.tree
            && self.syntax_diagnostics == cold.syntax_diagnostics
            && self.analysis == cold.analysis
            && self.index == cold.index
            && self.units == cold.units
    }

    pub fn diagnostics(&self) -> Vec<Diagnostic> {
        let mut combined = self.syntax_diagnostics.clone();
        combined.extend(self.analysis.diagnostics.iter().cloned());
        sort_diagnostics(&mut combined);
        combined
    }

    pub fn queries(&self) -> SessionQueries<'_> {
        SessionQueries { session: self }
    }

    pub(crate) fn query_context(&self) -> QueryContext<'_> {
        QueryContext {
            tree: &self.tree,
            source: &self.source,
            analysis: &self.analysis,
            index: &self.index,
            profile: self.profile,
        }
    }
}

pub struct SessionQueries<'session> {
    session: &'session DocumentSession,
}

impl SessionQueries<'_> {
    pub fn complete_with_edit(&self, position: Position) -> CompletionResult {
        let query = CompletionQuery {
            source: &self.session.source,
            tree: &self.session.tree,
            analysis: Some(&self.session.analysis),
            position,
            profile: self.session.profile,
        };
        complete_at_position_with_edit(&query)
    }

    pub fn definition(&self, position: Position) -> Option<Range> {
        find_definition(&self.session.index, &self.session.source, position)
    }

    pub fn references(&self, position: Position) -> Vec<Range> {
        find_references(&self.session.index, &self.session.source, position)
    }

    pub fn highlights(&self, position: Position) -> Vec<DocumentHighlight> {
        document_highlights(&self.session.index, &self.session.source, position)
    }

    pub fn symbols(&self) -> Vec<DocumentSymbolEntry> {
        document_symbols(
            &self.session.analysis,
            &self.session.index,
            &self.session.source,
        )
    }

    pub fn hover(&self, position: Position) -> Option<HoverOutcome> {
        hover_at_position(&self.session.query_context(), position)
    }

    pub fn signature_help(&self, position: Position) -> Option<SignatureHelp> {
        signature_help_at_position(&self.session.query_context(), position)
    }
}

pub struct LanguageService {
    sessions: BTreeMap<String, DocumentSession>,
}

impl Default for LanguageService {
    fn default() -> Self {
        Self::new()
    }
}

impl LanguageService {
    pub fn new() -> Self {
        Self {
            sessions: BTreeMap::new(),
        }
    }

    pub fn open_document(&mut self, uri: String, text: String, options: DocumentOptions) {
        let session = DocumentSession::new(text, options.profile, options.strict);
        self.sessions.insert(uri, session);
    }

    pub fn edit_document(&mut self, uri: &str, new_text: String) -> Option<PartitionReport> {
        let session = self.sessions.get_mut(uri)?;
        Some(session.apply_edit(new_text))
    }

    pub fn edit_document_ranges(
        &mut self,
        uri: &str,
        edits: &[TextEdit],
    ) -> Option<PartitionReport> {
        let session = self.sessions.get_mut(uri)?;
        Some(session.apply_text_edits(edits))
    }

    pub fn close_document(&mut self, uri: &str) -> bool {
        self.sessions.remove(uri).is_some()
    }

    pub fn session(&self, uri: &str) -> Option<&DocumentSession> {
        self.sessions.get(uri)
    }

    pub fn format_text(&self, text: &str, options: FormatOptions) -> String {
        format_source(text, options)
    }
}
