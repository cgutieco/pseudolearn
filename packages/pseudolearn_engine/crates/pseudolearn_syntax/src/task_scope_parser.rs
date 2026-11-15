use crate::declaration_parser::name;
use crate::parser_state::ParserState;
use crate::statement_parser::parse_statement_block;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parse(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    if state.kind() == TokenKind::Identifier {
        name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    }
    parse_statement_block(state);
    state.close(
        KeywordKind::EndTasks,
        DiagnosticCode::UnclosedTaskScope,
        start,
    );
    Ok(state.finish(NodeKind::TaskScope, start, marker))
}

pub(crate) fn spawn_statement(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    spawn_expression(state)?;
    Ok(state.finish(NodeKind::SpawnStatement, start, marker))
}

pub(crate) fn spawn_expression(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedExpression)?;
    crate::postfix_parser::arguments(state)?;
    Ok(state.finish(NodeKind::SpawnExpression, start, marker))
}
