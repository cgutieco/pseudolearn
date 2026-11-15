use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::{SourceId, Span};

#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum TokenKind {
    Whitespace,
    Comment,
    Newline,
    InvalidCharacter,
    EndOfFile,

    Identifier,
    IntegerLiteral,
    RealLiteral,
    StringLiteral,
    CharacterLiteral,
    BooleanLiteral(bool),

    Keyword(KeywordKind),

    Plus,
    Minus,
    Star,
    Slash,
    Power,
    Modulo,
    IntegerDivision,

    Equal,
    NotEqual,
    Less,
    LessEqual,
    Greater,
    GreaterEqual,

    LogicalAnd,
    LogicalOr,
    LogicalNot,

    Assignment,

    LeftParenthesis,
    RightParenthesis,
    LeftBracket,
    RightBracket,

    Comma,
    Colon,
    Semicolon,
    Dot,
}

impl TokenKind {
    pub fn is_trivia(&self) -> bool {
        matches!(
            self,
            Self::Whitespace | Self::Comment | Self::Newline | Self::InvalidCharacter
        )
    }

    pub fn is_literal(&self) -> bool {
        matches!(
            self,
            Self::IntegerLiteral
                | Self::RealLiteral
                | Self::StringLiteral
                | Self::CharacterLiteral
                | Self::BooleanLiteral(_)
        )
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Tokens {
    source_id: SourceId,
    pub kinds: Vec<TokenKind>,
    pub starts: Vec<u32>,
    pub endings: Vec<u32>,
}

impl Tokens {
    pub fn new() -> Self {
        Self::for_source(SourceId::STANDALONE)
    }

    pub fn for_source(source_id: SourceId) -> Self {
        Self {
            source_id,
            kinds: Vec::new(),
            starts: Vec::new(),
            endings: Vec::new(),
        }
    }

    pub fn push(&mut self, kind: TokenKind, start: u32, ending: u32) {
        self.kinds.push(kind);
        self.starts.push(start);
        self.endings.push(ending);
    }

    pub fn token_count(&self) -> usize {
        self.kinds.len()
    }

    pub fn kind(&self, token_index: usize) -> Option<TokenKind> {
        self.kinds.get(token_index).copied()
    }

    pub fn span(&self, token_index: usize) -> Option<Span> {
        let start = self.starts.get(token_index).copied()?;
        let ending = self.endings.get(token_index).copied()?;
        Some(Span::in_source(self.source_id, start, ending))
    }

    pub fn text<'source>(&self, source: &'source str, token_index: usize) -> Option<&'source str> {
        let span = self.span(token_index)?;
        let start = usize::try_from(span.start).ok()?;
        let ending = usize::try_from(span.ending).ok()?;
        source.get(start..ending)
    }
}

impl Default for Tokens {
    fn default() -> Self {
        Self::new()
    }
}
