use crate::parser_state::ParserState;
use crate::tokens::{TokenKind, Tokens};
use crate::tree::{NodeKind, SyntaxTree};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::{KeywordKind, Profile};

pub struct Parser<'tokens> {
    state: ParserState<'tokens>,
    profile: Profile,
}

impl<'tokens> Parser<'tokens> {
    pub fn new(tokens: &'tokens Tokens, source: &'tokens str) -> Self {
        Self {
            state: ParserState::new(tokens, source),
            profile: Profile::Spanish,
        }
    }

    pub(crate) fn with_profile(mut self, profile: Profile) -> Self {
        self.profile = profile;
        self.state.profile = profile;
        self
    }

    pub fn with_terminator(mut self, diagnostic: Option<DiagnosticCode>) -> Self {
        self.state.terminator_diagnostic = diagnostic;
        self
    }

    pub fn with_project_mode(mut self, enabled: bool) -> Self {
        self.state.project_mode = enabled;
        self
    }

    pub fn parse(mut self) -> (SyntaxTree, Vec<Diagnostic>) {
        let mut algorithms = 0_u32;
        let mut units = 0_u32;
        loop {
            self.state.separators();
            if self.state.kind() == TokenKind::EndOfFile {
                break;
            }
            let before = self.state.cursor;
            let opening = self.state.kind();
            let result = self.parse_unit(&mut algorithms, units);
            units = units.saturating_add(u32::from(!crate::module_parser::is_directive(opening)));
            if result.is_err() {
                recover_unit(&mut self.state, opening);
                crate::statement_parser::recover(&mut self.state);
            }
            if self.state.cursor == before {
                self.state.advance();
            }
        }
        if algorithms == 0 && !self.state.halted && !self.state.project_mode {
            let span = self.state.span();
            self.state
                .report(DiagnosticCode::ExpectedAlgorithmStart, span);
        }
        self.state.finish(NodeKind::Program, 0, 0);
        self.state.into_tree()
    }
    fn parse_contextual_unit(&mut self) -> Option<Result<usize, ()>> {
        if crate::interface_parser::starts(&mut self.state) {
            return Some(crate::interface_parser::interface(&mut self.state));
        }
        if crate::module_parser::is_standalone_directive(&mut self.state, self.profile) {
            let span = self.state.span();
            self.state
                .report(DiagnosticCode::ModuleSyntaxOutsideProject, span);
            return Some(Err(()));
        }
        if crate::unsupported::reject(&mut self.state) {
            return Some(Err(()));
        }
        None
    }
    fn parse_unit(&mut self, algorithms: &mut u32, units: u32) -> Result<usize, ()> {
        if let Some(result) = self.parse_contextual_unit() {
            return result;
        }
        let kind = self.state.kind();
        if crate::module_parser::is_directive(kind) && units == 0 {
            return crate::module_parser::directive(&mut self.state);
        }
        if crate::module_parser::is_visibility(kind) {
            return self.parse_visible_unit();
        }
        match kind {
            TokenKind::Keyword(KeywordKind::Algorithm) => self.parse_algorithm(algorithms),
            TokenKind::Keyword(KeywordKind::Subroutine) => {
                crate::unit_parser::subprogram(&mut self.state)
            }
            TokenKind::Keyword(KeywordKind::ClassKeyword) => {
                crate::unit_parser::class(&mut self.state)
            }
            TokenKind::Keyword(KeywordKind::EnumKeyword) => {
                crate::enum_parser::enumeration(&mut self.state)
            }
            TokenKind::Keyword(KeywordKind::RecordKeyword) => {
                crate::record_parser::record(&mut self.state)
            }
            TokenKind::Keyword(KeywordKind::ConstantKeyword) => self.parse_constant_unit(),
            _ => {
                let span = self.state.span();
                self.state
                    .report(DiagnosticCode::UnexpectedTokenOutsideProgramUnit, span);
                Err(())
            }
        }
    }

    fn parse_algorithm(&mut self, algorithms: &mut u32) -> Result<usize, ()> {
        *algorithms = algorithms.saturating_add(1);
        if *algorithms > 1 {
            let span = self.state.span();
            self.state.report(DiagnosticCode::MultipleAlgorithms, span);
        }
        crate::unit_parser::algorithm(&mut self.state)
    }

    fn parse_constant_unit(&mut self) -> Result<usize, ()> {
        let unit = crate::constant_parser::constant(&mut self.state)?;
        crate::statement_parser::terminator(&mut self.state)?;
        Ok(unit)
    }

    fn parse_visible_unit(&mut self) -> Result<usize, ()> {
        let prefix = crate::module_parser::visibility_prefix(&mut self.state)?;
        let opening = self.state.kind();
        let unit = match opening {
            TokenKind::Keyword(KeywordKind::ClassKeyword) => {
                crate::unit_parser::class(&mut self.state)
            }
            TokenKind::Keyword(KeywordKind::Subroutine) => {
                crate::unit_parser::subprogram(&mut self.state)
            }
            _ => {
                let span = self.state.span();
                self.state
                    .report(DiagnosticCode::UnexpectedTokenOutsideProgramUnit, span);
                Err(())
            }
        }?;
        if let (Some(token), Some(node)) = (prefix, self.state.nodes.get_mut(unit)) {
            node.first_token = token;
        }
        Ok(unit)
    }
}

pub(crate) fn recover_unit(state: &mut ParserState<'_>, opening: TokenKind) {
    let closing = match opening {
        TokenKind::Keyword(KeywordKind::Algorithm) => KeywordKind::EndAlgorithm,
        TokenKind::Keyword(KeywordKind::ClassKeyword) => KeywordKind::EndClass,
        TokenKind::Keyword(KeywordKind::EnumKeyword) => KeywordKind::EndEnum,
        TokenKind::Keyword(KeywordKind::RecordKeyword) => KeywordKind::EndRecord,
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
                KeywordKind::Algorithm
                    | KeywordKind::Subroutine
                    | KeywordKind::ClassKeyword
                    | KeywordKind::EnumKeyword
                    | KeywordKind::RecordKeyword
                    | KeywordKind::ConstantKeyword
            )
        ) {
            break;
        }
        state.advance();
    }
}
