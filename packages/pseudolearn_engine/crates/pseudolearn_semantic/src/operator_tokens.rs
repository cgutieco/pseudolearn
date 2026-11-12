use crate::expression_model::BinaryOperator;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_syntax::TokenKind;

pub(crate) fn operator(token: Option<TokenKind>) -> BinaryOperator {
    match token {
        Some(TokenKind::Minus) => BinaryOperator::Subtract,
        Some(TokenKind::Star) => BinaryOperator::Multiply,
        Some(TokenKind::Slash) => BinaryOperator::Divide,
        Some(TokenKind::IntegerDivision | TokenKind::Keyword(KeywordKind::IntegerDivide)) => {
            BinaryOperator::IntegerDivide
        }
        Some(TokenKind::Modulo | TokenKind::Keyword(KeywordKind::Modulo)) => BinaryOperator::Modulo,
        Some(TokenKind::Power) => BinaryOperator::Power,
        Some(TokenKind::Equal) => BinaryOperator::Equal,
        Some(TokenKind::NotEqual) => BinaryOperator::NotEqual,
        Some(TokenKind::Less) => BinaryOperator::Less,
        Some(TokenKind::LessEqual) => BinaryOperator::LessEqual,
        Some(TokenKind::Greater) => BinaryOperator::Greater,
        Some(TokenKind::GreaterEqual) => BinaryOperator::GreaterEqual,
        Some(TokenKind::LogicalAnd | TokenKind::Keyword(KeywordKind::And)) => {
            BinaryOperator::LogicalAnd
        }
        Some(TokenKind::LogicalOr | TokenKind::Keyword(KeywordKind::Or)) => {
            BinaryOperator::LogicalOr
        }
        _ => BinaryOperator::Add,
    }
}
