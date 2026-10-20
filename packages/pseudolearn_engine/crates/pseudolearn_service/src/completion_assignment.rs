use crate::completion::{CompletionQuery, CompletionResult, CompletionTextEdit};
use crate::completion_pool::keyed_entry;
use crate::completion_types::{CompletionEntry, CompletionKind};
use crate::symbol_queries::{enclosing_function, visible_locals};
use crate::typing_lines::{line_code_tokens, line_end, line_start, token_end};
use pseudolearn_diagnostics::{DiagnosticCode, DiagnosticSeverity};
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_semantic::ServiceAnalysis;
use pseudolearn_semantic::hir::HirLocal;
use pseudolearn_semantic::types::Type;
use pseudolearn_syntax::TokenKind;

pub fn assignment_offer(
    query: &CompletionQuery<'_>,
    cursor: usize,
) -> Option<(CompletionEntry, CompletionTextEdit)> {
    let (name, start) = assignment_target(query, cursor)?;
    let analysis = query.analysis?;
    let local = confirmed_local(analysis, (cursor, start), &name)?;
    let mut entry = assignment_entry(query, local);
    entry.insert_text = Some(format!("{name} <- "));
    entry.inline = true;
    Some((
        entry,
        CompletionTextEdit {
            start_utf8: start,
            end_utf8: cursor,
        },
    ))
}

fn assignment_target(query: &CompletionQuery<'_>, cursor: usize) -> Option<(String, usize)> {
    let text = query.source.as_str();
    let start = line_start(text, cursor);
    let end = line_end(text, cursor);
    if text
        .get(cursor..end)
        .is_none_or(|tail| !tail.trim_end_matches('\r').is_empty())
    {
        return None;
    }
    let tokens = line_code_tokens(query.tree, start, end);
    let [token] = tokens.as_slice() else {
        return None;
    };
    if token.kind != TokenKind::Identifier
        || token_end(query.tree, token.index) > cursor
        || !text.get(start..token.start)?.trim().is_empty()
        || !starts_statement(query, token.start)
    {
        return None;
    }
    let after = text.get(token_end(query.tree, token.index)..end)?;
    if !after
        .chars()
        .all(|glyph| matches!(glyph, ' ' | '\t' | '\r'))
    {
        return None;
    }
    Some((
        query.tree.tokens.text(text, token.index)?.to_owned(),
        token.start,
    ))
}

fn assignment_entry(query: &CompletionQuery<'_>, local: &HirLocal) -> CompletionEntry {
    let type_name = query
        .analysis
        .map(|analysis| crate::type_names::type_display(analysis, local.type_id, query.profile));
    keyed_entry(
        local.name.clone(),
        CompletionKind::Variable,
        ("type_name", type_name.into_iter().collect()),
        None,
    )
}

pub fn apply_assignment(
    result: &mut CompletionResult,
    offer: Option<(CompletionEntry, CompletionTextEdit)>,
) {
    let Some((entry, replace)) = offer else {
        return;
    };
    for candidate in &mut result.entries {
        candidate.inline = false;
    }
    if let Some(candidate) = result
        .entries
        .iter_mut()
        .find(|candidate| candidate.label == entry.label)
    {
        *candidate = entry;
    } else {
        result.entries.insert(0, entry);
    }
    result.text_edit = replace;
}

fn starts_statement(query: &CompletionQuery<'_>, start: usize) -> bool {
    if has_open_group(query, start) {
        return false;
    }
    let context = crate::cursor_context::analyze_cursor(query.tree, query.source, start);
    match context.previous {
        Some(TokenKind::Keyword(kind)) => !expects_operand(kind),
        Some(kind) => !continues_expression(kind),
        None => false,
    }
}

