use crate::declaration_parser::{name, parse_type};
use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn constant(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedConstantName)?;
    state.require(
        TokenKind::Keyword(KeywordKind::TypeConnector),
        DiagnosticCode::ExpectedTypeConnector,
    )?;
    parse_type(state)?;
    state.require(
        TokenKind::Assignment,
        DiagnosticCode::ExpectedConstantInitializer,
    )?;
    parse_expression(state, 0)?;
    Ok(state.finish(NodeKind::ConstantDeclaration, start, marker))
}
