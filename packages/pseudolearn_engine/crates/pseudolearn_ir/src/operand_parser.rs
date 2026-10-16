#![forbid(unsafe_code)]

use crate::identities::{BlockId, ValueId};
use crate::lexer::{Token, TokenKind};
use crate::operand::{Operand, PredicateKind};
use crate::types::IrType;

pub fn parse_operand(
    tokens: &[Token],
    cursor: &mut usize,
    parse_type_fn: impl Fn(&[Token], &mut usize) -> Result<IrType, String>,
) -> Result<Operand, String> {
    let token = tokens
        .get(*cursor)
        .ok_or("Unexpected end of tokens for operand")?;
    match &token.kind {
        TokenKind::Value(number) => {
            *cursor = cursor.saturating_add(1);
            Ok(Operand::Value(ValueId(*number)))
        }
        TokenKind::Block(number) => parse_block_target(tokens, cursor, *number),
        TokenKind::FunctionAt(identifier) => parse_function_target(tokens, cursor, identifier),
        TokenKind::Integer(number) => {
            let value = *number;
            *cursor = cursor.saturating_add(1);
            Ok(Operand::LiteralI64(value))
        }
        TokenKind::Float(number) => {
            let value = *number;
            *cursor = cursor.saturating_add(1);
            Ok(Operand::LiteralF64(value))
        }
        TokenKind::CharLiteral(character) => {
            let value = *character;
            *cursor = cursor.saturating_add(1);
            Ok(Operand::LiteralChar(value))
        }
        TokenKind::StringLiteral(content) => {
            let value = content.clone();
            *cursor = cursor.saturating_add(1);
            Ok(Operand::LiteralStr(value))
        }
        TokenKind::Word(word) => parse_word_operand(tokens, cursor, word, parse_type_fn),
        other => Err(format!("Unexpected operand token {other:?}")),
    }
}

fn parse_block_target(
    tokens: &[Token],
    cursor: &mut usize,
    block_number: u32,
) -> Result<Operand, String> {
    *cursor = cursor.saturating_add(1);
    expect_token(tokens, cursor, &TokenKind::OpenParen)?;
    let mut arguments = Vec::new();
    while tokens.get(*cursor).map(|token| &token.kind) != Some(&TokenKind::CloseParen) {
        arguments.push(parse_value_id(tokens, cursor)?);
        if tokens.get(*cursor).map(|token| &token.kind) == Some(&TokenKind::Comma) {
            *cursor = cursor.saturating_add(1);
        }
    }
    expect_token(tokens, cursor, &TokenKind::CloseParen)?;
    Ok(Operand::BlockTarget {
        target_block: BlockId(block_number),
        arguments,
    })
}

fn parse_function_target(
    tokens: &[Token],
    cursor: &mut usize,
    function_name: &str,
) -> Result<Operand, String> {
    let name = function_name.to_owned();
    *cursor = cursor.saturating_add(1);
    expect_token(tokens, cursor, &TokenKind::OpenParen)?;
    let mut arguments = Vec::new();
    while tokens.get(*cursor).map(|token| &token.kind) != Some(&TokenKind::CloseParen) {
        arguments.push(parse_value_id(tokens, cursor)?);
        if tokens.get(*cursor).map(|token| &token.kind) == Some(&TokenKind::Comma) {
            *cursor = cursor.saturating_add(1);
        }
    }
    expect_token(tokens, cursor, &TokenKind::CloseParen)?;
    Ok(Operand::FunctionTarget {
        function_name: name,
        arguments,
    })
}

fn parse_word_operand(
    tokens: &[Token],
    cursor: &mut usize,
    word: &str,
    parse_type_fn: impl Fn(&[Token], &mut usize) -> Result<IrType, String>,
) -> Result<Operand, String> {
    let text = word.to_owned();
    match text.as_str() {
        "true" => {
            *cursor = cursor.saturating_add(1);
            Ok(Operand::LiteralBool(true))
        }
        "false" => {
            *cursor = cursor.saturating_add(1);
            Ok(Operand::LiteralBool(false))
        }
        "newline" => {
            *cursor = cursor.saturating_add(1);
            Ok(Operand::Newline)
        }
        pred if PredicateKind::from_name(pred).is_some() => {
            *cursor = cursor.saturating_add(1);
            let predicate = PredicateKind::from_name(pred).ok_or("Invalid predicate")?;
            Ok(Operand::Predicate(predicate))
        }
        ir_type if IrType::parse_type(ir_type).is_some() || is_compound_type_head(ir_type) => {
            let parsed = parse_type_fn(tokens, cursor)?;
            Ok(Operand::Type(parsed))
        }
        _ => {
            *cursor = cursor.saturating_add(1);
            Ok(Operand::Identifier(text))
        }
    }
}

fn is_compound_type_head(word: &str) -> bool {
    matches!(word, "array" | "cell" | "obj")
}

fn parse_value_id(tokens: &[Token], cursor: &mut usize) -> Result<ValueId, String> {
    let token = tokens.get(*cursor).ok_or("Expected value %n")?;
    match &token.kind {
        TokenKind::Value(number) => {
            *cursor = cursor.saturating_add(1);
            Ok(ValueId(*number))
        }
        other => Err(format!("Expected value %n, found {other:?}")),
    }
}

fn expect_token(tokens: &[Token], cursor: &mut usize, expected: &TokenKind) -> Result<(), String> {
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