fn has_open_group(query: &CompletionQuery<'_>, start: usize) -> bool {
    let lower = query
        .analysis
        .and_then(|analysis| {
            enclosing_function(analysis, start)
                .and_then(|index| analysis.module.functions.get(index))
        })
        .map_or(0, |function| function.span.start);
    let upper = u32::try_from(start).unwrap_or(u32::MAX);
    let mut stack = Vec::new();
    for token in 0..query.tree.tokens.token_count() {
        let inside = query
            .tree
            .tokens
            .span(token)
            .is_some_and(|span| span.start >= lower && span.ending <= upper);
        if !inside {
            continue;
        }
        match query.tree.tokens.kind(token) {
            Some(TokenKind::LeftParenthesis) => stack.push(TokenKind::RightParenthesis),
            Some(TokenKind::LeftBracket) => stack.push(TokenKind::RightBracket),
            Some(kind @ (TokenKind::RightParenthesis | TokenKind::RightBracket))
                if stack.pop() != Some(kind) =>
            {
                return true;
            }
            _ => {}
        }
    }
    !stack.is_empty()
}

fn expects_operand(kind: KeywordKind) -> bool {
    matches!(
        kind,
        KeywordKind::Read
            | KeywordKind::Write
            | KeywordKind::ReturnKeyword
            | KeywordKind::IfKeyword
            | KeywordKind::WhileKeyword
            | KeywordKind::Until
            | KeywordKind::And
            | KeywordKind::Or
            | KeywordKind::Not
            | KeywordKind::TypeConnector
            | KeywordKind::Modulo
            | KeywordKind::IntegerDivide
            | KeywordKind::SwitchKeyword
            | KeywordKind::ForKeyword
            | KeywordKind::To
            | KeywordKind::Step
            | KeywordKind::NewInstance
    )
}

fn continues_expression(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Assignment
            | TokenKind::LeftParenthesis
            | TokenKind::LeftBracket
            | TokenKind::Comma
            | TokenKind::Dot
            | TokenKind::Plus
            | TokenKind::Minus
            | TokenKind::Star
            | TokenKind::Slash
            | TokenKind::Power
            | TokenKind::Modulo
            | TokenKind::IntegerDivision
            | TokenKind::Equal
            | TokenKind::NotEqual
            | TokenKind::Less
            | TokenKind::LessEqual
            | TokenKind::Greater
            | TokenKind::GreaterEqual
            | TokenKind::LogicalAnd
            | TokenKind::LogicalOr
            | TokenKind::LogicalNot
    )
}

fn confirmed_local<'analysis>(
    analysis: &'analysis ServiceAnalysis,
    position: (usize, usize),
    name: &str,
) -> Option<&'analysis HirLocal> {
    let (cursor, start) = position;
    let matching: Vec<&HirLocal> = visible_locals(analysis, cursor, start)
        .into_iter()
        .filter_map(|index| analysis.module.locals.get(index))
        .filter(|local| local.name == name)
        .collect();
    let [local] = matching.as_slice() else {
        return None;
    };
    if !matches!(
        analysis.module.types.get(local.type_id),
        Type::Integer
            | Type::Real
            | Type::Boolean
            | Type::Character
            | Type::String
            | Type::Object(_)
    ) || analysis
        .symbols
        .iter()
        .any(|symbol| symbol.span == local.span && symbol.name == local.name && symbol.is_inferred)
        || invalid_declaration(analysis, cursor, local)
    {
        return None;
    }
    Some(local)
}

fn invalid_declaration(analysis: &ServiceAnalysis, cursor: usize, local: &HirLocal) -> bool {
    let function =
        enclosing_function(analysis, cursor).and_then(|index| analysis.module.functions.get(index));
    analysis.diagnostics.iter().any(|diagnostic| {
        let collision = matches!(
            diagnostic.code,
            DiagnosticCode::DuplicateVariableDeclaration
                | DiagnosticCode::DuplicateParameterName
                | DiagnosticCode::SubroutineAndVariableSameName
        );
        let same_name = diagnostic
            .arguments
            .values()
            .any(|argument| argument.text() == local.name);
        let same_scope = function.is_some_and(|function| {
            function.span.start <= diagnostic.span.start
                && diagnostic.span.ending <= function.span.ending
        });
        let declaration_error = diagnostic.span.start <= local.span.start
            && local.span.ending <= diagnostic.span.ending;
        diagnostic.severity == DiagnosticSeverity::Error
            && (declaration_error || (collision && same_name && same_scope))
    })
}
