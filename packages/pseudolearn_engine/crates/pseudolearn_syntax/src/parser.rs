use crate::parser_state::ParserState;
use crate::tokens::{TokenKind, Tokens};
use crate::tree::{NodeKind, SyntaxTree};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::KeywordKind;

pub struct Parser<'tokens> {
    state: ParserState<'tokens>,
}

impl<'tokens> Parser<'tokens> {
    pub fn new(tokens: &'tokens Tokens, source: &'tokens str) -> Self {
        Self {
            state: ParserState::new(tokens, source),
        }
    }

    pub fn with_terminator(mut self, diagnostic: Option<DiagnosticCode>) -> Self {
        self.state.terminator_diagnostic = diagnostic;
        self
    }

    pub fn parse(mut self) -> (SyntaxTree, Vec<Diagnostic>) {
        let mut algorithms = 0_u32;
        loop {
            self.state.separators();
            if self.state.kind() == TokenKind::EndOfFile {
                break;
            }
            let before = self.state.cursor;
            let opening = self.state.kind();
            let result = self.parse_unit(&mut algorithms);
            if result.is_err() {
                recover_unit(&mut self.state, opening);
                crate::statement_parser::recover(&mut self.state);
            }
            if self.state.cursor == before {
                self.state.advance();
            }
        }
        if algorithms == 0 && !self.state.halted {
            let span = self.state.span();
            self.state
                .report(DiagnosticCode::ExpectedAlgorithmStart, span);
        }
        self.state.finish(NodeKind::Program, 0, 0);
        self.state.into_tree()
    }
    fn parse_unit(&mut self, algorithms: &mut u32) -> Result<usize, ()> {
        match self.state.kind() {
            TokenKind::Keyword(KeywordKind::Algorithm) => {
                *algorithms = algorithms.saturating_add(1);
                if *algorithms > 1 {
                    let span = self.state.span();
                    self.state.report(DiagnosticCode::MultipleAlgorithms, span);
                }
                crate::unit_parser::algorithm(&mut self.state)
            }
            TokenKind::Keyword(KeywordKind::Subroutine) => {
                crate::unit_parser::subprogram(&mut self.state)
            }
            TokenKind::Keyword(KeywordKind::ClassKeyword) => {
                crate::unit_parser::class(&mut self.state)
            }
            _ => {
                let span = self.state.span();
                self.state
                    .report(DiagnosticCode::UnexpectedTokenOutsideProgramUnit, span);
                Err(())
            }
        }
    }
}

pub(crate) fn recover_unit(state: &mut ParserState<'_>, opening: TokenKind) {
    let closing = match opening {
        TokenKind::Keyword(KeywordKind::Algorithm) => KeywordKind::EndAlgorithm,
        TokenKind::Keyword(KeywordKind::ClassKeyword) => KeywordKind::EndClass,
        TokenKind::Keyword(KeywordKind::Subroutine) => KeywordKind::EndSubroutine,
        TokenKind::Keyword(KeywordKind::IfKeyword) => KeywordKind::EndIf,
        TokenKind::Keyword(KeywordKind::WhileKeyword) => KeywordKind::EndWhile,
        TokenKind::Keyword(KeywordKind::Repeat) => KeywordKind::Until,
        TokenKind::Keyword(KeywordKind::ForKeyword) => KeywordKind::EndFor,
        TokenKind::Keyword(KeywordKind::SwitchKeyword) => KeywordKind::EndSwitch,
        _ => return,
    };
    while state.kind() != TokenKind::EndOfFile {
        if state.keyword(closing) {
            break;
        }
        if matches!(
            state.kind(),
            TokenKind::Keyword(
                KeywordKind::Algorithm | KeywordKind::Subroutine | KeywordKind::ClassKeyword
            )
        ) {
            break;
        }
        state.advance();
    }
}
