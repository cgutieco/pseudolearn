use super::PythonEmitter;
use crate::identifier_spelling::{python_type_name, unique_spelling};
use pseudolearn_semantic::{
    BinaryOperator, ExpressionId, HirExpression, Literal, Type, UnaryOperator,
};

fn binary_precedence(operator: BinaryOperator) -> u8 {
    match operator {
        BinaryOperator::LogicalOr => 1,
        BinaryOperator::LogicalAnd => 2,
        BinaryOperator::Equal
        | BinaryOperator::NotEqual
        | BinaryOperator::Less
        | BinaryOperator::LessEqual
        | BinaryOperator::Greater
        | BinaryOperator::GreaterEqual => 4,
        BinaryOperator::Add | BinaryOperator::Subtract => 6,
        BinaryOperator::Multiply | BinaryOperator::Divide => 7,
        BinaryOperator::IntegerDivide | BinaryOperator::Modulo | BinaryOperator::Power => 10,
    }
}

fn symbol(operator: BinaryOperator) -> &'static str {
    match operator {
        BinaryOperator::Add => "+",
        BinaryOperator::Subtract => "-",
        BinaryOperator::Multiply => "*",
        BinaryOperator::Divide => "/",
        BinaryOperator::Equal => "==",
        BinaryOperator::NotEqual => "!=",
        BinaryOperator::Less => "<",
        BinaryOperator::LessEqual => "<=",
        BinaryOperator::Greater => ">",
        BinaryOperator::GreaterEqual => ">=",
        BinaryOperator::LogicalAnd => "and",
        BinaryOperator::LogicalOr => "or",
        BinaryOperator::IntegerDivide | BinaryOperator::Modulo | BinaryOperator::Power => "?",
    }
}

impl PythonEmitter<'_, '_> {
    pub(crate) fn expression(&mut self, identifier: ExpressionId) -> String {
        let span = self.view.expression_span(identifier);
        match self.view.expression(identifier) {
            HirExpression::Literal(literal) => self.literal(identifier, literal),
            HirExpression::Local(local) | HirExpression::Uninitialized(local) => {
                self.local_name(*local)
            }
            HirExpression::Unary {
                operator, operand, ..
            } => match operator {
                UnaryOperator::Positive => self.expression(*operand),
                UnaryOperator::Negative => format!("-{}", self.operand(*operand, 8)),
                UnaryOperator::Not => format!("not {}", self.operand(*operand, 3)),
            },
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
            HirExpression::Effect { .. } => self.effect(identifier, span),
            HirExpression::Invalid => self.block("invalid", span),
            _ => self.compound(identifier, span),
        }
    }

    pub(crate) fn value(&mut self, identifier: ExpressionId) -> String {
        let text = self.expression(identifier);
        let record = self
            .view
            .expression_type_id(identifier)
            .is_some_and(|type_id| self.is_record(type_id));
        let place = matches!(
            self.view.expression(identifier),
            HirExpression::Local(_)
                | HirExpression::Field { .. }
                | HirExpression::Element { .. }
                | HirExpression::RecordField { .. }
                | HirExpression::Captured { .. }
        );
        if record && place {
            format!("{text}.copy()")
        } else {
            text
        }
    }

