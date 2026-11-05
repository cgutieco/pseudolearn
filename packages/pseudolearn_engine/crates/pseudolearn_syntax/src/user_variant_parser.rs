use crate::declaration_parser::{name, parse_type};
use crate::parser_state::ParserState;
use crate::tokens::TokenKind;
use crate::tree::NodeKind;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::KeywordKind;

pub(crate) fn starts(state: &mut ParserState<'_>) -> bool {
    crate::contextual::followed_by(state, "variantKeyword", TokenKind::Identifier)
}

pub(crate) fn variant(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    state.advance();
    name(state, DiagnosticCode::ExpectedClassName)?;
    crate::generic_parser::optional_parameters(state)?;
    loop {
        state.separators();
        if crate::contextual::matches(state, "endVariant") || unit_boundary(state.kind()) {
            break;
        }
        let before = state.cursor;
        if alternative(state).is_err() {
            crate::statement_parser::recover(state);
        }
        if state.cursor == before {
            state.advance();
        }
    }
    close(state, start);
    Ok(state.finish(NodeKind::VariantUnit, start, marker))
}

fn alternative(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    if !crate::contextual::eat(state, "alternativeKeyword") {
        let span = state.span();
        if !state.lexical_gap {
            state.report(DiagnosticCode::ExpectedVariantAlternative, span);
        }
        return Err(());
    }
    name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    if state.eat(TokenKind::LeftParenthesis) && !state.eat(TokenKind::RightParenthesis) {
        field(state)?;
        while state.eat(TokenKind::Comma) {
            field(state)?;
        }
        state.require(
            TokenKind::RightParenthesis,
            DiagnosticCode::UnclosedParenthesis,
        )?;
    }
    Ok(state.finish(NodeKind::VariantAlternative, start, marker))
}

fn field(state: &mut ParserState<'_>) -> Result<usize, ()> {
    let start = state.token();
    let marker = state.nodes.len();
    name(state, DiagnosticCode::ExpectedIdentifierInDeclaration)?;
    state.require(
        TokenKind::Keyword(KeywordKind::TypeConnector),
        DiagnosticCode::ExpectedType,
    )?;
    parse_type(state)?;
    Ok(state.finish(NodeKind::AlternativeField, start, marker))
}

fn close(state: &mut ParserState<'_>, opening: u32) {
    if crate::contextual::eat(state, "endVariant") {
        return;
    }
    let span = state.span();
    state.report(DiagnosticCode::UnclosedVariant, span);
    let opening = usize::try_from(opening)
        .ok()
        .and_then(|token| state.tokens.span(token));
    if let (Some(diagnostic), Some(opening)) = (state.diagnostics.last_mut(), opening) {
        diagnostic.related.push(opening);
    }
}

fn unit_boundary(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::EndOfFile
            | TokenKind::Keyword(
                KeywordKind::Algorithm
                    | KeywordKind::ClassKeyword
                    | KeywordKind::Subroutine
                    | KeywordKind::RecordKeyword
                    | KeywordKind::EnumKeyword
                    | KeywordKind::ConstantKeyword
                    | KeywordKind::PublicVisibility
                    | KeywordKind::PrivateVisibility
            )
    )
}
