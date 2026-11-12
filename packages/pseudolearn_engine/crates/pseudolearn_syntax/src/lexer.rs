use crate::literal_scanner::{
    scan_block_comment, scan_line_comment, scan_literal, scan_numeric_literal,
};
use crate::operator_scanner::scan_operator_or_punctuation;
use crate::tokens::{TokenKind, Tokens};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::{KeywordKind, Profile, find_keyword};
use pseudolearn_source::{IdentifierNormalizer, SourceText, Span, source_id};

pub struct Lexer<'source> {
    source: &'source SourceText,
    pub(crate) profile: Profile,
    project_mode: bool,
    cursor: usize,
    pub(crate) tokens: Tokens,
    diagnostics: Vec<Diagnostic>,
}

impl<'source> Lexer<'source> {
    pub fn new(source: &'source SourceText, profile: Profile) -> Self {
        let initial_cursor = usize::try_from(source.bom_prefix_length()).unwrap_or(0);
        Self {
            source,
            profile,
            project_mode: false,
            cursor: initial_cursor,
            tokens: Tokens::for_source(source_id(source)),
            diagnostics: Vec::new(),
        }
    }

    pub(crate) fn new_for_project(source: &'source SourceText, profile: Profile) -> Self {
        Self {
            project_mode: true,
            ..Self::new(source, profile)
        }
    }

    pub fn scan(mut self) -> (Tokens, Vec<Diagnostic>) {
        let total_bytes = self.source.as_str().len();
        while self.cursor < total_bytes {
            self.scan_next_token();
        }
        let final_offset = u32::try_from(total_bytes).unwrap_or(u32::MAX);
        self.tokens
            .push(TokenKind::EndOfFile, final_offset, final_offset);
        (self.tokens, self.diagnostics)
    }

    fn scan_next_token(&mut self) {
        let remainder = self.current_slice();
        let first_character = match remainder.chars().next() {
            Some(character) => character,
            None => return,
        };
        let start_offset = self.current_u32();

        if self.scan_leading_trivia(remainder, first_character, start_offset) {
            return;
        }
        if first_character == '"' {
            self.scan_string_token(start_offset);
            return;
        }
        if first_character == '\'' {
            self.scan_character_token(start_offset);
            return;
        }
        if first_character.is_ascii_digit() {
            self.scan_number_token(start_offset);
            return;
        }
        if first_character.is_alphabetic() || first_character == '_' {
            self.scan_identifier_or_keyword(start_offset);
            return;
        }
        self.scan_punctuation_token(start_offset);
    }

    fn scan_leading_trivia(
        &mut self,
        remainder: &str,
        first_character: char,
        start_offset: u32,
    ) -> bool {
        if first_character == ' ' || first_character == '\t' {
            self.scan_whitespace(start_offset);
            return true;
        }
        if first_character == '\r' || first_character == '\n' {
            self.scan_newline(start_offset);
            return true;
        }
        if remainder.starts_with("//") {
            let advance = scan_line_comment(remainder);
            self.advance_by(advance);
            self.tokens
                .push(TokenKind::Comment, start_offset, self.current_u32());
            return true;
        }
        if remainder.starts_with("/*") {
            self.scan_block_comment_token(start_offset);
            return true;
        }
        false
    }

    fn scan_whitespace(&mut self, start_offset: u32) {
        while let Some(character) = self.current_slice().chars().next() {
            if character == ' ' || character == '\t' {
                self.advance_by(character.len_utf8());
            } else {
                break;
            }
        }
        self.tokens
            .push(TokenKind::Whitespace, start_offset, self.current_u32());
    }

    fn scan_newline(&mut self, start_offset: u32) {
        let remainder = self.current_slice();
        if remainder.starts_with("\r\n") {
            self.advance_by(2);
        } else {
            self.advance_by(1);
        }
        self.tokens
            .push(TokenKind::Newline, start_offset, self.current_u32());
    }

