use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parse_expression(state: &mut ParserState<'_>, minimum: u8) -> Result<usize, ()> {
    let mut left = prefix(state)?;
    while let Some((binding, right_binding, kind)) = binding(state.kind()) {
        if binding < minimum {
            break;
        }
        let operator = state.token();
        let node = state.nodes.get(left).ok_or(())?;
        let marker = left
            .saturating_add(1)
            .saturating_sub(usize::try_from(node.subtree_size).unwrap_or(1));
        let start = node.first_token;
        let recursive_power = kind == NodeKind::PowerExpression;
        if recursive_power {
            state.enter()?;
        }
        state.advance();
        let right = parse_expression(state, right_binding);
        if recursive_power {
            state.leave();
        }
        right?;
        left = state.finish(kind, start, marker);
        if let Some(slot) = state.operators.get_mut(left) {
            *slot = Some(operator);
        }
    }
    Ok(left)
}

fn prefix(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    if matches!(
        state.kind(),
        TokenKind::Plus
            | TokenKind::Minus
            | TokenKind::LogicalNot
            | TokenKind::Keyword(KeywordKind::Not)
    ) {
        state.enter()?;
        state.advance();
        let result = parse_expression(state, 80);
        state.leave();
        result?;
        let node = state.finish(NodeKind::Unary, start, marker);
        if let Some(slot) = state.operators.get_mut(node) {
            *slot = Some(start);
        }
        return Ok(node);
    }
    let primary = primary(state)?;
    crate::postfix_parser::parse_postfix(state, primary)
}

fn primary(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    let kind = state.kind();
    if kind.is_literal() {
        state.advance();
        return Ok(state.finish(NodeKind::Literal, start, marker));
    }
    if kind == TokenKind::Identifier {
        state.advance();
        return Ok(state.finish(NodeKind::Identifier, start, marker));
    }
    if kind == TokenKind::LeftParenthesis {
        return grouping(state);
    }
    if kind == TokenKind::Keyword(KeywordKind::NewInstance) {
        return instance(state);
    }
    if matches!(
        kind,
        TokenKind::Keyword(KeywordKind::ThisObject | KeywordKind::SuperClass)
    ) {
        return receiver(state);
    }
    let span = state.span();
    if !state.lexical_gap {
        state.report(DiagnosticCode::ExpectedExpression, span);
    }
    Err(())
}

fn grouping(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.enter()?;
    state.advance();
    if state.eat(TokenKind::RightParenthesis) {
        let span = state
            .tokens
            .span(usize::try_from(start).unwrap_or(0))
            .unwrap_or_default();
        state.report(DiagnosticCode::EmptyParentheses, span);
        state.leave();
        return Err(());
    }
    let result = parse_expression(state, 0);
    state.leave();
    result?;
    state.require(
        TokenKind::RightParenthesis,
        DiagnosticCode::UnclosedParenthesis,
    )?;
    Ok(state.finish(NodeKind::Primary, start, marker))
}

fn instance(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    crate::declaration_parser::name(state, DiagnosticCode::ExpectedClassName)?;
    if state.kind() != TokenKind::LeftParenthesis {
        let span = state.span();
        state.report(DiagnosticCode::MissingInstantiationParentheses, span);
        return Err(());
    }
    crate::postfix_parser::arguments(state)?;
    Ok(state.finish(NodeKind::Instantiation, start, marker))
}

fn receiver(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    let is_this = state.kind() == TokenKind::Keyword(KeywordKind::ThisObject);
    if !state.inside_method {
        let code = if is_this {
            DiagnosticCode::ThisOutsideMethod
        } else {
            DiagnosticCode::SuperOutsideMethod
        };
        let span = state.span();
        state.report(code, span);
        return Err(());
    }
    if !is_this && !state.has_superclass {
        let span = state.span();
        state.report(DiagnosticCode::SuperInClassWithoutSuperclass, span);
        return Err(());
    }
    state.advance();
    Ok(state.finish(
        if is_this {
            NodeKind::ThisObject
        } else {
            NodeKind::SuperClass
        },
        start,
        marker,
    ))
}

fn binding(kind: TokenKind) -> Option<(u8, u8, NodeKind)> {
    match kind {
        TokenKind::LogicalOr | TokenKind::Keyword(KeywordKind::Or) => {
            Some((10, 11, NodeKind::Disjunction))
        }
        TokenKind::LogicalAnd | TokenKind::Keyword(KeywordKind::And) => {
            Some((20, 21, NodeKind::Conjunction))
        }
        TokenKind::Equal | TokenKind::NotEqual => Some((30, 31, NodeKind::Equality)),
        TokenKind::Less | TokenKind::LessEqual | TokenKind::Greater | TokenKind::GreaterEqual => {
            Some((40, 41, NodeKind::Ordering))
        }
        TokenKind::Plus | TokenKind::Minus => Some((50, 51, NodeKind::Addition)),
        TokenKind::Star
        | TokenKind::Slash
        | TokenKind::IntegerDivision
        | TokenKind::Modulo
        | TokenKind::Keyword(KeywordKind::Modulo | KeywordKind::IntegerDivide) => {
            Some((60, 61, NodeKind::Multiplication))
        }
        TokenKind::Power => Some((70, 70, NodeKind::PowerExpression)),
        _ => None,
    }
}
