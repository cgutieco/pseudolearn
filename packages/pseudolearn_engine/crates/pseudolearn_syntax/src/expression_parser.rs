use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::KeywordKind;

pub fn parse_expression(
    parser_state: &mut ParserState<'_>,
    minimum_binding_power: u8,
) -> Option<usize> {
    if !parser_state.enter_recursion() {
        return None;
    }
    let mut left_node_index = parse_prefix_or_primary(parser_state)?;

    loop {
        parser_state.skip_trivia();
        let (left_power, right_power) = match infix_binding_power(parser_state.current_kind()) {
            Some(powers) => powers,
            None => break,
        };
        if left_power < minimum_binding_power {
            break;
        }
        let first_token = parser_state.nodes.get(left_node_index)?.first_token;
        parser_state.advance();
        parser_state.skip_trivia_and_newlines();
        let _right_node_index = parse_expression(parser_state, right_power)?;
        let total_subtrees = parser_state.nodes.len().saturating_sub(left_node_index);
        let subtree_size = u32::try_from(total_subtrees.saturating_add(1)).unwrap_or(1);
        let binary_index =
            parser_state.push_node(NodeKind::BinaryExpression, first_token, subtree_size);
        left_node_index = binary_index;
    }

    parser_state.exit_recursion();
    Some(left_node_index)
}

fn parse_prefix_or_primary(parser_state: &mut ParserState<'_>) -> Option<usize> {
    parser_state.skip_trivia_and_newlines();
    let current_kind = parser_state.current_kind();
    if let Some(prefix_power) = prefix_binding_power(current_kind) {
        let first_token = parser_state.current_token_u32();
        parser_state.advance();
        parser_state.skip_trivia_and_newlines();
        let operand_index = parse_expression(parser_state, prefix_power)?;
        let total_subtrees = parser_state.nodes.len().saturating_sub(operand_index);
        let subtree_size = u32::try_from(total_subtrees.saturating_add(1)).unwrap_or(1);
        return Some(parser_state.push_node(NodeKind::UnaryExpression, first_token, subtree_size));
    }
    parse_primary_and_postfix(parser_state)
}

fn parse_primary_and_postfix(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let mut primary_index = parse_primary(parser_state)?;
    loop {
        parser_state.skip_trivia();
        match parser_state.current_kind() {
            TokenKind::LeftBracket => {
                primary_index = parse_indexing(parser_state, primary_index)?;
            }
            TokenKind::LeftParenthesis => {
                primary_index = parse_call(parser_state, primary_index)?;
            }
            TokenKind::Dot => {
                primary_index = parse_member_access(parser_state, primary_index)?;
            }
            _ => break,
        }
    }
    Some(primary_index)
}

fn parse_primary(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    let current_kind = parser_state.current_kind();
    if current_kind.is_literal() {
        parser_state.advance();
        return Some(parser_state.push_node(NodeKind::LiteralExpression, first_token, 1));
    }
    if current_kind == TokenKind::Identifier {
        parser_state.advance();
        return Some(parser_state.push_node(NodeKind::IdentifierExpression, first_token, 1));
    }
    if current_kind == TokenKind::LeftParenthesis {
        parser_state.advance();
        parser_state.skip_trivia_and_newlines();
        let inner_expression = parse_expression(parser_state, 0)?;
        if !parser_state.expect(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        ) {
            return None;
        }
        return Some(inner_expression);
    }
    let span = parser_state.current_span();
    parser_state
        .diagnostics
        .push(Diagnostic::new(DiagnosticCode::ExpectedExpression, span));
    None
}

fn parse_indexing(parser_state: &mut ParserState<'_>, target_node_index: usize) -> Option<usize> {
    let first_token = parser_state.nodes.get(target_node_index)?.first_token;
    parser_state.advance();
    parser_state.skip_trivia_and_newlines();
    if parser_state.current_kind() == TokenKind::RightBracket {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::EmptyIndexList, span));
        parser_state.advance();
        return None;
    }
    let _index_expression = parse_expression(parser_state, 0)?;
    while parser_state.eat_if(TokenKind::Comma) {
        parser_state.skip_trivia_and_newlines();
        let _next_index = parse_expression(parser_state, 0)?;
    }
    parser_state.expect(TokenKind::RightBracket, DiagnosticCode::UnclosedBracket);
    let total_subtrees = parser_state.nodes.len().saturating_sub(target_node_index);
    let subtree_size = u32::try_from(total_subtrees.saturating_add(1)).unwrap_or(1);
    Some(parser_state.push_node(NodeKind::IndexingExpression, first_token, subtree_size))
}

fn parse_call(parser_state: &mut ParserState<'_>, target_node_index: usize) -> Option<usize> {
    let first_token = parser_state.nodes.get(target_node_index)?.first_token;
    parser_state.advance();
    parser_state.skip_trivia_and_newlines();
    if !parser_state.eat_if(TokenKind::RightParenthesis) {
        let _first_argument = parse_expression(parser_state, 0)?;
        while parser_state.eat_if(TokenKind::Comma) {
            parser_state.skip_trivia_and_newlines();
            let _next_argument = parse_expression(parser_state, 0)?;
        }
        parser_state.expect(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        );
    }
    let total_subtrees = parser_state.nodes.len().saturating_sub(target_node_index);
    let subtree_size = u32::try_from(total_subtrees.saturating_add(1)).unwrap_or(1);
    Some(parser_state.push_node(NodeKind::CallExpression, first_token, subtree_size))
}

fn parse_member_access(
    parser_state: &mut ParserState<'_>,
    target_node_index: usize,
) -> Option<usize> {
    let first_token = parser_state.nodes.get(target_node_index)?.first_token;
    parser_state.advance();
    parser_state.skip_trivia();
    if parser_state.current_kind() != TokenKind::Identifier {
        let span = parser_state.current_span();
        parser_state.diagnostics.push(Diagnostic::new(
            DiagnosticCode::ExpectedMemberNameAfterDot,
            span,
        ));
        return None;
    }
    parser_state.advance();
    let total_subtrees = parser_state.nodes.len().saturating_sub(target_node_index);
    let subtree_size = u32::try_from(total_subtrees.saturating_add(1)).unwrap_or(1);
    Some(parser_state.push_node(NodeKind::MemberAccessExpression, first_token, subtree_size))
}

fn prefix_binding_power(token_kind: TokenKind) -> Option<u8> {
    match token_kind {
        TokenKind::Plus
        | TokenKind::Minus
        | TokenKind::LogicalNot
        | TokenKind::Keyword(KeywordKind::Not) => Some(70),
        _ => None,
    }
}

fn infix_binding_power(token_kind: TokenKind) -> Option<(u8, u8)> {
    match token_kind {
        TokenKind::LogicalOr | TokenKind::Keyword(KeywordKind::Or) => Some((10, 11)),
        TokenKind::LogicalAnd | TokenKind::Keyword(KeywordKind::And) => Some((20, 21)),
        TokenKind::Equal
        | TokenKind::NotEqual
        | TokenKind::Less
        | TokenKind::LessEqual
        | TokenKind::Greater
        | TokenKind::GreaterEqual => Some((30, 31)),
        TokenKind::Plus | TokenKind::Minus => Some((40, 41)),
        TokenKind::Star
        | TokenKind::Slash
        | TokenKind::Modulo
        | TokenKind::IntegerDivision
        | TokenKind::Keyword(KeywordKind::Modulo) => Some((50, 51)),
        TokenKind::Power => Some((61, 60)),
        _ => None,
    }
}
