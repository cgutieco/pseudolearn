use crate::completion::{CompletionEntry, CompletionQuery, complete_at_position};
use crate::formatter::{FormatOptions, format_source};
use crate::hover::{HoverOutcome, hover_at_position};
use crate::navigation::{
    DocumentHighlight, Position, Range, document_highlights, find_definition, find_references,
};
use crate::node_identity::{SyntaxNodeId, compute_node_identities};
use crate::unit_partition::{
    PartitionReport, UnitFingerprint, compare_partitions, partition_units,
};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, ServiceAnalysis, analyze_for_service};
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{SyntaxTree, parse_source};
use std::collections::BTreeMap;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct DocumentOptions {
    pub profile: Profile,
    pub strict: bool,
}

pub struct DocumentSession {
    pub source: SourceText,
    pub tree: SyntaxTree,
    pub analysis: ServiceAnalysis,
    pub units: Vec<UnitFingerprint>,
    pub profile: Profile,
    pub strict: bool,
}

impl DocumentSession {
    pub fn new(text: String, profile: Profile, strict: bool) -> Self {
        let source = SourceText::new(text);
        let (tree, _) = parse_source(&source, profile);
        let options = SemanticOptions { profile, strict };
        let analysis = analyze_for_service(&tree, &source, options);
        let units = partition_units(&tree, &source);
        Self {
            source,
            tree,
            analysis,
            units,
            profile,
            strict,
        }
    }

    pub fn apply_edit(&mut self, new_text: String) -> PartitionReport {
        let new_source = SourceText::new(new_text);
        let (new_tree, _) = parse_source(&new_source, self.profile);
        let new_units = partition_units(&new_tree, &new_source);
        let report = compare_partitions(&self.units, &new_units);
        let options = SemanticOptions {
            profile: self.profile,
            strict: self.strict,
        };
        let new_analysis = analyze_for_service(&new_tree, &new_source, options);
        self.source = new_source;
        self.tree = new_tree;
        self.analysis = new_analysis;
        self.units = report.units.clone();
        report
    }

    pub fn complete(&self, position: Position) -> Vec<CompletionEntry> {
        let query = CompletionQuery {
            source: &self.source,
            tree: &self.tree,
            analysis: Some(&self.analysis),
            position,
            profile: self.profile,
        };
        complete_at_position(&query)
    }

    pub fn definition(&self, position: Position) -> Option<Range> {
        find_definition(&self.analysis, &self.source, position)
    }

    pub fn references(&self, position: Position) -> Vec<Range> {
        find_references(&self.analysis, &self.source, position)
    }

    pub fn highlights(&self, position: Position) -> Vec<DocumentHighlight> {
        document_highlights(&self.analysis, &self.source, position)
    }

    pub fn hover(&self, position: Position) -> Option<HoverOutcome> {
        hover_at_position(&self.analysis, &self.source, position, self.profile)
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

    pub fn edit_document(&mut self, uri: &str, text: String) -> Option<PartitionReport> {
        let session = self.sessions.get_mut(uri)?;
        Some(session.apply_edit(text))
    }

    pub fn close_document(&mut self, uri: &str) {
        self.sessions.remove(uri);
    }

    pub fn session(&self, uri: &str) -> Option<&DocumentSession> {
        self.sessions.get(uri)
    }

    pub fn format_text(&self, text: &str, options: FormatOptions) -> String {
        format_source(text, options)
    }

    pub fn compute_identities(
        &self,
        tree: &SyntaxTree,
        source: &SourceText,
    ) -> Vec<(SyntaxNodeId, Span)> {
        compute_node_identities(tree, source)
    }
}
