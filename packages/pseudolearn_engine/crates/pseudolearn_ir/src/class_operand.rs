use crate::operand::Operand;
use crate::operation::Operation;

pub(crate) fn print(buffer: &mut String, operation: Operation, operand: &Operand) -> bool {
    match (operation, operand) {
        (Operation::ObjectNew, Operand::Identifier(class_name)) if !is_word(class_name) => {
            buffer.push_str(&crate::identifier_text::canonical(class_name));
            true
        }
        _ => false,
    }
}

pub(crate) fn restore(operation: Operation, operands: Vec<Operand>) -> Vec<Operand> {
    if operation != Operation::ObjectNew {
        return operands;
    }
    operands
        .into_iter()
        .map(|operand| match operand {
            Operand::LiteralStr(class_name) => Operand::Identifier(class_name),
            other => other,
        })
        .collect()
}

fn is_word(name: &str) -> bool {
    !name.is_empty()
        && name
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'.' | b'_' | b'$'))
}
