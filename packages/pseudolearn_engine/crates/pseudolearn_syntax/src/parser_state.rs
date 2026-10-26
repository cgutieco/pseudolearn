use crate::tokens::{TokenKind, Tokens};
use crate::tree::{ANALYSIS_NESTING_LIMIT, NodeKind, SyntaxNode, SyntaxTree};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::Span;
use std::ops::Range;

pub(crate) struct ParserState<'tokens> {
    pub tokens: &'tokens Tokens,
    pub source: &'tokens str,
    pub cursor: usize,
    pub nodes: Vec<SyntaxNode>,
    pub endings: Vec<u32>,
    pub operators: Vec<Option<u32>>,
    pub child_ranges: Vec<Range<usize>>,
    pub children: Vec<usize>,
    pub diagnostics: Vec<Diagnostic>,
    pub depth: u32,
    pub halted: bool,
    pub unclosed: bool,
    pub lexical_gap: bool,
    pub unit_context: NodeKind,
    pub has_superclass: bool,
    pub inside_method: bool,
    pub terminator_diagnostic: Option<DiagnosticCode>,
    pub project_mode: bool,
    pub profile: pseudolearn_lexicon::Profile,
}

impl<'tokens> ParserState<'tokens> {
    pub(crate) fn new(tokens: &'tokens Tokens, source: &'tokens str) -> Self {
        Self {
            tokens,
            source,
            cursor: 0,
            nodes: Vec::new(),
            endings: Vec::new(),
            operators: Vec::new(),
            child_ranges: Vec::new(),
            children: Vec::new(),
            diagnostics: Vec::new(),
            depth: 0,
            halted: false,
            unclosed: false,
            lexical_gap: false,
            unit_context: NodeKind::Program,
            has_superclass: false,
            inside_method: false,
            terminator_diagnostic: None,
            project_mode: false,
            profile: pseudolearn_lexicon::Profile::Spanish,
        }
    }

    pub(crate) fn kind(&mut self) -> TokenKind {
        while matches!(
            self.tokens.kind(self.cursor),
            Some(TokenKind::Whitespace | TokenKind::Comment | TokenKind::InvalidCharacter)
        ) {
            self.lexical_gap |= self.tokens.kind(self.cursor) == Some(TokenKind::InvalidCharacter);
            self.cursor = self.cursor.saturating_add(1);
        }
        self.tokens
            .kind(self.cursor)
            .unwrap_or(TokenKind::EndOfFile)
    }

    pub(crate) fn span(&mut self) -> Span {
        self.kind();
        self.tokens.span(self.cursor).unwrap_or(Span::new(0, 0))
    }

    pub(crate) fn advance(&mut self) {
        self.cursor = self.cursor.saturating_add(1).min(self.tokens.token_count());
    }

    pub(crate) fn eat(&mut self, kind: TokenKind) -> bool {
        if self.kind() != kind {
            return false;
        }
        self.advance();
        true
    }

    pub(crate) fn keyword(&mut self, kind: KeywordKind) -> bool {
        self.eat(TokenKind::Keyword(kind))
    }

    pub(crate) fn separators(&mut self) {
        while matches!(self.kind(), TokenKind::Newline | TokenKind::Semicolon) {
            self.advance();
        }
    }
}

