use super::RustEmitter;
use super::rust_expressions::ATOM;
use pseudolearn_semantic::{
    BinaryOperator, ExpressionId, HirExpression, Literal, Type, UnaryOperator,
};

pub(crate) fn binary_precedence(operator: BinaryOperator) -> u8 {
    match operator {
        BinaryOperator::LogicalOr => 2,
        BinaryOperator::LogicalAnd => 3,
        BinaryOperator::Equal
        | BinaryOperator::NotEqual
        | BinaryOperator::Less
        | BinaryOperator::LessEqual
        | BinaryOperator::Greater
        | BinaryOperator::GreaterEqual => 4,
        BinaryOperator::Add | BinaryOperator::Subtract => 6,
        BinaryOperator::Multiply | BinaryOperator::IntegerDivide | BinaryOperator::Modulo => 7,
        BinaryOperator::Divide | BinaryOperator::Power => ATOM,
    }
}

fn symbol(operator: BinaryOperator) -> &'static str {
    match operator {
        BinaryOperator::Add => "+",
        BinaryOperator::Subtract => "-",
        BinaryOperator::Multiply => "*",
        BinaryOperator::Divide | BinaryOperator::IntegerDivide => "/",
        BinaryOperator::Modulo => "%",
        BinaryOperator::Equal => "==",
        BinaryOperator::NotEqual => "!=",
        BinaryOperator::Less => "<",
        BinaryOperator::LessEqual => "<=",
        BinaryOperator::Greater => ">",
        BinaryOperator::GreaterEqual => ">=",
        BinaryOperator::LogicalAnd => "&&",
        BinaryOperator::LogicalOr => "||",
        BinaryOperator::Power => "^",
    }
}

impl RustEmitter<'_, '_> {
    pub(crate) fn unary(&mut self, operator: UnaryOperator, operand: ExpressionId) -> String {
        match operator {
            UnaryOperator::Positive => self.expression(operand),
            UnaryOperator::Negative => format!("-{}", self.operand(operand, 9)),
            UnaryOperator::Not => format!("!{}", self.operand(operand, 9)),
        }
    }

    pub(crate) fn binary(
        &mut self,
        identifier: ExpressionId,
        operator: BinaryOperator,
        (left, right): (ExpressionId, ExpressionId),
    ) -> String {
        let result_type = self.view.expression_type(identifier);
        match operator {
            BinaryOperator::Add if matches!(result_type, Type::String) => {
                self.concatenation(identifier)
            }
            BinaryOperator::Divide => self.real_division(left, right),
            _ => self.binary_rest(identifier, operator, (left, right)),
        }
    }

    pub(crate) fn binary_rest(
        &mut self,
        identifier: ExpressionId,
        operator: BinaryOperator,
        (left, right): (ExpressionId, ExpressionId),
    ) -> String {
        let result_type = self.view.expression_type(identifier);
        let operand_type = self.view.expression_type(left);
        match operator {
            BinaryOperator::Power => self.power(left, right, &result_type),
            BinaryOperator::Equal | BinaryOperator::NotEqual
                if matches!(operand_type, Type::Object(_)) =>
            {
                self.uses.insert("rc");
                let equal = format!(
                    "Rc::ptr_eq(&{}, &{})",
                    self.expression(left),
                    self.expression(right)
                );
                if operator == BinaryOperator::Equal {
                    equal
                } else {
                    format!("!{equal}")
                }
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

    pub(crate) fn concatenation(&mut self, identifier: ExpressionId) -> String {
        let mut parts = Vec::new();
        self.concatenated_parts(identifier, &mut parts);
        let mut template = String::new();
        let mut arguments = Vec::new();
        for part in parts {
            match self.literal_text(part) {
                Some(text) => template.push_str(&text.replace('{', "{{").replace('}', "}}")),
                None => {
                    template.push_str("{}");
                    arguments.push(self.displayed(part));
                }
            }
        }
        let template = format!("{template:?}");
        if arguments.is_empty() {
            return format!("{template}.to_string()");
        }
        format!("format!({template}, {})", arguments.join(", "))
    }

    pub(crate) fn concatenated_parts(
        &self,
        identifier: ExpressionId,
        parts: &mut Vec<ExpressionId>,
    ) {
        match self.view.expression(identifier) {
            HirExpression::Binary {
                operator: BinaryOperator::Add,
                left,
                right,
                ..
            } if matches!(self.view.expression_type(identifier), Type::String) => {
                self.concatenated_parts(*left, parts);
                self.concatenated_parts(*right, parts);
            }
            HirExpression::Widen(inner)
                if matches!(self.view.expression_type(*inner), Type::Character) =>
            {
                parts.push(*inner);
            }
            _ => parts.push(identifier),
        }
    }

    pub(crate) fn real_division(&mut self, left: ExpressionId, right: ExpressionId) -> String {
        let nonzero_literal = matches!(
            self.view.expression(right),
            HirExpression::Literal(Literal::Real(value)) if *value != 0.0
        );
        if nonzero_literal {
            let left_text = self.operand(left, 7);
            let right_text = self.operand(right, 8);
            return format!("{left_text} / {right_text}");
        }
        let helper = self.require("divide");
        let left_text = self.expression(left);
        let right_text = self.expression(right);
        format!("{helper}({left_text}, {right_text})")
    }

    pub(crate) fn power(
        &mut self,
        left: ExpressionId,
        right: ExpressionId,
        result_type: &Type,
    ) -> String {
        let left_text = self.expression(left);
        let right_text = self.expression(right);
        if matches!(result_type, Type::Integer) {
            let helper = self.require("integer_power");
            format!("{helper}({left_text}, {right_text})")
        } else {
            let helper = self.require("real_power");
            format!("{helper}({left_text}, {right_text})")
        }
    }

    pub(crate) fn widen(&mut self, identifier: ExpressionId, inner: ExpressionId) -> String {
        let target = self.view.expression_type(identifier);
        let source = self.view.expression_type(inner);
        match (&source, &target) {
            (Type::Integer, Type::Real) => {
                if let HirExpression::Literal(Literal::Integer(value)) = self.view.expression(inner)
                {
                    return format!("{value}.0");
                }
                format!("{} as f64", self.operand(inner, 9))
            }
            (Type::Character, Type::String) => {
                if let HirExpression::Literal(Literal::Character(value)) =
                    self.view.expression(inner)
                {
                    return format!("{:?}.to_string()", value.to_string());
                }
                format!("{}.to_string()", self.operand(inner, ATOM))
            }
            _ => self.value(inner),
        }
    }
}
