use crate::declaration_parser::parse_type;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn function_type(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    state.require(TokenKind::LeftParenthesis, DiagnosticCode::ExpectedType)?;
    if !state.eat(TokenKind::RightParenthesis) {
        parameter_type(state)?;
        while state.eat(TokenKind::Comma) {
            parameter_type(state)?;
        }
        state.require(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        )?;
    }
    if state.keyword(KeywordKind::TypeConnector) {
        parse_type(state)?;
    }
    Ok(state.finish(NodeKind::Type, start, marker))
}

fn parameter_type(state: &mut ParserState<'_>) -> Result<(), ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.enter()?;
    let parsed = parse_type(state);
    state.leave();
    parsed?;
    state.keyword(KeywordKind::ByReference);
    state.keyword(KeywordKind::ByValue);
    state.finish(NodeKind::FunctionParameterType, start, marker);
    Ok(())
}

pub(crate) fn literal(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    let context = state.unit_context;
    let inside_method = state.inside_method;
    state.unit_context = NodeKind::Subprogram;
    state.inside_method = false;
    state.advance();
    if crate::contextual::matches(state, "suspendibleModifier") {
        let modifier = state.token();
        let modifier_marker = state.nodes.len();
        state.advance();
        state.finish(NodeKind::SuspendibleModifier, modifier, modifier_marker);
    }
    state.enter()?;
    let result = literal_body(state, (start, marker));
    state.leave();
    state.unit_context = context;
    state.inside_method = inside_method;
    result
}

fn literal_body(state: &mut ParserState<'_>, (start, marker): (u32, usize)) -> Result<usize, ()> {
    crate::parameter_parser::parameters(state)?;
    if state.keyword(KeywordKind::TypeConnector) {
        parse_type(state)?;
    }
    crate::statement_parser::parse_statement_block(state);
    state.close(
        KeywordKind::EndSubroutine,
        DiagnosticCode::UnclosedSubroutine,
        start,
    );
    Ok(state.finish(NodeKind::FunctionLiteral, start, marker))
}
