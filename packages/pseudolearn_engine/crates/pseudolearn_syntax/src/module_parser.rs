use crate::declaration_parser::name;
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn is_directive(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Keyword(KeywordKind::ImportKeyword | KeywordKind::ExportKeyword)
    )
}

pub(crate) fn is_visibility(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Keyword(KeywordKind::PublicVisibility | KeywordKind::PrivateVisibility)
    )
}

pub(crate) fn reject_outside_project(state: &mut ParserState<'_>) {
    if !state.project_mode {
        let span = state.span();
        state.report(DiagnosticCode::ModuleSyntaxOutsideProject, span);
    }
}

pub(crate) fn directive(state: &mut ParserState<'_>) -> Result<usize, ()> {
    reject_outside_project(state);
    let start = state.token();
    let marker = state.nodes.len();
    let importing = state.kind() == TokenKind::Keyword(KeywordKind::ImportKeyword);
    state.advance();
    module_path(state)?;
    if importing && state.keyword(KeywordKind::TypeConnector) {
        name(state, DiagnosticCode::ExpectedModuleName)?;
    }
    crate::statement_parser::terminator(state)?;
    let kind = if importing {
        NodeKind::ImportDeclaration
    } else {
        NodeKind::ExportDeclaration
    };
    Ok(state.finish(kind, start, marker))
}

fn module_path(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    path_segment(state)?;
    while state.eat(TokenKind::Dot) {
        path_segment(state)?;
    }
    Ok(state.finish(NodeKind::ModulePath, start, marker))
}

fn path_segment(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let reserved = match state.kind() {
        TokenKind::Keyword(KeywordKind::TypeConnector) => false,
        TokenKind::Keyword(_) | TokenKind::BooleanLiteral(_) => true,
        _ => false,
    };
    if !reserved {
        return name(state, DiagnosticCode::ExpectedModuleName);
    }
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    Ok(state.finish(NodeKind::Identifier, start, marker))
}

pub(crate) fn visibility_prefix(state: &mut ParserState<'_>) -> Result<Option<u32>, ()> {
    if !is_visibility(state.kind()) {
        return Ok(None);
    }
    reject_outside_project(state);
    let token = state.token();
    state.advance();
    let allowed = matches!(
        state.kind(),
        TokenKind::Keyword(KeywordKind::Subroutine | KeywordKind::ClassKeyword)
    );
    if allowed {
        return Ok(Some(token));
    }
    let span = state.span();
    state.report(DiagnosticCode::UnexpectedTokenOutsideProgramUnit, span);
    Err(())
}
