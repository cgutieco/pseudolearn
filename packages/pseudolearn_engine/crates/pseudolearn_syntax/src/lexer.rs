use crate::literal_scanner::{
    scan_block_comment, scan_character_literal, scan_line_comment, scan_numeric_literal,
    scan_string_literal,
};
use crate::operator_scanner::scan_operator_or_punctuation;
use crate::tokens::{TokenKind, Tokens};
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_lexicon::{KeywordKind, Profile, find_keyword};
use pseudolearn_source::{SourceText, Span};

pub struct Lexer<'source> {
    source: &'source SourceText,
    profile: Profile,
    cursor: usize,
    tokens: Tokens,
    diagnostics: Vec<Diagnostic>,
}

impl<'source> Lexer<'source> {
    pub fn new(source: &'source SourceText, profile: Profile) -> Self {
        let initial_cursor = usize::try_from(source.bom_prefix_length()).unwrap_or(0);
        Self {
            source,
            profile,
            cursor: initial_cursor,
            tokens: Tokens::new(),
            diagnostics: Vec::new(),
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
            let span = Span::new(start_offset, ending_offset);
            self.diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnterminatedString, span));
        }
        self.tokens
            .push(TokenKind::Comment, start_offset, ending_offset);
    }

    fn scan_string_token(&mut self, start_offset: u32) {
        let (advance, closed) = scan_string_literal(self.current_slice());
        self.advance_by(advance);
        let ending_offset = self.current_u32();
        if !closed {
            let span = Span::new(start_offset, ending_offset);
            self.diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnterminatedString, span));
        }
        self.tokens
            .push(TokenKind::StringLiteral, start_offset, ending_offset);
    }

    fn scan_character_token(&mut self, start_offset: u32) {
        let (advance, closed) = scan_character_literal(self.current_slice());
        self.advance_by(advance);
        let ending_offset = self.current_u32();
        if !closed {
            let span = Span::new(start_offset, ending_offset);
            self.diagnostics
                .push(Diagnostic::new(DiagnosticCode::UnterminatedString, span));
        }
        self.tokens
            .push(TokenKind::CharacterLiteral, start_offset, ending_offset);
    }

    fn scan_number_token(&mut self, start_offset: u32) {
        let (advance, is_real) = scan_numeric_literal(self.current_slice());
        self.advance_by(advance);
        let kind = if is_real {
            TokenKind::RealLiteral
        } else {
            TokenKind::IntegerLiteral
        };
        self.tokens.push(kind, start_offset, self.current_u32());
    }

    fn scan_punctuation_token(&mut self, start_offset: u32) {
        let (kind, advance) = scan_operator_or_punctuation(self.current_slice());
        self.advance_by(advance);
        let ending_offset = self.current_u32();
        if kind == TokenKind::InvalidCharacter {
            let span = Span::new(start_offset, ending_offset);
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
            if character.is_alphanumeric() || character == '_' {
                self.advance_by(character.len_utf8());
            } else {
                break;
            }
        }
        let ending_offset = self.current_u32();
        let word = self.slice_from(start_offset, ending_offset);
        if self.match_compound_keyword(word, start_offset) {
            return;
        }
        if let Some(keyword) = find_keyword(word, self.profile) {
            let kind = match keyword {
                KeywordKind::BooleanTrue => TokenKind::BooleanLiteral(true),
                KeywordKind::BooleanFalse => TokenKind::BooleanLiteral(false),
                _ => TokenKind::Keyword(keyword),
            };
            self.tokens.push(kind, start_offset, ending_offset);
            return;
        }
        self.tokens
            .push(TokenKind::Identifier, start_offset, ending_offset);
    }

    fn match_compound_keyword(&mut self, word: &str, start_offset: u32) -> bool {
        let checkpoint = self.cursor;
        let mut whitespace_bytes: usize = 0;
        let remainder = self.current_slice();
        for character in remainder.chars() {
            if character == ' ' || character == '\t' {
                whitespace_bytes = whitespace_bytes.saturating_add(character.len_utf8());
            } else {
                break;
            }
        }
        if whitespace_bytes == 0 {
            return false;
        }
        let after_whitespace = remainder.get(whitespace_bytes..).unwrap_or("");
        let second_word_bytes = after_whitespace
            .chars()
            .take_while(|character| character.is_alphanumeric() || *character == '_')
            .map(char::len_utf8)
            .sum::<usize>();
        if second_word_bytes == 0 {
            return false;
        }
        let second_word = after_whitespace.get(..second_word_bytes).unwrap_or("");
        let combined = format!("{word} {second_word}");
        if let Some(keyword) = find_keyword(&combined, self.profile) {
            self.advance_by(whitespace_bytes.saturating_add(second_word_bytes));
            self.tokens.push(
                TokenKind::Keyword(keyword),
                start_offset,
                self.current_u32(),
            );
            return true;
        }
        self.cursor = checkpoint;
        false
    }

    fn current_slice(&self) -> &'source str {
        self.source.as_str().get(self.cursor..).unwrap_or("")
    }

    fn slice_from(&self, start: u32, ending: u32) -> &'source str {
        let start_index = usize::try_from(start).unwrap_or(0);
        let ending_index = usize::try_from(ending).unwrap_or(start_index);
        self.source
            .as_str()
            .get(start_index..ending_index)
            .unwrap_or("")
    }

    fn advance_by(&mut self, count: usize) {
        self.cursor = self.cursor.saturating_add(count);
    }

    fn current_u32(&self) -> u32 {
        u32::try_from(self.cursor).unwrap_or(u32::MAX)
    }
}