impl ParserState<'_> {
    pub(crate) fn token(&mut self) -> u32 {
        self.kind();
        u32::try_from(self.cursor).unwrap_or(u32::MAX)
    }

    pub(crate) fn report(&mut self, code: DiagnosticCode, span: Span) {
        if self.halted || self.diagnostics.len() > 100 {
            return;
        }
        if self.diagnostics.len() == 100 {
            self.diagnostics.push(Diagnostic::new(
                DiagnosticCode::MaxDiagnosticsExceeded,
                span,
            ));
            return;
        }
        let mut diagnostic = Diagnostic::new(code, span);
        if code.argument_kind("lexeme").is_some() {
            let lexeme = usize::try_from(span.start)
                .ok()
                .zip(usize::try_from(span.ending).ok())
                .and_then(|(start, ending)| self.source.get(start..ending))
                .unwrap_or("");
            diagnostic = diagnostic.with_argument("lexeme", lexeme);
        }
        self.diagnostics.push(diagnostic);
    }

    pub(crate) fn require(&mut self, kind: TokenKind, code: DiagnosticCode) -> Result<(), ()> {
        if self.eat(kind) {
            return Ok(());
        }
        let span = self.span();
        if !self.lexical_gap {
            self.report(code, span);
        }
        Err(())
    }

    pub(crate) fn enter(&mut self) -> Result<(), ()> {
        if self.depth >= ANALYSIS_NESTING_LIMIT {
            let span = self.span();
            self.report(DiagnosticCode::AnalysisNestingLimitExceeded, span);
            if let Some(diagnostic) = self.diagnostics.last_mut().filter(|diagnostic| {
                diagnostic.code == DiagnosticCode::AnalysisNestingLimitExceeded
            }) {
                diagnostic.arguments.insert(
                    "limit".to_owned(),
                    pseudolearn_diagnostics::DiagnosticArgument::Number(
                        ANALYSIS_NESTING_LIMIT.into(),
                    ),
                );
            }
            self.halted = true;
            self.cursor = self.tokens.token_count().saturating_sub(1);
            return Err(());
        }
        self.depth = self.depth.saturating_add(1);
        Ok(())
    }

    pub(crate) fn leave(&mut self) {
        self.depth = self.depth.saturating_sub(1);
    }

    pub(crate) fn text(&self, token: u32) -> &str {
        usize::try_from(token)
            .ok()
            .and_then(|index| self.tokens.text(self.source, index))
            .unwrap_or("")
    }
}

impl ParserState<'_> {
    pub(crate) fn finish(&mut self, kind: NodeKind, start: u32, marker: usize) -> usize {
        let index = self.nodes.len();
        let begin = self.children.len();
        let mut cursor = index;
        while cursor > marker {
            let child = cursor.saturating_sub(1);
            let size = self
                .nodes
                .get(child)
                .map_or(1, |node| usize::try_from(node.subtree_size).unwrap_or(1));
            self.children.push(child);
            cursor = cursor.saturating_sub(size.max(1));
        }
        if let Some(children) = self.children.get_mut(begin..) {
            children.reverse();
        }
        self.child_ranges.push(begin..self.children.len());
        self.nodes.push(SyntaxNode {
            kind,
            first_token: start,
            subtree_size: u32::try_from(index.saturating_sub(marker).saturating_add(1))
                .unwrap_or(u32::MAX),
        });
        self.endings
            .push(u32::try_from(self.cursor.saturating_sub(1)).unwrap_or(0));
        self.operators.push(None);
        index
    }

    pub(crate) fn close(&mut self, closing: KeywordKind, code: DiagnosticCode, opening: u32) {
        if self.keyword(closing) || self.unclosed || self.halted {
            return;
        }
        let span = self.span();
        self.report(code, span);
        let opening = usize::try_from(opening)
            .ok()
            .and_then(|index| self.tokens.span(index));
        if let (Some(diagnostic), Some(opening)) = (self.diagnostics.last_mut(), opening) {
            diagnostic.related.push(opening);
        }
        self.unclosed = true;
    }

    pub(crate) fn into_tree(self) -> (SyntaxTree, Vec<Diagnostic>) {
        let tree = SyntaxTree {
            nodes: self.nodes,
            has_errors: !self.diagnostics.is_empty(),
            tokens: self.tokens.clone(),
            ending_tokens: self.endings,
            operator_tokens: self.operators,
            child_ranges: self.child_ranges,
            children: self.children,
        };
        (tree, self.diagnostics)
    }
}
