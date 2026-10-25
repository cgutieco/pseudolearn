use crate::declaration_parser::{dimension, name, parse_type};
use crate::parameter_parser::parameters;
use crate::parser_state::ParserState;
use crate::statement_parser::{parse_statement_block, recover};
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn algorithm(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.unit_context = NodeKind::AlgorithmUnit;
    state.advance();
    if name(state, DiagnosticCode::ExpectedAlgorithmName).is_err() {
        recover(state);
    }
    parse_statement_block(state);
    state.close(
        KeywordKind::EndAlgorithm,
        DiagnosticCode::UnclosedAlgorithm,
        start,
    );
    Ok(state.finish(NodeKind::AlgorithmUnit, start, marker))
}

pub(crate) fn subprogram(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.unit_context = NodeKind::Subprogram;
    state.advance();
    name(state, DiagnosticCode::ExpectedSubroutineName)?;
    parameters(state)?;
    if state.keyword(KeywordKind::TypeConnector) {
        parse_type(state)?;
    }
    parse_statement_block(state);
    state.close(
        KeywordKind::EndSubroutine,
        DiagnosticCode::UnclosedSubroutine,
        start,
    );
    Ok(state.finish(NodeKind::Subprogram, start, marker))
}

pub(crate) fn class(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.unit_context = NodeKind::ClassUnit;
    state.advance();
    if crate::unsupported::reject(state) {
        return Err(());
    }
    let class_name = state.token();
    name(state, DiagnosticCode::ExpectedClassName)?;
    state.has_superclass = state.keyword(KeywordKind::InheritsFrom);
    if state.has_superclass {
        name(state, DiagnosticCode::ExpectedClassName)?;
        if state.kind() == TokenKind::Comma {
            let span = state.span();
            state.report(DiagnosticCode::MultipleInheritanceNotSupported, span);
            return Err(());
        }
    }
    loop {
        state.separators();
        if matches!(
            state.kind(),
            TokenKind::EndOfFile | TokenKind::Keyword(KeywordKind::EndClass)
        ) {
            break;
        }
        let before = state.cursor;
        if class_member(state, class_name).is_err() {
            recover(state);
        }
        if state.cursor == before {
            state.advance();
        }
    }
    state.close(KeywordKind::EndClass, DiagnosticCode::UnclosedClass, start);
    state.has_superclass = false;
    Ok(state.finish(NodeKind::ClassUnit, start, marker))
}

fn class_member(state: &mut ParserState<'_>, class_name: u32) -> Result<(), ()> {
    if crate::unsupported::reject(state) {
        return Err(());
    }
    let start = state.token();
    let marker = state.nodes.len();
    let modifier = state.keyword(KeywordKind::PublicVisibility)
        || state.keyword(KeywordKind::PrivateVisibility);
    match state.kind() {
        TokenKind::Keyword(KeywordKind::Declare) => {
            crate::declaration_parser::field(state)?;
        }
        TokenKind::Keyword(KeywordKind::Dimension) => {
            dimension(state)?;
        }
        TokenKind::Keyword(KeywordKind::Method) => {
            method(state, class_name, modifier)?;
            if let Some(node) = state.nodes.last_mut() {
                node.first_token = start;
            }
            return Ok(());
        }
        TokenKind::Keyword(KeywordKind::ClassKeyword | KeywordKind::Subroutine) => {
            reject_nested(state)?;
            return Ok(());
        }
        _ => {
            let span = state.span();
            state.report(DiagnosticCode::UnexpectedStatement, span);
            return Err(());
        }
    }
    if !state.eat(TokenKind::Semicolon) && state.terminator_diagnostic.is_some() {
        let span = state.span();
        state.report(DiagnosticCode::MissingStatementTerminator, span);
    }
    state.finish(NodeKind::FieldDeclaration, start, marker);
    Ok(())
}

fn method(state: &mut ParserState<'_>, class_name: u32, modifier: bool) -> Result<(), ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    let constructor = state.kind() == TokenKind::Keyword(KeywordKind::Constructor);
    check_method_name(state, class_name, constructor)?;
    if constructor && modifier {
        let span = state.span();
        state.report(DiagnosticCode::ConstructorVisibilityNotAllowed, span);
    }
    parameters(state)?;
    if state.keyword(KeywordKind::TypeConnector) {
        if constructor {
            let span = state.span();
            state.report(DiagnosticCode::ConstructorReturnTypeNotAllowed, span);
        }
        parse_type(state)?;
    }
    state.inside_method = true;
    parse_statement_block(state);
    state.inside_method = false;
    state.close(
        KeywordKind::EndMethod,
        DiagnosticCode::UnclosedMethod,
        start,
    );
    state.finish(
        if constructor {
            NodeKind::ConstructorMember
        } else {
            NodeKind::MethodMember
        },
        start,
        marker,
    );
    Ok(())
}

fn check_method_name(
    state: &mut ParserState<'_>,
    class_name: u32,
    constructor: bool,
) -> Result<(), ()> {
    if constructor {
        let start = state.token();
        let marker = state.nodes.len();
        state.advance();
        state.finish(NodeKind::Identifier, start, marker);
        return Ok(());
    }
    let token = state.token();
    if state.text(token) == state.text(class_name) {
        let span = state.span();
        state.report(DiagnosticCode::MethodNamedAsClass, span);
    }
    name(state, DiagnosticCode::ExpectedSubroutineName)?;
    Ok(())
}

pub(crate) fn reject_nested(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let opening = state.kind();
    let code = match (state.unit_context, opening) {
        (NodeKind::AlgorithmUnit, TokenKind::Keyword(KeywordKind::ClassKeyword)) => {
            DiagnosticCode::ClassInsideAlgorithm
        }
        (NodeKind::Subprogram, TokenKind::Keyword(KeywordKind::ClassKeyword)) => {
            DiagnosticCode::ClassInsideSubroutine
        }
        (_, TokenKind::Keyword(KeywordKind::ClassKeyword)) => {
            DiagnosticCode::NestedClassNotSupported
        }
        (NodeKind::AlgorithmUnit, TokenKind::Keyword(KeywordKind::Subroutine)) => {
            DiagnosticCode::SubroutineInsideAlgorithm
        }
        (NodeKind::ClassUnit, TokenKind::Keyword(KeywordKind::Subroutine)) => {
            DiagnosticCode::SubroutineInsideClass
        }
        (_, TokenKind::Keyword(KeywordKind::Subroutine)) => {
            DiagnosticCode::SubroutineInsideSubroutine
        }
        _ => DiagnosticCode::MethodOutsideClass,
    };
    let span = state.span();
    state.report(code, span);
    let closing = match opening {
        TokenKind::Keyword(KeywordKind::ClassKeyword) => KeywordKind::EndClass,
        TokenKind::Keyword(KeywordKind::Subroutine) => KeywordKind::EndSubroutine,
        _ => KeywordKind::EndMethod,
    };
    state.advance();
    while state.kind() != TokenKind::EndOfFile && state.kind() != TokenKind::Keyword(closing) {
        state.advance();
    }
    state.keyword(closing);
    Err(())
}
