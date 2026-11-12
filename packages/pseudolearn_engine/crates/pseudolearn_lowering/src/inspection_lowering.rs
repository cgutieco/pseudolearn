use crate::expressions::{ExpressionContext, lower_expression};
use crate::{FunctionBuilder, LoweringError, VariableEnvironment};
use pseudolearn_ir::{Function, Module, Operand, Operation, OriginEntry, OriginTable, VariableId};
use pseudolearn_semantic::inspection_expression::InspectionExpression;
use pseudolearn_source::SourceText;

pub fn lower_inspection(
    inspection: &InspectionExpression,
    source: &SourceText,
) -> Result<Module, LoweringError> {
    let (mut builder, aggregate) = inspection_builder(inspection)?;
    let entry = builder.create_block();
    builder.set_current_block(entry);
    let mut environment = bind_parameters(inspection, &mut builder)?;
    let context = ExpressionContext {
        module: &inspection.module,
        source,
    };
    let origins = lower_result(
        inspection,
        (&context, &mut environment),
        &mut builder,
        aggregate,
    )?;
    Ok(Module {
        name: "inspection".to_owned(),
        vocabulary: "es".to_owned(),
        profiles: Vec::new(),
        classes: crate::classes::lower_classes(&inspection.module),
        functions: vec![finish(builder)],
        origins: OriginTable { entries: origins },
    })
}

fn inspection_builder(
    inspection: &InspectionExpression,
) -> Result<(FunctionBuilder, Option<usize>), LoweringError> {
    let index = usize::try_from(inspection.expression.0).map_err(|_| invalid())?;
    let type_id = inspection
        .module
        .expressions
        .types
        .get(index)
        .copied()
        .ok_or_else(invalid)?;
    let aggregate = crate::records::record_width(type_id, &inspection.module);
    let result = if aggregate.is_some() {
        pseudolearn_ir::IrType::Unit
    } else {
        crate::types::lower_type(type_id, &inspection.module)
    };
    Ok((FunctionBuilder::new("@main".to_owned(), result), aggregate))
}

fn lower_result(
    inspection: &InspectionExpression,
    context: (&ExpressionContext<'_>, &mut VariableEnvironment),
    builder: &mut FunctionBuilder,
    aggregate: Option<usize>,
) -> Result<Vec<OriginEntry>, LoweringError> {
    if let Some(width) = aggregate {
        return lower_aggregate(inspection, context, builder, width);
    }
    let value = lower_expression(inspection.expression, context.0, context.1, builder);
    builder.emit_void(Operation::Return, vec![Operand::Value(value)], None);
    Ok(Vec::new())
}

fn bind_parameters(
    inspection: &InspectionExpression,
    builder: &mut FunctionBuilder,
) -> Result<VariableEnvironment, LoweringError> {
    let mut environment = VariableEnvironment::new();
    for identity in &inspection.parameters {
        let index = usize::try_from(identity.0).map_err(|_| invalid())?;
        let local = inspection.module.locals.get(index).ok_or_else(invalid)?;
        let kind = crate::types::lower_type(local.type_id, &inspection.module);
        let value = builder.next_value();
        builder.parameters.push((value, kind));
        environment.bind_value(*identity, value);
        environment.mark_assigned(*identity);
    }
    Ok(environment)
}

fn finish(builder: FunctionBuilder) -> Function {
    Function {
        suspendible: false,
        declaration_span: None,
        name: builder.name,
        parameters: builder.parameters,
        return_type: builder.return_type,
        columns: builder.columns,
        blocks: builder.blocks,
    }
}

fn invalid() -> LoweringError {
    LoweringError {
        description: "invalid inspection expression".to_owned(),
    }
}

fn lower_aggregate(
    inspection: &InspectionExpression,
    context: (&ExpressionContext<'_>, &mut VariableEnvironment),
    builder: &mut FunctionBuilder,
    width: usize,
) -> Result<Vec<OriginEntry>, LoweringError> {
    let mut state = crate::expressions::ExpressionState {
        context: context.0,
        environment: context.1,
        builder,
    };
    let values = crate::record_values::lower_range(inspection.expression, (0, width), &mut state);
    if values.len() != width {
        return Err(invalid());
    }
    let span = usize::try_from(inspection.expression.0)
        .ok()
        .and_then(|slot| inspection.module.expressions.spans.get(slot).copied())
        .and_then(|raw| crate::spans::resolve_span(raw, state.context.source));
    if !values.is_empty() {
        state.builder.emit_void(
            Operation::OutWrite,
            values.iter().map(|value| Operand::Value(*value)).collect(),
            span,
        );
    }
    let origins = aggregate_origins(&values)?;
    state.builder.emit_void(Operation::Return, Vec::new(), None);
    Ok(origins)
}

fn aggregate_origins(
    values: &[pseudolearn_ir::ValueId],
) -> Result<Vec<OriginEntry>, LoweringError> {
    values
        .iter()
        .enumerate()
        .map(|(position, value)| {
            Ok(OriginEntry {
                visibility: None,
                function: "@main".to_owned(),
                value: *value,
                variable: VariableId(u32::try_from(position).map_err(|_| invalid())?),
                name: format!("inspection_result_{position}"),
            })
        })
        .collect()
}
