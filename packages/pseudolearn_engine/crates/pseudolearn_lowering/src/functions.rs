#![forbid(unsafe_code)]

use crate::builder::{FunctionBuilder, is_current_block_terminated};
use crate::environment::VariableEnvironment;
use crate::expressions::ExpressionContext;
use crate::spans::resolve_span;
use crate::statement_context::StatementContext;
use crate::statements::lower_statement_list;
use crate::types::lower_type;
use pseudolearn_ir::{Function, IrType, Operation, OriginEntry, VariableId};
use pseudolearn_semantic::hir::{FunctionKind, HirFunction, HirModule};
use pseudolearn_semantic::identities::LocalId;
use pseudolearn_source::SourceText;

pub fn lower_function(
    function: &HirFunction,
    module: &HirModule,
    source: &SourceText,
    origins: &mut Vec<OriginEntry>,
) -> Function {
    let return_type = lower_type(function.result, module);
    let resolved_name = function_name(function, module);
    let mut builder = FunctionBuilder::new(resolved_name, return_type.clone());
    let mut environment = VariableEnvironment::new();
    let entry_block = builder.create_block();
    builder.set_current_block(entry_block);
    initialize_receiver(function, module, &mut builder);
    record_receiver(&builder, origins);

    let expression_context = ExpressionContext { module, source };
    let mut statement_context = StatementContext {
        expression_context: &expression_context,
        environment: &mut environment,
        builder: &mut builder,
        origins,
    };
    initialize_parameters(&function.parameters, &mut statement_context);
    initialize_result_cells(function, &mut statement_context);
    crate::constructor_flow::implicit_super(function, &mut statement_context);
    lower_statement_list(&function.body, &mut statement_context);
    origins.append(&mut builder.cleanup.origins);

    terminate_function_blocks(&mut builder, &return_type, function, source);
    compute_blocks_mass(&mut builder);

    Function {
        declaration_span: crate::spans::header_span(function.span, source),
        name: builder.name,
        parameters: builder.parameters,
        return_type: builder.return_type,
        columns: builder.columns,
        blocks: builder.blocks,
    }
}

pub(crate) fn function_name(function: &HirFunction, module: &HirModule) -> String {
    if let Some(owner) = function.owner
        && let Some(class) = usize::try_from(owner.0)
            .ok()
            .and_then(|index| module.classes.get(index))
    {
        return format!("@{}.{}", class.name, function.name);
    }
    if function.kind == FunctionKind::Main {
        main_name(function, module)
    } else if function.name.starts_with('@') {
        function.name.clone()
    } else {
        format!("@{}", function.name)
    }
}

fn main_name(function: &HirFunction, module: &HirModule) -> String {
    let position = module
        .functions
        .iter()
        .position(|candidate| std::ptr::eq(candidate, function));
    let selected = match module.units.entry {
        None => true,
        Some(entry) => position.and_then(|index| u32::try_from(index).ok()) == Some(entry.0),
    };
    if selected {
        return "@main".to_owned();
    }
    let unit = position
        .and_then(|index| u32::try_from(index).ok())
        .map_or(0, |index| {
            module
                .units
                .function_unit(pseudolearn_semantic::identities::FunctionId(index))
        });
    let qualifier = module.units.qualifiers.get(unit).map_or("", String::as_str);
    format!("@{qualifier}.main")
}

fn initialize_receiver(function: &HirFunction, module: &HirModule, builder: &mut FunctionBuilder) {
    if let Some(owner) = function.owner
        && let Some(class) = usize::try_from(owner.0)
            .ok()
            .and_then(|index| module.classes.get(index))
    {
        let receiver = builder.next_value();
        builder
            .parameters
            .push((receiver, IrType::Object(class.name.clone())));
        builder.receiver = Some(receiver);
    }
}

fn initialize_parameters(parameters: &[LocalId], context: &mut StatementContext<'_, '_>) {
    for &local_id in parameters {
        for target in crate::records::targets(local_id, context.expression_context.module) {
            initialize_single_parameter(target, context);
        }
    }
}

fn initialize_result_cells(function: &HirFunction, context: &mut StatementContext<'_, '_>) {
    let module = context.expression_context.module;
    let leaves = match module.types.get(function.result) {
        pseudolearn_semantic::types::Type::Record(record) => usize::try_from(record.0)
            .ok()
            .and_then(|slot| module.records.get(slot))
            .map(|model| model.leaf_types.clone())
            .unwrap_or_default(),
        _ => Vec::new(),
    };
    for leaf in leaves {
        let cell = context.builder.next_value();
        let cell_type = IrType::Cell(Box::new(lower_type(leaf, module)));
        context.builder.parameters.push((cell, cell_type));
        context.builder.result_cells.push(cell);
    }
}

fn initialize_single_parameter(local_id: LocalId, context: &mut StatementContext<'_, '_>) {
    let parameter_value = context.builder.next_value();
    let local_option = usize::try_from(local_id.0)
        .ok()
        .and_then(|local_index| context.expression_context.module.locals.get(local_index));
    let is_reference = local_option.is_some_and(|local| {
        crate::parameter_passing::requires_cell(local, context.expression_context.module)
    });
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
    let origin_value = promote_parameter(local_id, (parameter_value, is_reference), context);
    context.origins.push(OriginEntry {
        visibility: None,
        function: context.builder.name.clone(),
        value: origin_value,
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
        if return_type == &IrType::Unit && builder.result_cells.is_empty() {
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

fn record_receiver(builder: &FunctionBuilder, origins: &mut Vec<OriginEntry>) {
    if let Some(receiver) = builder.receiver {
        origins.push(OriginEntry {
            visibility: None,
            function: builder.name.clone(),
            value: receiver,
            variable: VariableId(u32::MAX),
            name: "receiver".to_owned(),
        });
    }
}

fn promote_parameter(
    local_id: LocalId,
    (parameter_value, is_reference): (pseudolearn_ir::ValueId, bool),
    context: &mut StatementContext<'_, '_>,
) -> pseudolearn_ir::ValueId {
    if !is_reference && crate::address_taken::contains(local_id, context.expression_context.module)
    {
        let cell = context.builder.next_value();
        let local_type = usize::try_from(local_id.0)
            .ok()
            .and_then(|index| context.expression_context.module.locals.get(index))
            .map(|local| lower_type(local.type_id, context.expression_context.module))
            .unwrap_or(IrType::Unit);
        context.builder.emit_with_target(
            pseudolearn_ir::Operation::CellLocal,
            vec![pseudolearn_ir::Operand::Type(local_type)],
            (Some(cell), None),
        );
        context.builder.emit_void(
            pseudolearn_ir::Operation::CellStore,
            vec![
                pseudolearn_ir::Operand::Value(cell),
                pseudolearn_ir::Operand::Value(parameter_value),
            ],
            None,
        );
        context.environment.bind_cell(local_id, cell);
        cell
    } else {
        parameter_value
    }
}
