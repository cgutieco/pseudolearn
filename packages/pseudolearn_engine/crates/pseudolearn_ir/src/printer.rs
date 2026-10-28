#![forbid(unsafe_code)]

use crate::columns::InstructionColumns;
use crate::identities::{BlockId, InstructionId, ValueId};
use crate::model::{Block, ClassDeclaration, Function, Module};
use crate::operand::Operand;
use std::collections::HashMap;

pub fn print_canonical(module: &Module) -> String {
    let mut buffer = String::new();
    buffer.push_str("module ");
    buffer.push_str(&module.name);
    buffer.push(' ');
    buffer.push_str(&module.vocabulary);
    buffer.push('\n');
    print_profiles(&mut buffer, module);

    for class_declaration in &module.classes {
        print_class(&mut buffer, class_declaration);
    }
    for function in &module.functions {
        print_function(&mut buffer, function);
    }
    buffer
}

fn print_profiles(buffer: &mut String, module: &Module) {
    let mut profiles: Vec<_> = module.profiles.iter().collect();
    profiles.sort_by_key(|profile| profile.source_id);
    for profile in profiles {
        buffer.push_str(&format!(
            "profile {} {}\n",
            profile.source_id.value(),
            profile.vocabulary
        ));
    }
}

fn print_class(buffer: &mut String, class_declaration: &ClassDeclaration) {
    buffer.push_str("class ");
    buffer.push_str(&crate::identifier_text::canonical(&class_declaration.name));
    if let Some(superclass) = &class_declaration.superclass {
        buffer.push_str(" : ");
        buffer.push_str(&crate::identifier_text::canonical(superclass));
    }
    buffer.push_str(" {");
    if !class_declaration.fields.is_empty() {
        buffer.push(' ');
        for (index, field) in class_declaration.fields.iter().enumerate() {
            if index > 0 {
                buffer.push_str(", ");
            }
            buffer.push_str(&crate::identifier_text::canonical(&field.name));
            buffer.push_str(": ");
            buffer.push_str(&field.field_type.to_string());
        }
        buffer.push(' ');
    }
    buffer.push_str("}\n");
}

struct PrintContext<'context> {
    columns: &'context InstructionColumns,
    block_map: &'context HashMap<BlockId, u32>,
    value_map: &'context HashMap<ValueId, u32>,
}

fn build_canonical_maps(function: &Function) -> (HashMap<BlockId, u32>, HashMap<ValueId, u32>) {
    let mut block_map = HashMap::new();
    let mut value_map = HashMap::new();
    let mut next_value_index = 0u32;

    for (index, block) in function.blocks.iter().enumerate() {
        let canonical_block = u32::try_from(index).unwrap_or(0);
        block_map.insert(block.identifier, canonical_block);
    }
    for (parameter_value, _) in &function.parameters {
        value_map.insert(*parameter_value, next_value_index);
        next_value_index = next_value_index.saturating_add(1);
    }
    for block in &function.blocks {
        for (parameter_value, _) in &block.parameters {
            value_map.insert(*parameter_value, next_value_index);
            next_value_index = next_value_index.saturating_add(1);
        }
        for instruction_identifier in &block.instructions {
            if let Some(result) = function.columns.result(*instruction_identifier) {
                value_map.insert(result, next_value_index);
                next_value_index = next_value_index.saturating_add(1);
            }
        }
    }
    (block_map, value_map)
}

fn print_function(buffer: &mut String, function: &Function) {
    let (block_map, value_map) = build_canonical_maps(function);
    let context = PrintContext {
        columns: &function.columns,
        block_map: &block_map,
        value_map: &value_map,
    };
    buffer.push_str(if function.suspendible {
        "func suspendible "
    } else {
        "func "
    });
    if !function.name.starts_with('@') {
        buffer.push('@');
    }
    buffer.push_str(&function.name);
    buffer.push('(');
    for (index, (parameter_value, parameter_type)) in function.parameters.iter().enumerate() {
        if index > 0 {
            buffer.push_str(", ");
        }
        let canonical_value = value_map
            .get(parameter_value)
            .copied()
            .unwrap_or(parameter_value.0);
        buffer.push('%');
        buffer.push_str(&canonical_value.to_string());
        buffer.push_str(": ");
        buffer.push_str(&parameter_type.to_string());
    }
    buffer.push_str(") -> ");
    buffer.push_str(&function.return_type.to_string());
    buffer.push_str(" {\n");

    for block in &function.blocks {
        print_block(buffer, block, &context);
    }
    buffer.push_str("}\n");
}

