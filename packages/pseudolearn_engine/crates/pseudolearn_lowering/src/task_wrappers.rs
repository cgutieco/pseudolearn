use crate::builder::FunctionBuilder;
use pseudolearn_ir::{Function, IrType, Operand, Operation, ValueId};
use pseudolearn_semantic::{HirExpression, HirModule, Type};
use std::collections::BTreeSet;

pub(crate) fn append(module: &HirModule, functions: &mut Vec<Function>) {
    let targets = module
        .expressions
        .kinds
        .iter()
        .filter_map(|expression| match expression {
            HirExpression::TaskSpawn { function, .. } => usize::try_from(function.0).ok(),
            _ => None,
        })
        .collect::<BTreeSet<_>>();
    for target in targets {
        if let (Some(function), Some(source)) =
            (functions.get(target), module.functions.get(target))
        {
            let wrapped = wrap(module, source.result, function);
            functions.push(wrapped);
        }
    }
}

pub(crate) fn name(original: &str) -> String {
    format!("@task:{}", original.trim_start_matches('@'))
}

fn wrap(
    module: &HirModule,
    result: pseudolearn_semantic::identities::TypeId,
    original: &Function,
) -> Function {
    let mut builder = FunctionBuilder::new(name(&original.name), IrType::Unit);
    builder.generated_span = original.declaration_span;
    let entry = builder.create_block();
    builder.set_current_block(entry);
    let width = crate::records::record_width(result, module).unwrap_or(0);
    let (arguments, cells) = arguments(original, width, &mut builder);
    let value = builder.next_value();
    let target = Operand::FunctionTarget {
        function_name: original.name.clone(),
        arguments,
    };
    builder.emit_with_target(Operation::Call, vec![target], (Some(value), None));
    let values = result_values(&cells, value, original, &mut builder);
    finish_result(module, result, &values, &mut builder);
    Function {
        name: builder.name,
        parameters: builder.parameters,
        return_type: IrType::Unit,
        blocks: builder.blocks,
        columns: builder.columns,
        declaration_span: original.declaration_span,
    }
}

fn result_values(
    cells: &[ValueId],
    scalar: ValueId,
    original: &Function,
    builder: &mut FunctionBuilder,
) -> Vec<ValueId> {
    if cells.is_empty() {
        return if original.return_type == IrType::Unit {
            Vec::new()
        } else {
            vec![scalar]
        };
    }
    cells
        .iter()
        .map(|cell| {
            let value = builder.next_value();
            builder.emit_with_target(
                Operation::CellLoadRaw,
                vec![Operand::Value(*cell)],
                (Some(value), None),
            );
            value
        })
        .collect()
}

fn finish_result(
    module: &HirModule,
    result: pseudolearn_semantic::identities::TypeId,
    values: &[ValueId],
    builder: &mut FunctionBuilder,
) {
    let variant = match module.types.get(result) {
        Type::Record(record) => module.variants.get(&record),
        _ => None,
    };
    let Some(variant) = variant.filter(|variant| {
        variant.family == pseudolearn_semantic::variant_model::VariantFamily::Result
    }) else {
        outcome("success", values, builder);
        return;
    };
    let successful = success_condition(values, builder);
    let success = builder.create_block();
    let failure = builder.create_block();
    builder.emit_void(
        Operation::Branch,
        vec![Operand::Value(successful), target(success), target(failure)],
        None,
    );
    for (index, block, status) in [(0, success, "success"), (1, failure, "error")] {
        builder.set_current_block(block);
        let payload = variant
            .offsets
            .get(index)
            .into_iter()
            .flatten()
            .filter_map(|offset| values.get(usize::try_from(*offset).ok()?).copied())
            .collect::<Vec<_>>();
        outcome(status, &payload, builder);
    }
}

fn outcome(status: &str, values: &[ValueId], builder: &mut FunctionBuilder) {
    let mut operands = vec![Operand::Identifier(status.to_owned())];
    operands.extend(values.iter().copied().map(Operand::Value));
    builder.emit_void(Operation::TaskOutcome, operands, None);
    builder.emit_void(Operation::Return, Vec::new(), None);
}

fn target(block: pseudolearn_ir::BlockId) -> Operand {
    Operand::BlockTarget {
        target_block: block,
        arguments: Vec::new(),
    }
}

fn arguments(
    original: &Function,
    width: usize,
    builder: &mut FunctionBuilder,
) -> (Vec<ValueId>, Vec<ValueId>) {
    let mut arguments = Vec::new();
    let mut cells = Vec::new();
    for (_, kind) in original
        .parameters
        .iter()
        .take(original.parameters.len().saturating_sub(width))
    {
        let value = builder.next_value();
        builder.parameters.push((value, kind.clone()));
        arguments.push(value);
    }
    for (_, kind) in original
        .parameters
        .iter()
        .skip(original.parameters.len().saturating_sub(width))
    {
        let IrType::Cell(kind) = kind else { continue };
        let value = builder.next_value();
        builder.emit_with_target(
            Operation::CellLocal,
            vec![Operand::Type(*kind.clone())],
            (Some(value), None),
        );
        cells.push(value);
        arguments.push(value);
    }
    (arguments, cells)
}

fn success_condition(values: &[ValueId], builder: &mut FunctionBuilder) -> ValueId {
    let zero = builder.next_value();
    builder.emit_with_target(
        Operation::ConstI64,
        vec![Operand::LiteralI64(0)],
        (Some(zero), None),
    );
    let successful = builder.next_value();
    builder.emit_with_target(
        Operation::IntCmp,
        vec![
            Operand::Predicate(pseudolearn_ir::PredicateKind::Equal),
            Operand::Value(values.first().copied().unwrap_or(zero)),
            Operand::Value(zero),
        ],
        (Some(successful), None),
    );
    successful
}
