#![forbid(unsafe_code)]

use crate::span::IrSpan;
pub use crate::tokens::{Token, TokenKind};

pub struct Lexer<'source> {
    characters: &'source [u8],
    position: usize,
    line: u32,
    column: u32,
}

impl<'source> Lexer<'source> {
    pub fn new(source: &'source str) -> Self {
        Self {
            characters: source.as_bytes(),
            position: 0,
            line: 1,
            column: 1,
        }
    }

    pub fn tokenize(&mut self) -> Result<Vec<Token>, String> {
        let mut tokens = Vec::new();
        loop {
            self.skip_whitespace();
            if self.position >= self.characters.len() {
                tokens.push(Token {
                    kind: TokenKind::Eof,
                    line: self.line,
                    column: self.column,
                });
                break;
            }
            tokens.push(self.next_token()?);
        }
        Ok(tokens)
    }

    fn skip_whitespace(&mut self) {
        while let Some(&byte) = self.characters.get(self.position) {
            if byte == b'\n' {
                self.position = self.position.saturating_add(1);
                self.line = self.line.saturating_add(1);
                self.column = 1;
            } else if byte.is_ascii_whitespace() {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
            } else {
                break;
            }
        }
    }

    fn next_token(&mut self) -> Result<Token, String> {
        let start_line = self.line;
        let start_column = self.column;
        let current_byte = self.characters.get(self.position).copied().unwrap_or(0);

        let kind = match current_byte {
            b':' => self.advance_single(TokenKind::Colon),
            b',' => self.advance_single(TokenKind::Comma),
            b'=' => self.advance_single(TokenKind::Equal),
            b'(' => self.advance_single(TokenKind::OpenParen),
            b')' => self.advance_single(TokenKind::CloseParen),
            b'{' => self.advance_single(TokenKind::OpenBrace),
            b'}' => self.advance_single(TokenKind::CloseBrace),
            b'<' => self.advance_single(TokenKind::Less),
            b'>' => self.advance_single(TokenKind::Greater),
            b'-' => self.lex_minus()?,
            b'%' => self.lex_value()?,
            b'@' => self.lex_at()?,
            b'"' => self.lex_string()?,
            b'\'' => self.lex_char()?,
            digit if digit.is_ascii_digit() => self.lex_number(false)?,
            _ => self.lex_word_or_block()?,
        };

        Ok(Token {
            kind,
            line: start_line,
            column: start_column,
        })
    }

    fn advance_single(&mut self, kind: TokenKind) -> TokenKind {
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        kind
    }

    fn lex_minus(&mut self) -> Result<TokenKind, String> {
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        if let Some(&b'>') = self.characters.get(self.position) {
            self.position = self.position.saturating_add(1);
            self.column = self.column.saturating_add(1);
            return Ok(TokenKind::Arrow);
        }
        if let Some(&byte) = self.characters.get(self.position)
            && byte.is_ascii_digit()
        {
            return self.lex_number(true);
        }
        Err(format!("Unexpected '-' at {}:{}", self.line, self.column))
    }

    fn lex_value(&mut self) -> Result<TokenKind, String> {
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        let number = self.read_digits()?;
        Ok(TokenKind::Value(number))
    }

    fn lex_at(&mut self) -> Result<TokenKind, String> {
        self.position = self.position.saturating_add(1);
        self.column = self.column.saturating_add(1);
        let start = self.position;
        while let Some(&byte) = self.characters.get(self.position) {
            if byte.is_ascii_alphanumeric() || matches!(byte, b'.' | b'_' | b'-' | b':') {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
            } else {
                break;
            }
        }
        let text = std::str::from_utf8(self.characters.get(start..self.position).unwrap_or(&[]))
            .map_err(|error| error.to_string())?;
        if text.contains(':') && text.contains('-') {
            let span = IrSpan::parse(&format!("@{text}"))
                .ok_or_else(|| format!("Invalid span @{text}"))?;
            Ok(TokenKind::Span(span))
        } else {
            Ok(TokenKind::FunctionAt(format!("@{text}")))
        }
    }

    fn lex_string(&mut self) -> Result<TokenKind, String> {
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
            } else {
                text.push(char::from(byte));
            }
            self.position = self.position.saturating_add(1);
            self.column = self.column.saturating_add(1);
        }
        Err("Unterminated string literal".to_owned())
    }

    fn lex_char(&mut self) -> Result<TokenKind, String> {
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
            Some(&byte) => char::from(byte),
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

    fn lex_number(&mut self, negative: bool) -> Result<TokenKind, String> {
        let start = if negative {
            self.position.saturating_sub(1)
        } else {
            self.position
        };
        let mut is_float = false;
        while let Some(&byte) = self.characters.get(self.position) {
            if byte == b'.' {
                if let Some(&next) = self.characters.get(self.position.saturating_add(1))
                    && next.is_ascii_digit()
                {
                    is_float = true;
                    self.position = self.position.saturating_add(1);
                    self.column = self.column.saturating_add(1);
                    continue;
                }
                break;
            }
            if byte.is_ascii_digit() {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
            } else {
                break;
            }
        }
        let slice = self.characters.get(start..self.position).unwrap_or(&[]);
        let text = std::str::from_utf8(slice).map_err(|error| error.to_string())?;
        if is_float {
            let value = text.parse::<f64>().map_err(|error| error.to_string())?;
            Ok(TokenKind::Float(value))
        } else {
            let value = text.parse::<i64>().map_err(|error| error.to_string())?;
            Ok(TokenKind::Integer(value))
        }
    }

    fn lex_word_or_block(&mut self) -> Result<TokenKind, String> {
        let start = self.position;
        while let Some(&byte) = self.characters.get(self.position) {
            if byte.is_ascii_alphanumeric() || matches!(byte, b'.' | b'_') {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
            } else {
                break;
            }
        }
        let slice = self.characters.get(start..self.position).unwrap_or(&[]);
        let text = std::str::from_utf8(slice).map_err(|error| error.to_string())?;
        if text.starts_with('b')
            && text.len() > 1
            && text
                .get(1..)
                .is_some_and(|digits| digits.chars().all(|character| character.is_ascii_digit()))
        {
            let digits_slice = text.get(1..).unwrap_or("");
            if let Ok(block_number) = digits_slice.parse::<u32>() {
                return Ok(TokenKind::Block(block_number));
            }
        }
        Ok(TokenKind::Word(text.to_owned()))
    }

    fn read_digits(&mut self) -> Result<u32, String> {
        let start = self.position;
        while let Some(&byte) = self.characters.get(self.position) {
            if byte.is_ascii_digit() {
                self.position = self.position.saturating_add(1);
                self.column = self.column.saturating_add(1);
            } else {
                break;
            }
        }
        let slice = self.characters.get(start..self.position).unwrap_or(&[]);
        let text = std::str::from_utf8(slice).map_err(|error| error.to_string())?;
        text.parse::<u32>().map_err(|error| error.to_string())
    }
}
