#![forbid(unsafe_code)]

use crate::lexer::Lexer;
use crate::tokens::TokenKind;

impl Lexer<'_> {
    pub(crate) fn scalar_at(&self) -> Option<(char, usize)> {
        let rest = self.characters.get(self.position..)?;
        let width = match rest.first()? {
            0..=0x7F => 1,
            0xC0..=0xDF => 2,
            0xE0..=0xEF => 3,
            _ => 4,
        };
        let text = std::str::from_utf8(rest.get(..width)?).ok()?;
        text.chars().next().map(|character| (character, width))
    }

    pub(crate) fn lex_string(&mut self) -> Result<TokenKind, String> {
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        let mut text = String::new();
        while let Some(&byte) = self.characters.get(self.position) {
            if byte == b'"' {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
                return Ok(TokenKind::StringLiteral(text));
            }
            if byte == b'\\' {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
                let escaped = match self.characters.get(self.position) {
                    Some(b'n') => '\n',
                    Some(b't') => '\t',
                    Some(b'r') => '\r',
                    Some(b'\\') => '\\',
                    Some(b'"') => '"',
                    _ => return Err("Invalid string escape".to_owned()),
                };
                text.push(escaped);
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
            } else {
                let (character, width) =
                    self.scalar_at().ok_or("Invalid UTF-8 in string literal")?;
                text.push(character);
                self.position = self.position.saturating_add(width);
                self.column = self.column.saturating_add(1);
            }
        }
        Err("Unterminated string literal".to_owned())
    }

    pub(crate) fn lex_char(&mut self) -> Result<TokenKind, String> {
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        let character = match self.characters.get(self.position) {
            Some(&b'\\') => {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
                match self.characters.get(self.position) {
                    Some(b'n') => '\n',
                    Some(b't') => '\t',
                    Some(b'r') => '\r',
                    Some(b'\\') => '\\',
                    Some(b'\'') => '\'',
                    _ => return Err("Invalid char escape".to_owned()),
                }
            }
            Some(_) => {
                let (scalar, width) = self.scalar_at().ok_or("Invalid UTF-8 in char literal")?;
                self.position = self.position.saturating_add(width.saturating_sub(1));
                scalar
            }
            None => return Err("Unterminated character literal".to_owned()),
        };
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        if self.characters.get(self.position) != Some(&b'\'') {
            return Err("Expected closing single quote for char literal".to_owned());
        }
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        Ok(TokenKind::CharLiteral(character))
    }
}