    pub(crate) fn precedence(&self, identifier: ExpressionId) -> u8 {
        match self.view.expression(identifier) {
            HirExpression::Binary { operator, .. } => binary_precedence(*operator),
            HirExpression::Unary {
                operator: UnaryOperator::Not,
                ..
            } => 3,
            HirExpression::Unary { .. } => 8,
            HirExpression::Widen(inner)
                if !matches!(self.view.expression_type(*inner), Type::Integer) =>
            {
                self.precedence(*inner)
            }
            HirExpression::Literal(Literal::Integer(value)) if *value < 0 => 8,
            HirExpression::Literal(Literal::Real(value)) if value.is_sign_negative() => 8,
            HirExpression::Call { function, .. } if !self.write_backs(*function).is_empty() => 10,
            _ => 10,
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
        if let (Type::Enum(enumeration), Literal::Integer(ordinal)) =
            (self.view.expression_type(identifier), literal)
        {
            let member = usize::try_from(enumeration.0)
                .ok()
                .and_then(|index| self.view.module.enums.get(index))
                .and_then(|entry| {
                    usize::try_from(*ordinal)
                        .ok()
                        .and_then(|position| entry.members.get(position))
                        .map(|member| {
                            unique_spelling(python_type_name, entry.members.iter().cloned(), member)
                        })
                })
                .unwrap_or_default();
            return format!("{}.{member}", self.enum_name(enumeration.0));
        }
        match literal {
            Literal::Integer(value) => value.to_string(),
            Literal::Real(value) => format!("{value:?}"),
            Literal::Boolean(true) => "True".to_owned(),
            Literal::Boolean(false) => "False".to_owned(),
            Literal::Character(value) => python_string(&value.to_string()),
            Literal::String(text) => python_string(text),
        }
    }

    pub(crate) fn binary(
        &mut self,
        identifier: ExpressionId,
        operator: BinaryOperator,
        (left, right): (ExpressionId, ExpressionId),
    ) -> String {
        let result = self.view.expression_type(identifier);
        match operator {
            BinaryOperator::IntegerDivide => self.helper("int_divide", &[left, right]),
            BinaryOperator::Modulo => self.helper("int_modulo", &[left, right]),
            BinaryOperator::Power if matches!(result, Type::Integer) => {
                self.helper("int_power", &[left, right])
            }
            BinaryOperator::Power => self.helper("real_power", &[left, right]),
            BinaryOperator::Equal | BinaryOperator::NotEqual
                if matches!(self.view.expression_type(left), Type::Object(_)) =>
            {
                let keyword = if operator == BinaryOperator::Equal {
                    "is"
                } else {
                    "is not"
                };
                format!(
                    "{} {keyword} {}",
                    self.operand(left, 5),
                    self.operand(right, 5)
                )
            }
            _ => {
                let precedence = binary_precedence(operator);
                let comparison = precedence == 4;
                let left_minimum = if comparison { 5 } else { precedence };
                let left_text = self.operand(left, left_minimum);
                let right_text = self.operand(right, precedence.saturating_add(1));
                format!("{left_text} {} {right_text}", symbol(operator))
            }
        }
    }

    pub(crate) fn helper(&mut self, name: &'static str, arguments: &[ExpressionId]) -> String {
        self.require(name);
        let texts = arguments
            .iter()
            .map(|argument| self.expression(*argument))
            .collect::<Vec<_>>();
        format!("{name}({})", texts.join(", "))
    }

    pub(crate) fn widen(&mut self, identifier: ExpressionId, inner: ExpressionId) -> String {
        match (
            self.view.expression_type(inner),
            self.view.expression_type(identifier),
        ) {
            (Type::Integer, Type::Real) => {
                if let HirExpression::Literal(Literal::Integer(value)) = self.view.expression(inner)
                {
                    return format!("{value}.0");
                }
                format!("float({})", self.expression(inner))
            }
            _ => self.value(inner),
        }
    }

    pub(crate) fn displayed(&mut self, identifier: ExpressionId) -> String {
        match self.view.expression_type(identifier) {
            Type::Real => format!(
                "{}({})",
                self.require("real_text"),
                self.expression(identifier)
            ),
            Type::Boolean => format!(
                "{}({})",
                self.require("boolean_text"),
                self.expression(identifier)
            ),
            Type::Object(class) if self.view.module.collections.contains_key(&class) => {
                format!(
                    "{}({})",
                    self.require("collection_text"),
                    self.expression(identifier)
                )
            }
            _ => self.expression(identifier),
        }
    }
}

fn needs_escape(character: char) -> bool {
    character.is_control()
        || (character.is_whitespace() && character != ' ')
        || matches!(
            u32::from(character),
            0xAD | 0x61C | 0x180E | 0x200B..=0x200F | 0x202A..=0x202E | 0x2060..=0x206F
                | 0xFEFF | 0xFFF9..=0xFFFB | 0xE000..=0xF8FF | 0xE0000..=0xE007F
                | 0xF0000..=0x10FFFF
        )
}

fn numeric_escape(character: char) -> String {
    let code = u32::from(character);
    if code <= 0xFF {
        format!("\\x{code:02x}")
    } else if code <= 0xFFFF {
        format!("\\u{code:04x}")
    } else {
        format!("\\U{code:08x}")
    }
}

pub(crate) fn python_string(text: &str) -> String {
    let mut quoted = String::from("\"");
    for character in text.chars() {
        match character {
            '"' => quoted.push_str("\\\""),
            '\\' => quoted.push_str("\\\\"),
            '\n' => quoted.push_str("\\n"),
            '\r' => quoted.push_str("\\r"),
            '\t' => quoted.push_str("\\t"),
            other if needs_escape(other) => quoted.push_str(&numeric_escape(other)),
            other => quoted.push(other),
        }
    }
    quoted.push('"');
    quoted
}
