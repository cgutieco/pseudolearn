use crate::expression_parser::parse_expression;
use crate::parser_state::ParserState;
use crate::statement_parser::parse_statement_block;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn compound(state: &mut ParserState<'_>) -> Result<usize, ()> {
    state.enter()?;
    let opening = state.kind();
    let result = match state.kind() {
        TokenKind::Keyword(KeywordKind::IfKeyword) => conditional(state),
        TokenKind::Keyword(KeywordKind::WhileKeyword) => while_loop(state),
        TokenKind::Keyword(KeywordKind::Repeat) => repeat_loop(state),
        TokenKind::Keyword(KeywordKind::ForKeyword) => for_loop(state),
        TokenKind::Keyword(KeywordKind::TasksKeyword) => crate::task_scope_parser::parse(state),
        TokenKind::Keyword(KeywordKind::SelectKeyword) => crate::select_parser::parse(state),
        _ => crate::switch_parser::switch(state),
    };
    state.leave();
    if result.is_err() {
        crate::parser::recover_unit(state, opening);
    }
    result
}

fn conditional(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    parse_expression(state, 0)?;
    state.require(
        TokenKind::Keyword(KeywordKind::Then),
        DiagnosticCode::ExpectedThenKeyword,
    )?;
    parse_statement_block(state);
    if state.keyword(KeywordKind::ElseKeyword) {
        parse_statement_block(state);
    }
    state.close(
        KeywordKind::EndIf,
        DiagnosticCode::UnclosedIfStatement,
        start,
    );
    Ok(state.finish(NodeKind::Conditional, start, marker))
}

fn while_loop(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    parse_expression(state, 0)?;
    state.require(
        TokenKind::Keyword(KeywordKind::DoKeyword),
        DiagnosticCode::ExpectedDoKeyword,
    )?;
    parse_statement_block(state);
    state.close(
        KeywordKind::EndWhile,
        DiagnosticCode::UnclosedWhileStatement,
        start,
    );
    Ok(state.finish(NodeKind::WhileLoop, start, marker))
}

fn repeat_loop(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    parse_statement_block(state);
    state.close(
        KeywordKind::Until,
        DiagnosticCode::UnclosedRepeatStatement,
        start,
    );
    if !state.unclosed {
        parse_expression(state, 0)?;
    }
    Ok(state.finish(NodeKind::RepeatLoop, start, marker))
}

fn for_loop(state: &mut ParserState<'_>) -> Result<usize, ()> {
    if crate::iteration_parser::starts(state) {
        return crate::iteration_parser::for_each(state);
    }
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    crate::declaration_parser::name(state, DiagnosticCode::ExpectedForLoopVariable)?;
    state.require(
        TokenKind::Assignment,
        DiagnosticCode::ExpectedAssignmentOperator,
    )?;
    parse_expression(state, 0)?;
    state.require(
        TokenKind::Keyword(KeywordKind::To),
        DiagnosticCode::ExpectedToKeyword,
    )?;
    parse_expression(state, 0)?;
    if state.keyword(KeywordKind::Step) {
        parse_expression(state, 0)?;
    }
    state.require(
        TokenKind::Keyword(KeywordKind::DoKeyword),
        DiagnosticCode::ExpectedDoKeyword,
    )?;
    parse_statement_block(state);
    state.close(
        KeywordKind::EndFor,
        DiagnosticCode::UnclosedForStatement,
        start,
    );
    Ok(state.finish(NodeKind::ForLoop, start, marker))
}
