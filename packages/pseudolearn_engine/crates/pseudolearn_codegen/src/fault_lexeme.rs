use crate::lowering::Lowering;
use pseudolearn_ir::{Function, IrSpan, Module, Operand, Operation};
use std::collections::HashMap;

type SpanKey = (u32, u32, u32, u32);
pub(crate) type Lexemes = HashMap<SpanKey, String>;

fn key(span: IrSpan) -> SpanKey {
    (
        span.start_line,
        span.start_column,
        span.end_line,
        span.end_column,
    )
}

pub(crate) fn collect(function: &Function, module: &Module) -> Lexemes {
    let mut origins: HashMap<_, _> = module
        .origins
        .entries
        .iter()
        .filter(|origin| origin.function == function.name)
        .map(|origin| (origin.value, origin.name.clone()))
        .collect();
    let mut lexemes = HashMap::new();
    let columns = &function.columns;
    for instruction in function.blocks.iter().flat_map(|block| &block.instructions) {
        if !carries_lexeme(columns.operation(*instruction)) {
            continue;
        }
        let name = instruction_lexeme(&origins, columns.operands(*instruction)).or_else(|| {
            columns
                .result(*instruction)
                .and_then(|result| origins.get(&result).cloned())
        });
        if let Some(name) = name.as_ref()
            && let Some(result) = columns.result(*instruction)
        {
            origins.entry(result).or_insert_with(|| name.clone());
        }
        if let Some(span) = columns.span(*instruction)
            && let Some(name) = name
        {
            lexemes.entry(key(span)).or_insert(name);
        }
    }
    lexemes
}

pub(crate) fn resolve(lowering: &Lowering<'_, '_>, code: &str, span: Option<IrSpan>) -> String {
    if code == "subroutineEndedWithoutReturn" {
        return lowering
            .function
            .name
            .trim_start_matches('@')
            .rsplit('.')
            .next()
            .unwrap_or("")
            .to_owned();
    }
    span.and_then(|span| lowering.fault_lexemes.get(&key(span)))
        .cloned()
        .unwrap_or_default()
}

fn instruction_lexeme(
    origins: &HashMap<pseudolearn_ir::ValueId, String>,
    operands: &[Operand],
) -> Option<String> {
    if let Some(Operand::Identifier(name)) = operands.get(1) {
        return Some(name.clone());
    }
    let Some(Operand::Value(value)) = operands.first() else {
        return None;
    };
    origins.get(value).cloned()
}

fn carries_lexeme(operation: Option<Operation>) -> bool {
    matches!(
        operation,
        Some(
            Operation::ValueRequire
                | Operation::CellLoad
                | Operation::ObjectLoad
                | Operation::ArrayLoad
                | Operation::CellLocal
                | Operation::CellElement
                | Operation::CellField
        )
    )
}
