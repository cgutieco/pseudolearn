use crate::ValueId;
use crate::lexer::TokenKind;
use crate::parser::Parser;

impl Parser {
    pub(crate) fn parse_optional_result(&mut self) -> Option<ValueId> {
        if let TokenKind::Value(number) = self.peek() {
            let value_number = *number;
            if self
                .tokens
                .get(self.cursor.saturating_add(1))
                .map(|token| &token.kind)
                == Some(&TokenKind::Equal)
            {
                let _ = self.advance();
                let _ = self.advance();
                return Some(ValueId(value_number));
            }
        }
        None
    }
}
