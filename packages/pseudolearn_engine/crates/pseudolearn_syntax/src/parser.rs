use crate::parser_state::ParserState;
use crate::statement_parser::parse_statement_block;
use crate::tokens::{TokenKind, Tokens};
use crate::tree::{NodeKind, SyntaxTree};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::KeywordKind;
pub struct Parser<'tokens> {
    state: ParserState<'tokens>,
}

impl<'tokens> Parser<'tokens> {
    pub fn new(tokens: &'tokens Tokens) -> Self {
        Self {
            state: ParserState::new(tokens),
        }
    }

    pub fn parse(mut self) -> (SyntaxTree, Vec<Diagnostic>) {
        while self.state.current_kind() != TokenKind::EndOfFile {
            let before = self.state.current_token_u32();
            self.state.skip_trivia_and_newlines();
            let kind = self.state.current_kind();
            if kind == TokenKind::EndOfFile {
                break;
            }
            match kind {
                TokenKind::Keyword(KeywordKind::Algorithm) => {
                    self.parse_algorithm_unit();
                }
                TokenKind::Keyword(KeywordKind::Subroutine) => {
                    self.parse_subroutine_unit();
                }
                TokenKind::Keyword(KeywordKind::ClassKeyword) => {
                    self.parse_class_unit();
                }
                _ => {
                    self.parse_top_level_block();
                }
            }
            if self.state.current_token_u32() == before
                && self.state.current_kind() != TokenKind::EndOfFile
            {
                self.state.advance();
            }
        }
        (
            SyntaxTree::new(self.state.nodes, self.state.tokens.clone()),
            self.state.diagnostics,
        )
    }

    fn parse_algorithm_unit(&mut self) {
        let first_token = self.state.current_token_u32();
        self.state.advance();
        self.state.skip_trivia();
        if self.state.current_kind() != TokenKind::Identifier {
            let span = self.state.current_span();
            self.state
                .diagnostics
                .push(Diagnostic::new(DiagnosticCode::ExpectedAlgorithmName, span));
        } else {
            self.state.advance();
        }
        parse_statement_block(&mut self.state);
        if !self
            .state
            .eat_if(TokenKind::Keyword(KeywordKind::EndAlgorithm))
        {
            let span = self.state.current_span();
            self.state
                .diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnclosedAlgorithm, span));
        }
        self.state.push_node(NodeKind::ProgramUnit, first_token, 1);
    }

    fn parse_subroutine_unit(&mut self) {
        let first_token = self.state.current_token_u32();
        self.state.advance();
        self.state.skip_trivia();
        if self.state.current_kind() == TokenKind::Identifier {
            self.state.advance();
            self.state.skip_trivia();
            if self.state.eat_if(TokenKind::Assignment) {
                self.state.skip_trivia();
                if self.state.current_kind() == TokenKind::Identifier {
                    self.state.advance();
                }
            }
        }
        self.parse_formal_parameters();
        parse_statement_block(&mut self.state);
        if !self
            .state
            .eat_if(TokenKind::Keyword(KeywordKind::EndSubroutine))
        {
            let span = self.state.current_span();
            self.state
                .diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnclosedSubroutine, span));
        }
        self.state.push_node(NodeKind::FunctionUnit, first_token, 1);
    }

    fn parse_class_unit(&mut self) {
        let first_token = self.state.current_token_u32();
        self.state.advance();
        self.state.skip_trivia();
        if self.state.current_kind() == TokenKind::Identifier {
            self.state.advance();
        }
        parse_statement_block(&mut self.state);
        if !self.state.eat_if(TokenKind::Keyword(KeywordKind::EndClass)) {
            let span = self.state.current_span();
            self.state
                .diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnclosedClass, span));
        }
        self.state.push_node(NodeKind::ClassUnit, first_token, 1);
    }

    fn parse_top_level_block(&mut self) {
        let first_token = self.state.current_token_u32();
        parse_statement_block(&mut self.state);
        if self.state.current_token_u32() == first_token
            && self.state.current_kind() != TokenKind::EndOfFile
        {
            self.state.advance();
        }
        self.state.push_node(NodeKind::ProgramUnit, first_token, 1);
    }

    fn parse_formal_parameters(&mut self) {
        self.state.skip_trivia();
        if self.state.eat_if(TokenKind::LeftParenthesis) {
            while self.state.current_kind() == TokenKind::Identifier {
                self.state.advance();
                self.state.skip_trivia();
                self.state.eat_if(TokenKind::Comma);
                self.state.skip_trivia();
            }
            self.state.expect(
                TokenKind::RightParenthesis,
                DiagnosticCode::UnclosedParenthesis,
            );
        }
    }
}
