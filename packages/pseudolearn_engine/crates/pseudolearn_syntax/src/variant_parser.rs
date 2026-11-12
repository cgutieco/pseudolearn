use crate::declaration_parser::name;
use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn starts(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Keyword(
            KeywordKind::SomeVariant
                | KeywordKind::NoneVariant
                | KeywordKind::SuccessVariant
                | KeywordKind::ErrorVariant
        )
    )
}

pub(crate) fn construction(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    let empty = state.kind() == TokenKind::Keyword(KeywordKind::NoneVariant);
    state.advance();
    if !empty {
        state.require(
            TokenKind::LeftParenthesis,
            DiagnosticCode::ExpectedExpression,
        )?;
        state.enter()?;
        let expression = parse_expression(state, 0);
        state.leave();
        expression?;
        state.require(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        )?;
    }
    Ok(state.finish(NodeKind::VariantConstruction, start, marker))
}

pub(crate) fn pattern(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    let empty = state.kind() == TokenKind::Keyword(KeywordKind::NoneVariant);
    state.advance();
    if !empty {
        state.require(
            TokenKind::LeftParenthesis,
            DiagnosticCode::ExpectedExpression,
        )?;
        name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
        state.require(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        )?;
    }
    Ok(state.finish(NodeKind::VariantPattern, start, marker))
}

pub(crate) fn propagation(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    state.enter()?;
    let expression = parse_expression(state, 80);
    state.leave();
    expression?;
    Ok(state.finish(NodeKind::Propagation, start, marker))
}

pub(crate) fn discard(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    parse_expression(state, 0)?;
    Ok(state.finish(NodeKind::DiscardStatement, start, marker))
}

pub(crate) fn type_arguments(state: &mut ParserState<'_>, result: bool) -> Result<(), ()> {
    state.require(TokenKind::Less, DiagnosticCode::ExpectedType)?;
    state.enter()?;
    let argument = crate::declaration_parser::parse_type(state);
    state.leave();
    argument?;
    if result {
        state.require(TokenKind::Comma, DiagnosticCode::ExpectedType)?;
        state.enter()?;
        let argument = crate::declaration_parser::parse_type(state);
        state.leave();
        argument?;
    }
    state.require(TokenKind::Greater, DiagnosticCode::ExpectedType)?;
    Ok(())
}
