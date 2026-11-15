use crate::identifier_roles::IdentifierRoles;
use crate::source_lines::SourceLine;
use crate::spelling::{boolean_spelling, builtin_spelling, positioned_keyword_spelling};
use pseudolearn_lexicon::{KeywordKind, Profile, find_builtin};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind};
use std::collections::BTreeSet;

pub struct RenderContext<'context> {
    pub tree: &'context SyntaxTree,
    pub source: &'context SourceText,
    pub profile: Profile,
    pub roles: &'context IdentifierRoles,
    pub angle_brackets: &'context BTreeSet<usize>,
}

#[derive(Clone, Debug)]
struct Piece {
    text: String,
    kind: TokenKind,
    unary: bool,
    angle: bool,
}

pub fn render_line(
    context: &RenderContext<'_>,
    line: &SourceLine,
    terminated_statement: bool,
) -> String {
    let mut pieces: Vec<Piece> = line
        .order
        .iter()
        .map(|index| piece_for(context, *index))
        .collect();
    if terminated_statement {
        adjust_terminator(&mut pieces);
    }
    mark_unary_operators(&mut pieces);
    join_pieces(&pieces)
}

fn piece_for(context: &RenderContext<'_>, index: usize) -> Piece {
    let kind = context
        .tree
        .tokens
        .kind(index)
        .unwrap_or(TokenKind::Whitespace);
    let original = context
        .tree
        .tokens
        .text(context.source.as_str(), index)
        .unwrap_or("");
    let text = match kind {
        TokenKind::Keyword(keyword) => {
            positioned_keyword_spelling(context.tree, index, keyword, context.profile)
        }
        TokenKind::BooleanLiteral(value) => boolean_spelling(value, context.profile),
        TokenKind::Identifier => identifier_text(context, index, original),
        TokenKind::Assignment => "<-".to_owned(),
        TokenKind::Comment => normalize_comment(original),
        _ => original.to_owned(),
    };
    Piece {
        text,
        kind,
        unary: false,
        angle: context.angle_brackets.contains(&index),
    }
}

fn identifier_text(context: &RenderContext<'_>, index: usize, original: &str) -> String {
    if let Some(identity) = context.roles.contextual_identity(index) {
        return crate::spelling::contextual_word_spelling(
            context.tree,
            index,
            identity,
            context.profile,
        )
        .unwrap_or_else(|| original.to_owned());
    }
    if context
        .roles
        .is_user_name(context.tree, context.source, index)
    {
        return original.to_owned();
    }
    match find_builtin(original, context.profile) {
        Some(builtin) => builtin_spelling(builtin, context.profile),
        None => operation_alias_spelling(original, context.profile)
            .unwrap_or(original)
            .to_owned(),
    }
}

fn operation_alias_spelling(original: &str, profile: Profile) -> Option<&'static str> {
    let spanish = profile == Profile::Spanish;
    let operation = pseudolearn_semantic::EFFECT_OPERATIONS
        .iter()
        .filter(|operation| operation.receiver.is_none())
        .find(|operation| {
            let aliases = if spanish {
                operation.spanish_aliases
            } else {
                operation.english_aliases
            };
            aliases
                .iter()
                .any(|alias| alias.eq_ignore_ascii_case(original))
        })?;
    Some(if spanish {
        operation.spanish
    } else {
        operation.english
    })
}

fn normalize_comment(original: &str) -> String {
    let trimmed = original.trim_end();
    let Some(rest) = trimmed.strip_prefix("//") else {
        return original.to_owned();
    };
    if rest.is_empty() || rest.starts_with(' ') || rest.starts_with('\t') {
        return trimmed.to_owned();
    }
    format!("// {rest}")
}

fn adjust_terminator(pieces: &mut Vec<Piece>) {
    let last_code = pieces
        .iter()
        .rposition(|piece| piece.kind != TokenKind::Comment);
    let Some(position) = last_code else {
        return;
    };
    let ends_with_semicolon = pieces
        .get(position)
        .is_some_and(|piece| piece.kind == TokenKind::Semicolon);
    if !ends_with_semicolon {
        pieces.insert(
            position.saturating_add(1),
            Piece {
                text: ";".to_owned(),
                kind: TokenKind::Semicolon,
                unary: false,
                angle: false,
            },
        );
    }
}

fn mark_unary_operators(pieces: &mut [Piece]) {
    let mut previous: Option<TokenKind> = None;
    for piece in pieces.iter_mut() {
        if piece.kind == TokenKind::Comment {
            continue;
        }
        if matches!(piece.kind, TokenKind::Minus | TokenKind::Plus) {
            piece.unary = !previous.is_some_and(ends_operand);
        }
        previous = Some(piece.kind);
    }
}

fn ends_operand(kind: TokenKind) -> bool {
    kind.is_literal()
        || matches!(
            kind,
            TokenKind::Identifier
                | TokenKind::RightParenthesis
                | TokenKind::RightBracket
                | TokenKind::Keyword(KeywordKind::ThisObject | KeywordKind::SuperClass)
        )
}

fn join_pieces(pieces: &[Piece]) -> String {
    let mut rendered = String::new();
    let mut previous: Option<&Piece> = None;
    let last_index = pieces.len().saturating_sub(1);
    for (position, piece) in pieces.iter().enumerate() {
        if let Some(before) = previous {
            let trailing_comment = piece.kind == TokenKind::Comment && position == last_index;
            rendered.push_str(gap(before, piece, trailing_comment));
        }
        rendered.push_str(&piece.text);
        previous = Some(piece);
    }
    rendered
}

fn gap(before: &Piece, after: &Piece, trailing_comment: bool) -> &'static str {
    if after.kind == TokenKind::Comment {
        return if trailing_comment { "  " } else { " " };
    }
    if before.kind == TokenKind::Comment {
        return " ";
    }
    if hugs_previous(after.kind) || hugs_next(before) || after.angle || opens_type_list(before) {
        return "";
    }
    if after.kind == TokenKind::LeftParenthesis
        && (opens_call(before.kind, true)
            || closes_type_list(before)
            || precedes_own_parentheses(before.kind))
    {
        return "";
    }
    if after.kind == TokenKind::LeftBracket && opens_call(before.kind, false) {
        return "";
    }
    " "
}

fn opens_type_list(before: &Piece) -> bool {
    before.angle && before.kind == TokenKind::Less
}

fn closes_type_list(before: &Piece) -> bool {
    before.angle && before.kind == TokenKind::Greater
}

fn precedes_own_parentheses(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Keyword(
            KeywordKind::SomeVariant
                | KeywordKind::SuccessVariant
                | KeywordKind::ErrorVariant
                | KeywordKind::Subroutine
                | KeywordKind::Function
        )
    )
}

fn hugs_previous(kind: TokenKind) -> bool {
    matches!(
        kind,
        TokenKind::Comma
            | TokenKind::Semicolon
            | TokenKind::Colon
            | TokenKind::RightParenthesis
            | TokenKind::RightBracket
            | TokenKind::Dot
    )
}

fn hugs_next(before: &Piece) -> bool {
    match before.kind {
        TokenKind::LeftParenthesis | TokenKind::LeftBracket | TokenKind::Dot => true,
        TokenKind::Minus | TokenKind::Plus => before.unary,
        TokenKind::LogicalNot => true,
        _ => false,
    }
}

fn opens_call(before: TokenKind, parenthesis: bool) -> bool {
    let constructor_like =
        parenthesis && matches!(before, TokenKind::Keyword(KeywordKind::Constructor));
    ends_operand(before) && !before.is_literal() || constructor_like
}
