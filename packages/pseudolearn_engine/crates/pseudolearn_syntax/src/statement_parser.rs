use crate::control_statement_parser::{
    parse_for_statement, parse_if_statement, parse_repeat_statement, parse_switch_statement,
    parse_while_statement,
};
use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parse_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    parser_state.skip_trivia();
    let current_kind = parser_state.current_kind();
    match current_kind {
        TokenKind::Keyword(KeywordKind::Declare) => parse_define_statement(parser_state),
        TokenKind::Keyword(KeywordKind::Dimension) => parse_dimension_statement(parser_state),
        TokenKind::Keyword(KeywordKind::IfKeyword) => parse_if_statement(parser_state),
        TokenKind::Keyword(KeywordKind::WhileKeyword) => parse_while_statement(parser_state),
        TokenKind::Keyword(KeywordKind::Repeat) => parse_repeat_statement(parser_state),
        TokenKind::Keyword(KeywordKind::ForKeyword) => parse_for_statement(parser_state),
        TokenKind::Keyword(KeywordKind::SwitchKeyword) => parse_switch_statement(parser_state),
        TokenKind::Keyword(KeywordKind::Read) => parse_read_statement(parser_state),
        TokenKind::Keyword(KeywordKind::Write) => parse_write_statement(parser_state),
        TokenKind::Keyword(KeywordKind::ReturnKeyword) => parse_return_statement(parser_state),
        TokenKind::Keyword(KeywordKind::ClassKeyword) => parse_nested_class(parser_state),
        TokenKind::Keyword(KeywordKind::Subroutine) => parse_nested_subroutine(parser_state),
        TokenKind::Identifier => parse_assignment_or_call(parser_state),
        _ => None,
    }
}

fn parse_define_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia();
    if parser_state.current_kind() != TokenKind::Identifier {
        let span = parser_state.current_span();
        parser_state.diagnostics.push(Diagnostic::new(
            DiagnosticCode::ExpectedIdentifierInDeclaration,
            span,
        ));
        return None;
    }
    parser_state.advance();
    while parser_state.eat_if(TokenKind::Comma) {
        parser_state.skip_trivia();
        if parser_state.current_kind() == TokenKind::Identifier {
            parser_state.advance();
        }
    }
    parser_state.skip_trivia();
    if !parser_state.eat_if(TokenKind::Keyword(KeywordKind::TypeConnector)) {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::ExpectedTypeConnector, span));
    }
    parser_state.skip_trivia();
    parser_state.advance();
    let total_subtrees = 1;
    Some(parser_state.push_node(NodeKind::VariableDeclaration, first_token, total_subtrees))
}

fn parse_dimension_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia();
    if parser_state.current_kind() != TokenKind::Identifier {
        let span = parser_state.current_span();
        parser_state.diagnostics.push(Diagnostic::new(
            DiagnosticCode::ExpectedIdentifierInDimension,
            span,
        ));
        return None;
    }
    parser_state.advance();
    parser_state.skip_trivia();
    if parser_state.eat_if(TokenKind::LeftBracket) {
        let _size = parse_expression(parser_state, 0);
        while parser_state.eat_if(TokenKind::Comma) {
            let _next_size = parse_expression(parser_state, 0);
        }
        parser_state.expect(TokenKind::RightBracket, DiagnosticCode::UnclosedBracket);
    }
    Some(parser_state.push_node(NodeKind::DimensionDeclaration, first_token, 1))
}

fn parse_read_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia();
    if parser_state.current_kind() != TokenKind::Identifier {
        let span = parser_state.current_span();
        parser_state
            .diagnostics
            .push(Diagnostic::new(DiagnosticCode::ExpectedReadTarget, span));
        return None;
    }
    parser_state.advance();
    while parser_state.eat_if(TokenKind::Comma) {
        parser_state.skip_trivia();
        if parser_state.current_kind() == TokenKind::Identifier {
            parser_state.advance();
        }
    }
    Some(parser_state.push_node(NodeKind::ReadStatement, first_token, 1))
}

fn parse_write_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    let _first_argument = parse_expression(parser_state, 0)?;
    while parser_state.eat_if(TokenKind::Comma) {
        let _next_argument = parse_expression(parser_state, 0)?;
    }
    Some(parser_state.push_node(NodeKind::WriteStatement, first_token, 1))
}

fn parse_return_statement(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia();
    let next_kind = parser_state.current_kind();
    if next_kind != TokenKind::Newline
        && next_kind != TokenKind::Semicolon
        && next_kind != TokenKind::EndOfFile
    {
        let _return_value = parse_expression(parser_state, 0);
    }
    Some(parser_state.push_node(NodeKind::ReturnStatement, first_token, 1))
}

