#![forbid(unsafe_code)]

use crate::lexer::{Token, TokenKind};
use crate::types::IrType;

pub fn parse_type_tokens(tokens: &[Token], cursor: &mut usize) -> Result<IrType, String> {
    let token = tokens
        .get(*cursor)
        .ok_or("Unexpected end of tokens for type")?;
    *cursor = cursor.saturating_add(1);
    match &token.kind {
        TokenKind::Word(word) => match word.as_str() {
            "i64" => Ok(IrType::I64),
            "f64" => Ok(IrType::F64),
            "bool" => Ok(IrType::Bool),
            "char" => Ok(IrType::Char),
            "str" => Ok(IrType::Str),
            "unit" => Ok(IrType::Unit),
            _ => parse_compound_type_tokens(word, tokens, cursor),
        },
        other => Err(format!("Expected type token, found {other:?}")),
    }
}

fn parse_compound_type_tokens(
    word: &str,
    tokens: &[Token],
    cursor: &mut usize,
) -> Result<IrType, String> {
    match word {
        "cell" => {
            expect_exact_token(tokens, cursor, &TokenKind::Less)?;
            let inner = parse_type_tokens(tokens, cursor)?;
            expect_exact_token(tokens, cursor, &TokenKind::Greater)?;
            Ok(IrType::Cell(Box::new(inner)))
        }
        "obj" => {
            expect_exact_token(tokens, cursor, &TokenKind::Less)?;
            let class_name = parse_word_token(tokens, cursor)?;
            expect_exact_token(tokens, cursor, &TokenKind::Greater)?;
            Ok(IrType::Object(class_name))
        }
        "array" => parse_array_type(tokens, cursor),
        _ => Err(format!("Unknown type: {word}")),
    }
}

fn parse_array_type(tokens: &[Token], cursor: &mut usize) -> Result<IrType, String> {
    expect_exact_token(tokens, cursor, &TokenKind::Less)?;
    let element = parse_type_tokens(tokens, cursor)?;
    expect_exact_token(tokens, cursor, &TokenKind::Comma)?;
    let rank = match tokens
        .get(*cursor)
        .map(|candidate_token| &candidate_token.kind)
    {
        Some(TokenKind::Integer(number)) => {
            *cursor = cursor.saturating_add(1);
            u32::try_from(*number).map_err(|error| error.to_string())?
        }
        other => return Err(format!("Expected array rank, found {other:?}")),
    };
    expect_exact_token(tokens, cursor, &TokenKind::Greater)?;
    Ok(IrType::Array {
        element: Box::new(element),
        dimension_rank: rank,
    })
}

pub fn expect_exact_token(
    tokens: &[Token],
    cursor: &mut usize,
    expected: &TokenKind,
) -> Result<(), String> {
    let token = tokens
        .get(*cursor)
        .ok_or_else(|| format!("Expected {expected:?}, found EOF"))?;
    if &token.kind == expected {
        *cursor = cursor.saturating_add(1);
        Ok(())
    } else {
        Err(format!("Expected {expected:?}, found {:?}", token.kind))
    }
}

pub fn parse_word_token(tokens: &[Token], cursor: &mut usize) -> Result<String, String> {
    let token = tokens.get(*cursor).ok_or("Expected word")?;
    match &token.kind {
        TokenKind::Word(word) => {
            *cursor = cursor.saturating_add(1);
            Ok(word.clone())
        }
        other => Err(format!("Expected word, found {other:?}")),
    }
}
