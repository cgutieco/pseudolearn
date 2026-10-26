use crate::declaration_parser::{name, parse_type};
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;

pub(crate) fn type_parameters(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    parameter(state)?;
    while state.eat(TokenKind::Comma) {
        parameter(state)?;
    }
    state.require(TokenKind::Greater, DiagnosticCode::ExpectedType)?;
    Ok(state.finish(NodeKind::TypeParameters, start, marker))
}

fn parameter(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    if state.eat(TokenKind::Colon) {
        name(state, DiagnosticCode::ExpectedClassName)?;
    }
    Ok(state.finish(NodeKind::TypeParameter, start, marker))
}

pub(crate) fn type_arguments(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    argument(state)?;
    while state.eat(TokenKind::Comma) {
        argument(state)?;
    }
    state.require(TokenKind::Greater, DiagnosticCode::ExpectedType)?;
    Ok(state.finish(NodeKind::TypeArguments, start, marker))
}

fn argument(state: &mut ParserState<'_>) -> Result<usize, ()> {
    state.enter()?;
    let parsed = parse_type(state);
    state.leave();
    parsed
}

pub(crate) fn optional_parameters(state: &mut ParserState<'_>) -> Result<(), ()> {
    if state.kind() == TokenKind::Less {
        type_parameters(state)?;
    }
    Ok(())
}