fn print_block(buffer: &mut String, block: &Block, context: &PrintContext<'_>) {
    let canonical_block_index = context
        .block_map
        .get(&block.identifier)
        .copied()
        .unwrap_or(block.identifier.0);
    buffer.push('b');
    buffer.push_str(&canonical_block_index.to_string());
    buffer.push('(');
    for (index, (parameter_value, parameter_type)) in block.parameters.iter().enumerate() {
        if index > 0 {
            buffer.push_str(", ");
        }
        let canonical_value = context
            .value_map
            .get(parameter_value)
            .copied()
            .unwrap_or(parameter_value.0);
        buffer.push('%');
        buffer.push_str(&canonical_value.to_string());
        buffer.push_str(": ");
        buffer.push_str(&parameter_type.to_string());
    }
    buffer.push_str(") mass ");
    buffer.push_str(&block.mass.to_string());
    buffer.push_str(":\n");

    for instruction_identifier in &block.instructions {
        print_instruction(buffer, *instruction_identifier, context);
    }
}

fn print_instruction(
    buffer: &mut String,
    instruction_identifier: InstructionId,
    context: &PrintContext<'_>,
) {
    buffer.push_str("  ");
    if let Some(result) = context.columns.result(instruction_identifier) {
        let canonical_value = context.value_map.get(&result).copied().unwrap_or(result.0);
        buffer.push('%');
        buffer.push_str(&canonical_value.to_string());
        buffer.push_str(" = ");
    }
    let Some(operation) = context.columns.operation(instruction_identifier) else {
        return;
    };
    buffer.push_str(operation.as_str());

    let instruction_operands = context.columns.operands(instruction_identifier);
    if !instruction_operands.is_empty() {
        buffer.push(' ');
        for (index, operand) in instruction_operands.iter().enumerate() {
            if index > 0 {
                buffer.push_str(", ");
            }
            print_operand(buffer, operand, context);
        }
    }
    if let Some(span) = context.columns.span(instruction_identifier) {
        buffer.push(' ');
        buffer.push_str(&span.to_string());
    }
    buffer.push('\n');
}

fn print_operand(buffer: &mut String, operand: &Operand, context: &PrintContext<'_>) {
    match operand {
        Operand::Value(value) => {
            let canonical = context.value_map.get(value).copied().unwrap_or(value.0);
            buffer.push('%');
            buffer.push_str(&canonical.to_string());
        }
        Operand::BlockTarget {
            target_block,
            arguments,
        } => {
            let canonical = context
                .block_map
                .get(target_block)
                .copied()
                .unwrap_or(target_block.0);
            buffer.push('b');
            buffer.push_str(&canonical.to_string());
            print_value_arguments(buffer, arguments, context);
        }
        Operand::FunctionTarget {
            function_name,
            arguments,
        } => {
            if !function_name.starts_with('@') {
                buffer.push('@');
            }
            buffer.push_str(function_name);
            print_value_arguments(buffer, arguments, context);
        }
        _ => print_literal_operand(buffer, operand),
    }
}

fn print_value_arguments(buffer: &mut String, arguments: &[ValueId], context: &PrintContext<'_>) {
    buffer.push('(');
    for (index, argument) in arguments.iter().enumerate() {
        if index > 0 {
            buffer.push_str(", ");
        }
        let canonical_arg = context
            .value_map
            .get(argument)
            .copied()
            .unwrap_or(argument.0);
        buffer.push('%');
        buffer.push_str(&canonical_arg.to_string());
    }
    buffer.push(')');
}

fn print_literal_operand(buffer: &mut String, operand: &Operand) {
    match operand {
        Operand::LiteralI64(number) => buffer.push_str(&number.to_string()),
        Operand::LiteralF64(number) => buffer.push_str(&format_f64_literal(*number)),
        Operand::LiteralBool(flag) => buffer.push_str(if *flag { "true" } else { "false" }),
        Operand::LiteralChar(character) => {
            buffer.push('\'');
            buffer.push(*character);
            buffer.push('\'');
        }
        Operand::LiteralStr(content) => buffer.push_str(&escape_string(content)),
        Operand::Type(ir_type) => buffer.push_str(&ir_type.to_string()),
        Operand::Predicate(predicate) => buffer.push_str(predicate.as_str()),
        Operand::Identifier(identifier) => buffer.push_str(identifier),
        Operand::Newline => buffer.push_str("newline"),
        _ => {}
    }
}

fn format_f64_literal(value: f64) -> String {
    let rendered = format!("{value}");
    if rendered.contains('.') || rendered.contains('e') || rendered.contains('E') {
        rendered
    } else {
        format!("{rendered}.0")
    }
}

fn escape_string(content: &str) -> String {
    let mut escaped = String::with_capacity(content.len().saturating_add(2));
    escaped.push('"');
    for character in content.chars() {
        match character {
            '\n' => escaped.push_str("\\n"),
            '\t' => escaped.push_str("\\t"),
            '\r' => escaped.push_str("\\r"),
            '\\' => escaped.push_str("\\\\"),
            '"' => escaped.push_str("\\\""),
            other => escaped.push(other),
        }
    }
    escaped.push('"');
    escaped
}
