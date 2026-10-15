use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parse_postfix(state: &mut ParserState<'_>, mut target: usize) -> Result<usize, ()> {
    let node = state.nodes.get(target).ok_or(())?;
    let marker = target
        .saturating_add(1)
        .saturating_sub(usize::try_from(node.subtree_size).unwrap_or(1));
    let start = node.first_token;
    let mut indexed = false;
    loop {
        let operator = state.token();
        match state.kind() {
            TokenKind::LeftParenthesis => {
                arguments(state)?;
            }
            TokenKind::LeftBracket => {
                index(state, indexed)?;
                indexed = true;
            }
            TokenKind::Dot => {
                member(state)?;
                indexed = false;
            }
            _ => break,
        }
        target = state.finish(NodeKind::Postfix, start, marker);
        if let Some(slot) = state.operators.get_mut(target) {
            *slot = Some(operator);
        }
    }
    Ok(target)
}

pub(crate) fn arguments(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.require(
        TokenKind::LeftParenthesis,
        DiagnosticCode::ExpectedExpression,
    )?;
    if !state.eat(TokenKind::RightParenthesis) {
        expression_list(state)?;
        state.require(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        )?;
    }
    Ok(state.finish(NodeKind::Arguments, start, marker))
}

pub(crate) fn expression_list(state: &mut ParserState<'_>) -> Result<(), ()> {
    parse_expression(state, 0)?;
    while state.eat(TokenKind::Comma) {
        parse_expression(state, 0)?;
    }
    Ok(())
}

fn index(state: &mut ParserState<'_>, indexed: bool) -> Result<(), ()> {
    if indexed {
        let span = state.span();
        state.report(DiagnosticCode::ChainedArrayAccess, span);
        return Err(());
    }
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    if state.kind() == TokenKind::RightBracket {
        let span = state.span();
        state.report(DiagnosticCode::EmptyIndexList, span);
        return Err(());
    }
    expression_list(state)?;
    state.require(TokenKind::RightBracket, DiagnosticCode::UnclosedBracket)?;
    state.finish(NodeKind::Expressions, start, marker);
    Ok(())
}

fn member(state: &mut ParserState<'_>) -> Result<(), ()> {
    state.advance();
    if state.kind() == TokenKind::Keyword(KeywordKind::Constructor) {
        let start = state.token();
        let marker = state.nodes.len();
        state.advance();
        state.finish(NodeKind::Identifier, start, marker);
    } else {
        crate::declaration_parser::name(state, DiagnosticCode::ExpectedMemberNameAfterDot)?;
    }
    if state.kind() == TokenKind::LeftParenthesis {
        arguments(state)?;
    }
    Ok(())
}
