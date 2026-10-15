use crate::tokens::{TokenKind, Tokens};
use crate::tree::{NodeKind, SyntaxNode};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_source::Span;

const MAXIMUM_RECURSION_DEPTH: u32 = 256;

pub(crate) struct ParserState<'tokens> {
    pub(crate) tokens: &'tokens Tokens,
    pub(crate) cursor: usize,
    pub(crate) nodes: Vec<SyntaxNode>,
    pub(crate) diagnostics: Vec<Diagnostic>,
    pub(crate) recursion_depth: u32,
}

impl<'tokens> ParserState<'tokens> {
    pub(crate) fn new(tokens: &'tokens Tokens) -> Self {
        Self {
            tokens,
            cursor: 0,
            nodes: Vec::new(),
            diagnostics: Vec::new(),
            recursion_depth: 0,
        }
    }

    pub(crate) fn skip_trivia(&mut self) {
        while self.cursor < self.tokens.token_count() {
            let kind = self
                .tokens
                .kind(self.cursor)
                .unwrap_or(TokenKind::EndOfFile);
            if kind == TokenKind::Whitespace || kind == TokenKind::Comment {
                self.cursor = self.cursor.saturating_add(1);
            } else {
                break;
            }
        }
    }

    pub(crate) fn skip_trivia_and_newlines(&mut self) {
        while self.cursor < self.tokens.token_count() {
            let kind = self
                .tokens
                .kind(self.cursor)
                .unwrap_or(TokenKind::EndOfFile);
            if kind.is_trivia() {
                self.cursor = self.cursor.saturating_add(1);
            } else {
                break;
            }
        }
    }

    pub(crate) fn current_kind(&mut self) -> TokenKind {
        self.skip_trivia();
        self.tokens
            .kind(self.cursor)
            .unwrap_or(TokenKind::EndOfFile)
    }

    pub(crate) fn current_token_index(&mut self) -> usize {
        self.skip_trivia();
        self.cursor
    }

    pub(crate) fn current_token_u32(&mut self) -> u32 {
        let index = self.current_token_index();
        u32::try_from(index).unwrap_or(u32::MAX)
    }

    pub(crate) fn current_span(&mut self) -> Span {
        let index = self.current_token_index();
        self.tokens.span(index).unwrap_or(Span::new(0, 0))
    }

    pub(crate) fn advance(&mut self) {
        if self.cursor < self.tokens.token_count() {
            self.cursor = self.cursor.saturating_add(1);
        }
    }

    pub(crate) fn eat_if(&mut self, expected_kind: TokenKind) -> bool {
        if self.current_kind() == expected_kind {
            self.advance();
            true
        } else {
            false
        }
    }

    pub(crate) fn expect(&mut self, expected_kind: TokenKind, code: DiagnosticCode) -> bool {
        if self.current_kind() == expected_kind {
            self.advance();
            true
        } else {
            let span = self.current_span();
            self.diagnostics.push(Diagnostic::new(code, span));
            false
        }
    }

    pub(crate) fn push_node(
        &mut self,
        kind: NodeKind,
        first_token: u32,
        subtree_size: u32,
    ) -> usize {
        let node_index = self.nodes.len();
        self.nodes
            .push(SyntaxNode::new(kind, first_token, subtree_size));
        node_index
    }

    pub(crate) fn enter_recursion(&mut self) -> bool {
        self.recursion_depth = self.recursion_depth.saturating_add(1);
        if self.recursion_depth > MAXIMUM_RECURSION_DEPTH {
            let span = self.current_span();
            self.diagnostics.push(Diagnostic::new(
                DiagnosticCode::RecursionDepthExceeded,
                span,
            ));
            false
        } else {
            true
        }
    }

    pub(crate) fn exit_recursion(&mut self) {
        self.recursion_depth = self.recursion_depth.saturating_sub(1);
    }
}
