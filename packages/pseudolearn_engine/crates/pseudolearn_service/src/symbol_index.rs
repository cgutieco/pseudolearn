use pseudolearn_semantic::hir::FunctionKind;
use pseudolearn_semantic::{ServiceAnalysis, ServiceReference, ServiceSymbolTarget};
use pseudolearn_source::Span;
use pseudolearn_syntax::{SyntaxTree, TokenKind};
use std::collections::BTreeSet;

#[derive(Clone, Debug, PartialEq)]
pub struct NamedOccurrence {
    pub span: Span,
    pub target: ServiceSymbolTarget,
    pub is_declaration: bool,
    pub is_write: bool,
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct SymbolIndex {
    entries: Vec<NamedOccurrence>,
}

impl SymbolIndex {
    pub fn build(tree: &SyntaxTree, analysis: &ServiceAnalysis) -> Self {
        let mut entries: Vec<NamedOccurrence> = Vec::new();
        let mut seen: BTreeSet<(u32, u32, ServiceSymbolTarget)> = BTreeSet::new();
        for occurrence in &analysis.occurrences {
            let located = locate_name(tree, analysis, occurrence);
            let Some(span) = located else {
                continue;
            };
            if !seen.insert((span.start, span.ending, occurrence.target)) {
                continue;
            }
            entries.push(NamedOccurrence {
                span,
                target: occurrence.target,
                is_declaration: occurrence.is_declaration,
                is_write: occurrence.is_write || is_assignment_target(tree, span),
            });
        }
        entries.sort_by_key(|entry| (entry.span.start, entry.span.ending));
        Self { entries }
    }

    pub fn at_offset(&self, offset: usize) -> Option<&NamedOccurrence> {
        let position = u32::try_from(offset).unwrap_or(u32::MAX);
        self.entries
            .iter()
            .find(|entry| entry.span.start <= position && position <= entry.span.ending)
    }

    pub fn occurrences_of(&self, target: ServiceSymbolTarget) -> Vec<&NamedOccurrence> {
        self.entries
            .iter()
            .filter(|entry| entry.target == target)
            .collect()
    }

    pub fn declaration_of(&self, target: ServiceSymbolTarget) -> Option<&NamedOccurrence> {
        self.entries
            .iter()
            .find(|entry| entry.target == target && entry.is_declaration)
    }

    pub fn user_name_starts(&self) -> impl Iterator<Item = u32> + '_ {
        self.entries.iter().map(|entry| entry.span.start)
    }
}

fn locate_name(
    tree: &SyntaxTree,
    analysis: &ServiceAnalysis,
    occurrence: &ServiceReference,
) -> Option<Span> {
    let span = occurrence.span;
    let is_declaration = occurrence.is_declaration;
    match occurrence.target {
        ServiceSymbolTarget::Local(_) => single_identifier(tree, span),
        ServiceSymbolTarget::Field(_) if is_declaration => first_identifier_from(tree, span),
        ServiceSymbolTarget::Field(_) => last_identifier_within(tree, span),
        ServiceSymbolTarget::Class(_) if is_declaration => first_identifier_from(tree, span),
        ServiceSymbolTarget::Class(_) => single_identifier(tree, span),
        ServiceSymbolTarget::Function(function) if is_declaration => {
            declaration_name(tree, analysis, function.0, span)
        }
        ServiceSymbolTarget::Function(_) => callee_before_parenthesis(tree, span),
        ServiceSymbolTarget::Builtin(_) => None,
    }
}

fn declaration_name(
    tree: &SyntaxTree,
    analysis: &ServiceAnalysis,
    function: u32,
    span: Span,
) -> Option<Span> {
    let slot = usize::try_from(function).ok()?;
    let kind = analysis.module.functions.get(slot)?.kind;
    if kind == FunctionKind::Constructor {
        return first_token_of_kind(tree, span, |kind| {
            matches!(
                kind,
                TokenKind::Keyword(pseudolearn_lexicon::KeywordKind::Constructor)
            )
        });
    }
    first_identifier_from(tree, span)
}

fn token_slot_at(tree: &SyntaxTree, offset: u32) -> usize {
    tree.tokens.starts.partition_point(|start| *start < offset)
}

