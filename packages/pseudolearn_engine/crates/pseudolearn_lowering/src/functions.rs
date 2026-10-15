#![forbid(unsafe_code)]

use crate::builder::{FunctionBuilder, is_current_block_terminated};
use crate::environment::VariableEnvironment;
use crate::expressions::ExpressionContext;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements::lower_statement_list;
use crate::types::lower_type;
use pseudolearn_ir::{Function, IrType, Operation, OriginEntry, VariableId};
use pseudolearn_semantic::hir::{FunctionKind, HirFunction, HirModule, Passing};
use pseudolearn_semantic::identities::LocalId;
use pseudolearn_source::SourceText;

pub fn lower_function(
    function: &HirFunction,
    module: &HirModule,
    source: &SourceText,
    origins: &mut Vec<OriginEntry>,
) -> Function {
    let return_type = lower_type(function.result, module);
    let resolved_name = resolve_function_name(function);
    let mut builder = FunctionBuilder::new(resolved_name, return_type.clone());
    let mut environment = VariableEnvironment::new();
    let entry_block = builder.create_block();
    builder.set_current_block(entry_block);

    let expression_context = ExpressionContext { module, source };
    let mut statement_context = StatementContext {
        expression_context: &expression_context,
        environment: &mut environment,
        builder: &mut builder,
        origins,
    };
    initialize_parameters(&function.parameters, &mut statement_context);
    lower_statement_list(&function.body, &mut statement_context);

    terminate_function_blocks(&mut builder, &return_type, function, source);
    compute_blocks_mass(&mut builder);

    Function {
        name: builder.name,
        parameters: builder.parameters,
        return_type: builder.return_type,
        columns: builder.columns,
        blocks: builder.blocks,
    }
}

fn resolve_function_name(function: &HirFunction) -> String {
    if function.kind == FunctionKind::Main {
        "@main".to_owned()
    } else if function.name.starts_with('@') {
        function.name.clone()
    } else {
        format!("@{}", function.name)
    }
}

fn initialize_parameters(parameters: &[LocalId], context: &mut StatementContext<'_, '_>) {
    for &local_id in parameters {
        initialize_single_parameter(local_id, context);
    }
}

fn initialize_single_parameter(local_id: LocalId, context: &mut StatementContext<'_, '_>) {
    let parameter_value = context.builder.next_value();
    let local_option = usize::try_from(local_id.0)
        .ok()
        .and_then(|local_index| context.expression_context.module.locals.get(local_index));
    let is_reference = local_option.is_some_and(|local| local.passing == Passing::Reference);
    let raw_type = local_option
        .map(|local| lower_type(local.type_id, context.expression_context.module))
        .unwrap_or(IrType::I64);

    if is_reference {
        let cell_type = IrType::Cell(Box::new(raw_type));
        context
            .builder
            .parameters
            .push((parameter_value, cell_type));
        context.environment.bind_cell(local_id, parameter_value);
    } else {
        context.builder.parameters.push((parameter_value, raw_type));
        context.environment.bind_value(local_id, parameter_value);
        context.environment.mark_assigned(local_id);
    }

    let parameter_name = local_option
        .map(|local| local.name.clone())
        .unwrap_or_else(|| format!("v{}", local_id.0));
    context.origins.push(OriginEntry {
        value: parameter_value,
        variable: VariableId(local_id.0),
        name: parameter_name,
    });
}

fn terminate_function_blocks(
    builder: &mut FunctionBuilder,
    return_type: &IrType,
    function: &HirFunction,
    source: &SourceText,
) {
    if !is_current_block_terminated(builder) {
        let closing_span = resolve_span(function.closing_span, source);
        if return_type == &IrType::Unit {
            builder.emit_void(Operation::Return, vec![], closing_span);
        } else {
            builder.emit_void(Operation::TrapMissingReturn, vec![], closing_span);
        }
    }
}

fn compute_blocks_mass(builder: &mut FunctionBuilder) {
    for block in &mut builder.blocks {
        let mut enter_count = 0u32;
        for &instruction_id in &block.instructions {
            if builder.columns.operation(instruction_id) == Some(Operation::StmtEnter) {
                enter_count = enter_count.saturating_add(1);
            }
        }
        block.mass = enter_count;
    }
}