    fn scan_block_comment_token(&mut self, start_offset: u32) {
        let (advance, closed) = scan_block_comment(self.current_slice());
        self.advance_by(advance);
        let ending_offset = self.current_u32();
        if !closed {
            let span = self.source_span(start_offset, ending_offset);
            self.diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnterminatedString, span));
        }
        self.tokens
            .push(TokenKind::Comment, start_offset, ending_offset);
    }

    fn scan_string_token(&mut self, start_offset: u32) {
        let literal = scan_literal(self.current_slice());
        self.advance_by(literal.bytes);
        let span = self.source_span(start_offset, self.current_u32());
        if !literal.closed {
            self.diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnterminatedString, span));
        }
        if let Some((offset, escape)) = &literal.invalid_escape {
            let start = start_offset.saturating_add(u32::try_from(*offset).unwrap_or(0));
            let ending = start.saturating_add(u32::try_from(escape.len()).unwrap_or(0));
            self.diagnostics.push(
                Diagnostic::new(
                    DiagnosticCode::InvalidEscapeSequence,
                    self.source_span(start, ending),
                )
                .with_argument("lexeme", escape),
            );
        }
        let invalid = !literal.closed || literal.invalid_escape.is_some();
        let kind = if invalid {
            TokenKind::InvalidCharacter
        } else if literal.content.chars().count() == 1 {
            TokenKind::CharacterLiteral
        } else {
            TokenKind::StringLiteral
        };
        self.tokens.push(kind, start_offset, self.current_u32());
    }

    fn scan_character_token(&mut self, start_offset: u32) {
        self.scan_string_token(start_offset);
    }

    fn scan_number_token(&mut self, start_offset: u32) {
        let (advance, is_real) = scan_numeric_literal(self.current_slice());
        self.advance_by(advance);
        let kind = if is_real {
            TokenKind::RealLiteral
        } else {
            TokenKind::IntegerLiteral
        };
        let ending = self.current_u32();
        let lexeme = self.slice_from(start_offset, ending);
        if !is_real && lexeme.parse::<i64>().is_err() {
            self.diagnostics.push(
                Diagnostic::new(
                    DiagnosticCode::IntegerLiteralOutOfRange,
                    self.source_span(start_offset, ending),
                )
                .with_argument("lexeme", lexeme),
            );
        }
        let kind = if !is_real && lexeme.parse::<i64>().is_err() {
            TokenKind::InvalidCharacter
        } else {
            kind
        };
        self.tokens.push(kind, start_offset, ending);
    }

    fn scan_punctuation_token(&mut self, start_offset: u32) {
        let (kind, advance) = scan_operator_or_punctuation(self.current_slice());
        self.advance_by(advance);
        let ending_offset = self.current_u32();
        if kind == TokenKind::InvalidCharacter {
            let span = self.source_span(start_offset, ending_offset);
            let bad_character = self.slice_from(start_offset, ending_offset);
            self.diagnostics.push(
                Diagnostic::new(DiagnosticCode::UnrecognizedCharacter, span)
                    .with_argument("lexeme", bad_character),
            );
        }
        self.tokens.push(kind, start_offset, ending_offset);
    }

    fn scan_identifier_or_keyword(&mut self, start_offset: u32) {
        while let Some(character) = self.current_slice().chars().next() {
            if pseudolearn_source::IdentifierNormalizer::is_continuation(character) {
                self.advance_by(character.len_utf8());
            } else {
                break;
            }
        }
        let ending_offset = self.current_u32();
        self.classify_identifier(start_offset, ending_offset);
    }

    fn classify_identifier(&mut self, start_offset: u32, ending_offset: u32) {
        let word = self.slice_from(start_offset, ending_offset);
        if !IdentifierNormalizer::is_valid_identifier(word) {
            self.push_invalid_identifier(start_offset, ending_offset, word);
            return;
        }
        if self.match_compound_keyword(word, start_offset) {
            return;
        }
        let kind = match find_keyword(word, self.profile) {
            Some(KeywordKind::ImportKeyword | KeywordKind::ExportKeyword) if !self.project_mode => {
                TokenKind::Identifier
            }
            Some(KeywordKind::BooleanTrue) => TokenKind::BooleanLiteral(true),
            Some(KeywordKind::BooleanFalse) => TokenKind::BooleanLiteral(false),
            Some(keyword) => TokenKind::Keyword(keyword),
            None => TokenKind::Identifier,
        };
        self.tokens.push(kind, start_offset, ending_offset);
    }

    fn push_invalid_identifier(&mut self, start_offset: u32, ending_offset: u32, word: &str) {
        let span = self.source_span(start_offset, ending_offset);
        self.diagnostics.push(
            Diagnostic::new(DiagnosticCode::UnrecognizedCharacter, span)
                .with_argument("lexeme", word),
        );
        self.tokens
            .push(TokenKind::InvalidCharacter, start_offset, ending_offset);
    }

    pub(crate) fn current_slice(&self) -> &'source str {
        self.source.as_str().get(self.cursor..).unwrap_or("")
    }

    fn source_span(&self, start: u32, ending: u32) -> Span {
        Span::in_source(pseudolearn_source::source_id(self.source), start, ending)
    }

    fn slice_from(&self, start: u32, ending: u32) -> &'source str {
        let start_index = usize::try_from(start).unwrap_or(0);
        let ending_index = usize::try_from(ending).unwrap_or(start_index);
        self.source
            .as_str()
            .get(start_index..ending_index)
            .unwrap_or("")
    }

    pub(crate) fn advance_by(&mut self, count: usize) {
        self.cursor = self.cursor.saturating_add(count);
    }

    pub(crate) fn current_u32(&self) -> u32 {
        u32::try_from(self.cursor).unwrap_or(u32::MAX)
    }
}
