use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn parse_statement_block(state: &mut ParserState<'_>) -> usize {
    body_until(state, |state| {
        boundary(state.kind())
            || crate::contextual::matches(state, "endDefer")
            || state.kind() == TokenKind::Keyword(KeywordKind::EndTasks)
    })
}

pub(crate) fn parse_case_body(state: &mut ParserState<'_>) -> usize {
    body_until(state, |state| {
        boundary(state.kind()) || crate::switch_parser::starts_label(state)
    })
}

fn body_until(state: &mut ParserState<'_>, boundary: fn(&mut ParserState<'_>) -> bool) -> usize {
    let start = state.token();
    let marker = state.nodes.len();
    loop {
        state.separators();
        if boundary(state) {
            break;
        }
        let before = state.cursor;
        state.lexical_gap = false;
        if parse_statement(state).is_err() {
            recover(state);
        }
        if state.cursor == before {
            state.advance();
        }
    }
    state.finish(NodeKind::Body, start, marker)
}

fn parse_statement(state: &mut ParserState<'_>) -> Result<usize, ()> {
    if let Some(result) = crate::iteration_parser::statement(state) {
        return result;
    }
    if crate::unsupported::reject(state) {
        return Err(());
    }
    let start = state.token();
    let marker = state.nodes.len();
    let result = match state.kind() {
        TokenKind::Keyword(
            KeywordKind::IfKeyword
            | KeywordKind::WhileKeyword
            | KeywordKind::Repeat
            | KeywordKind::ForKeyword
            | KeywordKind::SwitchKeyword,
        ) => return crate::control_statement_parser::compound(state),
        TokenKind::Keyword(KeywordKind::TasksKeyword) => {
            return crate::control_statement_parser::compound(state);
        }
        TokenKind::Keyword(KeywordKind::Declare) => crate::declaration_parser::declaration(state),
        TokenKind::Keyword(KeywordKind::ConstantKeyword) => crate::constant_parser::constant(state),
        TokenKind::Keyword(KeywordKind::Dimension) => crate::declaration_parser::dimension(state),
        TokenKind::Keyword(KeywordKind::Write) => output(state),
        TokenKind::Keyword(KeywordKind::Read) => input(state),
        TokenKind::Keyword(KeywordKind::ReturnKeyword) => returned(state),
        TokenKind::Keyword(KeywordKind::SpawnKeyword) => {
            crate::task_scope_parser::spawn_statement(state)
        }
        TokenKind::Keyword(KeywordKind::DiscardKeyword) => crate::variant_parser::discard(state),
        TokenKind::Keyword(
            KeywordKind::ClassKeyword | KeywordKind::Subroutine | KeywordKind::Method,
        ) => return crate::unit_parser::reject_nested(state),
        _ => assignment_or_call(state),
    }?;
    terminator(state)?;
    state.finish(NodeKind::Statement, start, marker);
    Ok(result)
}

fn output(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    let initial_modifier = state.kind() == TokenKind::Keyword(KeywordKind::WithoutNewline);
    if !simple_end(state.kind()) && state.kind() != TokenKind::Keyword(KeywordKind::WithoutNewline)
    {
        crate::postfix_parser::expression_list(state)?;
    }
    if state.keyword(KeywordKind::WithoutNewline) {
        if state.kind() == TokenKind::Keyword(KeywordKind::WithoutNewline) {
            let span = state.span();
            state.report(DiagnosticCode::DuplicateModifier, span);
            return Err(());
        }
        if initial_modifier && !simple_end(state.kind()) {
            let span = state.span();
            state.report(DiagnosticCode::UnexpectedModifierPosition, span);
            return Err(());
        }
    }
    Ok(state.finish(NodeKind::Output, start, marker))
}

fn input(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    if simple_end(state.kind()) {
        let span = state.span();
        if !state.lexical_gap {
            state.report(DiagnosticCode::ExpectedReadTarget, span);
        }
        return Err(());
    }
    parse_expression(state, 0)?;
    while state.eat(TokenKind::Comma) {
        parse_expression(state, 0)?;
    }
    Ok(state.finish(NodeKind::Input, start, marker))
}

fn returned(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    if !simple_end(state.kind()) {
        parse_expression(state, 0)?;
    }
    Ok(state.finish(NodeKind::ReturnStatement, start, marker))
}

fn assignment_or_call(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    let target = parse_expression(state, 0)?;
    if state.eat(TokenKind::Assignment) {
        if !designator(state, target) {
            let span = state.span();
            state.report(DiagnosticCode::InvalidAssignmentTarget, span);
            return Err(());
        }
        parse_expression(state, 0)?;
        return Ok(state.finish(NodeKind::AssignmentStatement, start, marker));
    }
    if state.nodes.get(target).is_some_and(|node| {
        matches!(
            node.kind,
            NodeKind::Postfix | NodeKind::AwaitExpression | NodeKind::SpawnExpression
        )
    }) {
        return Ok(state.finish(NodeKind::CallStatement, start, marker));
    }
    let span = state.span();
    state.report(DiagnosticCode::UnexpectedStatement, span);
    Err(())
}

fn designator(state: &ParserState<'_>, index: usize) -> bool {
    let Some(node) = state.nodes.get(index) else {
        return false;
    };
    if node.kind == NodeKind::Identifier {
        return true;
    }
    let operator = state
        .operators
        .get(index)
        .copied()
        .flatten()
        .and_then(|token| usize::try_from(token).ok())
        .and_then(|token| state.tokens.kind(token));
    node.kind == NodeKind::Postfix
        && matches!(operator, Some(TokenKind::LeftBracket | TokenKind::Dot))
}

pub(crate) fn terminator(state: &mut ParserState<'_>) -> Result<(), ()> {
    if state.eat(TokenKind::Semicolon) {
        return Ok(());
    }
    if simple_end(state.kind()) {
        if state.lexical_gap {
            return Ok(());
        }
        if let Some(code) = state.terminator_diagnostic {
            let span = state.span();
            state.report(code, span);
            return Err(());
        }
        return Ok(());
    }
    let span = state.span();
    state.report(DiagnosticCode::MissingStatementTerminator, span);
    Err(())
}

pub(crate) fn recover(state: &mut ParserState<'_>) {
    while !simple_end(state.kind()) {
        state.advance();
    }
    state.eat(TokenKind::Semicolon);
}

fn simple_end(kind: TokenKind) -> bool {
    matches!(kind, TokenKind::Newline | TokenKind::Semicolon) || boundary(kind)
}

pub(crate) fn boundary(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::EndOfFile
            | TokenKind::Keyword(
                KeywordKind::EndIf
                    | KeywordKind::ElseKeyword
                    | KeywordKind::EndWhile
                    | KeywordKind::Until
                    | KeywordKind::EndFor
                    | KeywordKind::EndSwitch
                    | KeywordKind::DefaultCase
                    | KeywordKind::EndAlgorithm
                    | KeywordKind::EndSubroutine
                    | KeywordKind::EndTasks
                    | KeywordKind::EndClass
                    | KeywordKind::EndMethod
            )
    )
}
