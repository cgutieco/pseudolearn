use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parse(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    state.separators();
    while starts_branch(state) {
        branch(state)?;
        state.separators();
    }
    state.close(
        KeywordKind::EndSelect,
        DiagnosticCode::UnclosedSwitchStatement,
        start,
    );
    Ok(state.finish(NodeKind::SelectStatement, start, marker))
}

fn branch(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    crate::declaration_parser::name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    if !crate::contextual::eat(state, "receiveSource") {
        let span = state.span();
        state.report(DiagnosticCode::ExpectedExpression, span);
        return Err(());
    }
    crate::expression_parser::parse_expression(state, 0)?;
    state.require(TokenKind::Colon, DiagnosticCode::ExpectedExpression)?;
    crate::statement_parser::body_until(state, |state| {
        crate::statement_parser::boundary(state.kind()) || starts_branch(state)
    });
    Ok(state.finish(NodeKind::ReceiveBranch, start, marker))
}

fn starts_branch(state: &mut ParserState<'_>) -> bool {
    if !crate::contextual::matches(state, "channelReceive") {
        return false;
    }
    let cursor = state.cursor;
    state.advance();
    let binding = state.kind() == TokenKind::Identifier;
    state.advance();
    let source = crate::contextual::matches(state, "receiveSource");
    state.cursor = cursor;
    binding && source
}
