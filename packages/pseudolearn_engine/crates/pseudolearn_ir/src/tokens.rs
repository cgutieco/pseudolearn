#![forbid(unsafe_code)]

use crate::span::IrSpan;

#[derive(Clone, Debug, PartialEq)]
pub enum TokenKind {
    Word(String),
    Value(u32),
    Block(u32),
    FunctionAt(String),
    Span(IrSpan),
    StringLiteral(String),
    CharLiteral(char),
    Integer(i64),
    Float(f64),
    Colon,
    Comma,
    Equal,
    Arrow,
    OpenParen,
    CloseParen,
    OpenBrace,
    CloseBrace,
    Less,
    Greater,
    Eof,
}

#[derive(Clone, Debug, PartialEq)]
pub struct Token {
    pub kind: TokenKind,
    pub line: u32,
    pub column: u32,
}