fn parse_assignment_or_call(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let first_token = parser_state.current_token_u32();
    parser_state.advance();
    parser_state.skip_trivia();
    if parser_state.current_kind() == TokenKind::LeftBracket {
        parser_state.advance();
        let _index = parse_expression(parser_state, 0);
        while parser_state.eat_if(TokenKind::Comma) {
            let _next_index = parse_expression(parser_state, 0);
        }
        parser_state.expect(TokenKind::RightBracket, DiagnosticCode::UnclosedBracket);
    }
    parser_state.skip_trivia();
    if parser_state.eat_if(TokenKind::Assignment) || parser_state.eat_if(TokenKind::Equal) {
        let _assigned_value = parse_expression(parser_state, 0)?;
        return Some(parser_state.push_node(NodeKind::AssignmentStatement, first_token, 1));
    }
    if parser_state.eat_if(TokenKind::LeftParenthesis) {
        if !parser_state.eat_if(TokenKind::RightParenthesis) {
            let _first_argument = parse_expression(parser_state, 0)?;
            while parser_state.eat_if(TokenKind::Comma) {
                let _next_argument = parse_expression(parser_state, 0)?;
            }
            parser_state.expect(
                TokenKind::RightParenthesis,
                DiagnosticCode::UnclosedParenthesis,
            );
        }
        return Some(parser_state.push_node(NodeKind::CallStatement, first_token, 1));
    }
    None
}

fn parse_nested_class(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let span = parser_state.current_span();
    parser_state
        .diagnostics
        .push(Diagnostic::new(DiagnosticCode::ClassInsideAlgorithm, span));
    parser_state.advance();
    parse_statement_block(parser_state);
    parser_state.eat_if(TokenKind::Keyword(KeywordKind::EndClass));
    let token_index = parser_state.current_token_u32();
    Some(parser_state.push_node(NodeKind::ClassUnit, token_index, 1))
}

fn parse_nested_subroutine(parser_state: &mut ParserState<'_>) -> Option<usize> {
    let span = parser_state.current_span();
    parser_state.diagnostics.push(Diagnostic::new(
        DiagnosticCode::SubroutineInsideAlgorithm,
        span,
    ));
    parser_state.advance();
    parse_statement_block(parser_state);
    parser_state.eat_if(TokenKind::Keyword(KeywordKind::EndSubroutine));
    let token_index = parser_state.current_token_u32();
    Some(parser_state.push_node(NodeKind::FunctionUnit, token_index, 1))
}

pub(crate) fn parse_statement_block(parser_state: &mut ParserState<'_>) {
    loop {
        parser_state.skip_trivia_and_newlines();
        let kind = parser_state.current_kind();
        if is_block_terminator(kind) || is_case_label_start(parser_state) {
            break;
        }
        if parse_statement(parser_state).is_none() {
            parser_state.advance();
        }
    }
}

fn is_case_label_start(parser_state: &mut ParserState<'_>) -> bool {
    let kind = parser_state.current_kind();
    if !matches!(
        kind,
        TokenKind::IntegerLiteral
            | TokenKind::RealLiteral
            | TokenKind::StringLiteral
            | TokenKind::CharacterLiteral
    ) {
        return false;
    }
    let mut peek_index = parser_state.cursor.saturating_add(1);
    while peek_index < parser_state.tokens.token_count() {
        let peek_kind = parser_state
            .tokens
            .kind(peek_index)
            .unwrap_or(TokenKind::EndOfFile);
        if peek_kind == TokenKind::Whitespace || peek_kind == TokenKind::Comment {
            peek_index = peek_index.saturating_add(1);
            continue;
        }
        return peek_kind == TokenKind::Colon || peek_kind == TokenKind::Comma;
    }
    false
}

fn is_block_terminator(token_kind: TokenKind) -> bool {
    matches!(
        token_kind,
        TokenKind::EndOfFile
            | TokenKind::Keyword(KeywordKind::EndIf)
            | TokenKind::Keyword(KeywordKind::ElseKeyword)
            | TokenKind::Keyword(KeywordKind::EndWhile)
            | TokenKind::Keyword(KeywordKind::Until)
            | TokenKind::Keyword(KeywordKind::EndFor)
            | TokenKind::Keyword(KeywordKind::EndSwitch)
            | TokenKind::Keyword(KeywordKind::BranchSeparator)
            | TokenKind::Keyword(KeywordKind::DefaultCase)
            | TokenKind::Keyword(KeywordKind::EndAlgorithm)
            | TokenKind::Keyword(KeywordKind::EndSubroutine)
            | TokenKind::Keyword(KeywordKind::EndClass)
    )
}
