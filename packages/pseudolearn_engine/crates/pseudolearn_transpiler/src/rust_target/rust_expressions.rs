use super::RustEmitter;
use pseudolearn_semantic::{ExpressionId, HirExpression, Literal, Type};

pub(crate) const ATOM: u8 = 10;

impl RustEmitter<'_, '_> {
    pub(crate) fn expression(&mut self, identifier: ExpressionId) -> String {
        let span = self.view.expression_span(identifier);
        match self.view.expression(identifier) {
            HirExpression::Literal(literal) => self.literal(identifier, literal),
            HirExpression::Local(local) | HirExpression::Uninitialized(local) => {
                self.local_read(*local)
            }
            HirExpression::Unary {
                operator, operand, ..
            } => self.unary(*operator, *operand),
            HirExpression::Binary {
                operator,
                left,
                right,
                ..
            } => self.binary(identifier, *operator, (*left, *right)),
            HirExpression::Widen(inner) => self.widen(identifier, *inner),
            HirExpression::Builtin {
                function,
                arguments,
            } => self.builtin(*function, arguments, span),
            HirExpression::Channel(channel) => self.channel_operation(channel, span),
            HirExpression::Collection(collection) => self.collection_operation(collection),
            HirExpression::Effect { .. } => self.effect(identifier, span),
            HirExpression::Invalid => self.block("invalid", span),
            _ => self.compound(identifier, span),
        }
    }

    pub(crate) fn value(&mut self, identifier: ExpressionId) -> String {
        let text = self.expression(identifier);
        let copies = self
            .view
            .expression_type_id(identifier)
            .is_some_and(|type_id| self.is_copy(type_id));
        if !copies && self.is_place_expression(identifier) {
            format!("{text}.clone()")
        } else {
            text
        }
    }

    pub(crate) fn is_place_expression(&self, identifier: ExpressionId) -> bool {
        matches!(
            self.view.expression(identifier),
            HirExpression::Local(_)
                | HirExpression::Field { .. }
                | HirExpression::Element { .. }
                | HirExpression::RecordField { .. }
                | HirExpression::Captured { .. }
                | HirExpression::This(_)
        )
    }

    pub(crate) fn precedence(&self, identifier: ExpressionId) -> u8 {
        match self.view.expression(identifier) {
            HirExpression::Binary { operator, .. } => {
                super::rust_operators::binary_precedence(*operator)
            }
            HirExpression::Unary { .. } => 9,
            HirExpression::Widen(inner) => {
                if matches!(self.view.expression_type(identifier), Type::Real)
                    && matches!(self.view.expression_type(*inner), Type::Integer)
                {
                    8
                } else {
                    self.precedence(*inner)
                }
            }
            HirExpression::Literal(Literal::Integer(value)) if *value < 0 => 9,
            HirExpression::Literal(Literal::Real(value)) if value.is_sign_negative() => 9,
            _ => ATOM,
        }
    }

    pub(crate) fn operand(&mut self, identifier: ExpressionId, minimum: u8) -> String {
        let text = self.expression(identifier);
        if self.precedence(identifier) < minimum {
            format!("({text})")
        } else {
            text
        }
    }

    pub(crate) fn literal(&mut self, identifier: ExpressionId, literal: &Literal) -> String {
        if let Type::Enum(enumeration) = self.view.expression_type(identifier)
            && let Literal::Integer(ordinal) = literal
        {
            return self.enum_member(enumeration.0, *ordinal);
        }
        match literal {
            Literal::Integer(value) => integer_literal(*value),
            Literal::Real(value) => format!("{value:?}"),
            Literal::Boolean(value) => value.to_string(),
            Literal::Character(value) => format!("{value:?}"),
            Literal::String(text) => format!("{text:?}.to_string()"),
        }
    }

    pub(crate) fn enum_member(&self, enumeration: u32, ordinal: i64) -> String {
        let name = self.enum_name(enumeration);
        let member = usize::try_from(enumeration)
            .ok()
            .and_then(|index| self.view.module.enums.get(index))
            .and_then(|entry| {
                usize::try_from(ordinal)
                    .ok()
                    .and_then(|position| entry.members.get(position))
                    .map(|member| {
                        crate::identifier_spelling::unique_spelling(
                            crate::identifier_spelling::rust_type_name,
                            entry.members.iter().cloned(),
                            member,
                        )
                    })
            })
            .unwrap_or_else(|| format!("Member{ordinal}"));
        format!("{name}::{member}")
    }

    pub(crate) fn literal_text(&self, identifier: ExpressionId) -> Option<String> {
        if matches!(self.view.expression_type(identifier), Type::Enum(_)) {
            return None;
        }
        match self.view.expression(identifier) {
            HirExpression::Literal(Literal::String(text)) => Some(text.clone()),
            HirExpression::Literal(Literal::Character(value)) => Some(value.to_string()),
            HirExpression::Literal(Literal::Integer(value)) => Some(value.to_string()),
            HirExpression::Literal(Literal::Boolean(value)) => {
                Some(self.boolean_word(*value).to_owned())
            }
            _ => None,
        }
    }

    pub(crate) fn boolean_word(&self, value: bool) -> &'static str {
        if value {
            self.request.truth
        } else {
            self.request.falsity
        }
    }

    pub(crate) fn displayed(&mut self, identifier: ExpressionId) -> String {
        match self.view.expression_type(identifier) {
            Type::Real => {
                let helper = self.require("real_text");
                format!("{helper}({})", self.expression(identifier))
            }
            Type::Boolean => {
                let helper = self.require("boolean_text");
                format!("{helper}({})", self.expression(identifier))
            }
            Type::Object(class) if self.view.module.collections.contains_key(&class) => {
                let helper = self.require("collection_text");
                format!("{helper}(&*{}.borrow())", self.expression(identifier))
            }
            _ => self.expression(identifier),
        }
    }
}

pub(crate) fn integer_literal(value: i64) -> String {
    if value == i64::MIN {
        "i64::MIN".to_owned()
    } else if i32::try_from(value).is_ok() {
        value.to_string()
    } else {
        format!("{value}_i64")
    }
}
