use crate::parser_state::ParserState;
use crate::{Lexer, SyntaxTree, TokenKind};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;

pub fn parse_expression_source(
    source: &SourceText,
    profile: Profile,
) -> (SyntaxTree, Vec<Diagnostic>) {
    let (tokens, mut diagnostics) = Lexer::new(source, profile).scan();
    let mut state = ParserState::new(&tokens, source.as_str());
    state.profile = profile;
    let parsed = crate::expression_parser::parse_expression(&mut state, 0);
    if parsed.is_ok() && state.kind() != TokenKind::EndOfFile {
        let span = state.span();
        state.report(DiagnosticCode::ExpectedExpression, span);
    }
    let (mut tree, mut parser_diagnostics) = state.into_tree();
    diagnostics.append(&mut parser_diagnostics);
    tree.has_errors = !diagnostics.is_empty() || parsed.is_err();
    (tree, diagnostics)
}
