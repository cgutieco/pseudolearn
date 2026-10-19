use crate::identifier_roles::IdentifierRoles;
use crate::source_lines::SourceLine;
use crate::spelling::{boolean_spelling, builtin_spelling, keyword_spelling};
use pseudolearn_lexicon::{KeywordKind, Profile, find_builtin};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{SyntaxTree, TokenKind};

pub struct RenderContext<'context> {
    pub tree: &'context SyntaxTree,
    pub source: &'context SourceText,
    pub profile: Profile,
    pub roles: &'context IdentifierRoles,
    pub strict: bool,
}

#[derive(Clone, Debug)]
struct Piece {
    text: String,
    kind: TokenKind,
    unary: bool,
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
        adjust_terminator(&mut pieces, context.strict);
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
        TokenKind::Keyword(keyword) => keyword_spelling(keyword, context.profile),
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
    }
}

fn identifier_text(context: &RenderContext<'_>, index: usize, original: &str) -> String {
    if context
        .roles
        .is_user_name(context.tree, context.source, index)
    {
        return original.to_owned();
    }
    match find_builtin(original, context.profile) {
        Some(builtin) => builtin_spelling(builtin, context.profile),
        None => original.to_owned(),
    }
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

fn adjust_terminator(pieces: &mut Vec<Piece>, strict: bool) {
    let last_code = pieces
        .iter()
        .rposition(|piece| piece.kind != TokenKind::Comment);
    let Some(position) = last_code else {
        return;
    };
    if strict {
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
                },
            );
        }
        return;
    }
    let mut cursor = position;
    loop {
        let is_semicolon = pieces
            .get(cursor)
            .is_some_and(|piece| piece.kind == TokenKind::Semicolon);
        if !is_semicolon {
            return;
        }
        pieces.remove(cursor);
        if cursor == 0 {
            return;
        }
        cursor = cursor.saturating_sub(1);
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
    if hugs_previous(after.kind) || hugs_next(before) {
        return "";
    }
    if after.kind == TokenKind::LeftParenthesis && opens_call(before.kind, true) {
        return "";
    }
    if after.kind == TokenKind::LeftBracket && opens_call(before.kind, false) {
        return "";
    }
    " "
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