fn single_identifier(tree: &SyntaxTree, span: Span) -> Option<Span> {
    let slot = token_slot_at(tree, span.start);
    let token = tree.tokens.span(slot)?;
    (tree.tokens.kind(slot) == Some(TokenKind::Identifier) && token.start == span.start)
        .then_some(token)
}

fn first_identifier_from(tree: &SyntaxTree, span: Span) -> Option<Span> {
    first_token_of_kind(tree, span, |kind| kind == TokenKind::Identifier)
}

fn first_token_of_kind(
    tree: &SyntaxTree,
    span: Span,
    wanted: impl Fn(TokenKind) -> bool,
) -> Option<Span> {
    let mut slot = token_slot_at(tree, span.start);
    while let Some(token) = tree.tokens.span(slot) {
        if token.start >= span.ending {
            return None;
        }
        if tree.tokens.kind(slot).is_some_and(&wanted) {
            return Some(token);
        }
        slot = slot.saturating_add(1);
    }
    None
}

fn last_identifier_within(tree: &SyntaxTree, span: Span) -> Option<Span> {
    let mut slot = token_slot_at(tree, span.start);
    let mut found = None;
    while let Some(token) = tree.tokens.span(slot) {
        if token.start >= span.ending {
            break;
        }
        if tree.tokens.kind(slot) == Some(TokenKind::Identifier) {
            found = Some(token);
        }
        slot = slot.saturating_add(1);
    }
    found
}

fn callee_before_parenthesis(tree: &SyntaxTree, span: Span) -> Option<Span> {
    let mut slot = token_slot_at(tree, span.start);
    let mut candidate = None;
    while let Some(token) = tree.tokens.span(slot) {
        if token.start >= span.ending {
            return None;
        }
        match tree.tokens.kind(slot) {
            Some(TokenKind::Identifier) => candidate = Some(token),
            Some(TokenKind::LeftParenthesis) => return candidate,
            _ => {}
        }
        slot = slot.saturating_add(1);
    }
    None
}

fn is_assignment_target(tree: &SyntaxTree, span: Span) -> bool {
    let slot = token_slot_at(tree, span.start);
    if tree.tokens.kind(slot) != Some(TokenKind::Identifier) {
        return false;
    }
    if follows_read_keyword(tree, slot) {
        return true;
    }
    let mut cursor = next_code_slot(tree, slot);
    if tree.tokens.kind(cursor) == Some(TokenKind::LeftBracket) {
        cursor = skip_brackets(tree, cursor);
    }
    tree.tokens.kind(cursor) == Some(TokenKind::Assignment)
}

fn follows_read_keyword(tree: &SyntaxTree, slot: usize) -> bool {
    let mut cursor = slot;
    while cursor > 0 {
        cursor = cursor.saturating_sub(1);
        match tree.tokens.kind(cursor) {
            Some(TokenKind::Whitespace) => {}
            Some(TokenKind::Keyword(pseudolearn_lexicon::KeywordKind::Read)) => return true,
            Some(TokenKind::Comma | TokenKind::Identifier | TokenKind::Dot) => {}
            _ => return false,
        }
    }
    false
}

fn next_code_slot(tree: &SyntaxTree, slot: usize) -> usize {
    let mut cursor = slot.saturating_add(1);
    while tree.tokens.kind(cursor) == Some(TokenKind::Whitespace) {
        cursor = cursor.saturating_add(1);
    }
    cursor
}

fn skip_brackets(tree: &SyntaxTree, open: usize) -> usize {
    let mut depth = 0u32;
    let mut cursor = open;
    while let Some(kind) = tree.tokens.kind(cursor) {
        match kind {
            TokenKind::LeftBracket => depth = depth.saturating_add(1),
            TokenKind::RightBracket => {
                depth = depth.saturating_sub(1);
                if depth == 0 {
                    return next_code_slot(tree, cursor);
                }
            }
            TokenKind::Newline | TokenKind::EndOfFile => return cursor,
            _ => {}
        }
        cursor = cursor.saturating_add(1);
    }
    cursor
}
