use crate::parser_state::ParserState;
use crate::postfix_parser::expression_list;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn name(state: &mut ParserState<'_>, missing: DiagnosticCode) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    if state.eat(TokenKind::Identifier) {
        return Ok(state.finish(NodeKind::Identifier, start, marker));
    }
    let code = match state.kind() {
        TokenKind::Keyword(KeywordKind::TypeConnector) => missing,
        TokenKind::Keyword(_) | TokenKind::BooleanLiteral(_) => {
            DiagnosticCode::ReservedLexemeUsedAsName
        }
        _ => missing,
    };
    let span = state.span();
    state.report(code, span);
    reserved_arguments(state, code);
    Err(())
}

pub(crate) fn parse_type(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    if matches!(
        state.kind(),
        TokenKind::Keyword(KeywordKind::OptionalType | KeywordKind::ResultType)
    ) {
        let result = state.kind() == TokenKind::Keyword(KeywordKind::ResultType);
        state.advance();
        crate::variant_parser::type_arguments(state, result)?;
        return Ok(state.finish(NodeKind::Type, start, marker));
    }
    match state.kind() {
        TokenKind::Identifier
        | TokenKind::Keyword(
            KeywordKind::IntegerType
            | KeywordKind::RealType
            | KeywordKind::BooleanType
            | KeywordKind::CharacterType
            | KeywordKind::StringType,
        ) => state.advance(),
        _ => {
            let span = state.span();
            state.report(DiagnosticCode::ExpectedType, span);
            return Err(());
        }
    }
    Ok(state.finish(NodeKind::Type, start, marker))
}

pub(crate) fn declaration(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    state.keyword(KeywordKind::MutableKeyword);
    name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    state.require(
        TokenKind::Keyword(KeywordKind::TypeConnector),
        DiagnosticCode::ExpectedTypeConnector,
    )?;
    parse_type(state)?;
    if state.eat(TokenKind::Assignment) {
        crate::expression_parser::parse_expression(state, 0)?;
    } else {
        let span = state.span();
        state.report(DiagnosticCode::MissingBindingInitializer, span);
        return Err(());
    }
    Ok(state.finish(NodeKind::Declaration, start, marker))
}

pub(crate) fn field(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    while state.eat(TokenKind::Comma) {
        name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    }
    state.require(
        TokenKind::Keyword(KeywordKind::TypeConnector),
        DiagnosticCode::ExpectedTypeConnector,
    )?;
    parse_type(state)?;
    reject_initializer(state)?;
    Ok(state.finish(NodeKind::Declaration, start, marker))
}

pub(crate) fn dimension(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    dimensioned(state)?;
    while state.eat(TokenKind::Comma) {
        dimensioned(state)?;
    }
    state.require(
        TokenKind::Keyword(KeywordKind::TypeConnector),
        DiagnosticCode::ExpectedTypeConnector,
    )?;
    parse_type(state)?;
    reject_initializer(state)?;
    Ok(state.finish(NodeKind::DimensionDeclaration, start, marker))
}

fn dimensioned(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    name(state, DiagnosticCode::ExpectedIdentifierInDimension)?;
    state.require(TokenKind::LeftBracket, DiagnosticCode::UnclosedBracket)?;
    if state.kind() == TokenKind::RightBracket {
        let span = state.span();
        state.report(DiagnosticCode::EmptyDimensionList, span);
        return Err(());
    }
    expression_list(state)?;
    state.require(TokenKind::RightBracket, DiagnosticCode::UnclosedBracket)?;
    Ok(state.finish(NodeKind::Dimensioned, start, marker))
}

fn reject_initializer(state: &mut ParserState<'_>) -> Result<(), ()> {
    if matches!(state.kind(), TokenKind::Assignment | TokenKind::Equal) {
        let span = state.span();
        state.report(DiagnosticCode::InitializationInDeclarationNotAllowed, span);
        return Err(());
    }
    Ok(())
}

fn reserved_arguments(state: &mut ParserState<'_>, code: DiagnosticCode) {
    if code != DiagnosticCode::ReservedLexemeUsedAsName {
        return;
    }
    let token = state.token();
    let keyword = match state.kind() {
        TokenKind::Keyword(keyword) => keyword,
        TokenKind::BooleanLiteral(true) => KeywordKind::BooleanTrue,
        _ => KeywordKind::BooleanFalse,
    };
    let text = usize::try_from(token)
        .ok()
        .and_then(|token| state.tokens.text(state.source, token))
        .unwrap_or("")
        .to_owned();
    if let Some(diagnostic) = state
        .diagnostics
        .last_mut()
        .filter(|diagnostic| diagnostic.code == code)
    {
        diagnostic.arguments.insert(
            "lexeme".to_owned(),
            pseudolearn_diagnostics::DiagnosticArgument::Lexeme(text),
        );
        diagnostic.arguments.insert(
            "token".to_owned(),
            pseudolearn_diagnostics::DiagnosticArgument::Token(keyword.as_str().to_owned()),
        );
    }
}
