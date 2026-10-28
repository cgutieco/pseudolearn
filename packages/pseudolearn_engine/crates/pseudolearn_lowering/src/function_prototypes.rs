use pseudolearn_ir::{Block, BlockId, Function, IrType, Operation, ValueId};
use pseudolearn_semantic::identities::TypeId;
use pseudolearn_semantic::{HirModule, Passing, Type};

pub(crate) fn append(module: &HirModule, functions: &mut Vec<Function>) {
    for (record, signature) in &module.function_types {
        functions.push(prototype(module, *record, signature));
    }
}

fn prototype(
    module: &HirModule,
    record: pseudolearn_semantic::identities::RecordId,
    signature: &pseudolearn_semantic::function_model::FunctionSignature,
) -> Function {
    let (parameters, result) = signature_types(module, signature);
    let mut function = Function::new(name(record.0), result);
    function.parameters = parameters
        .into_iter()
        .enumerate()
        .filter_map(|(index, kind)| Some((ValueId(u32::try_from(index).ok()?), kind)))
        .collect();
    let instruction = function.columns.push_instruction(
        pseudolearn_ir::InstructionDefinition {
            operation: Operation::Unreachable,
            result: None,
            span: None,
        },
        &[],
    );
    function.blocks.push(Block {
        identifier: BlockId(0),
        parameters: Vec::new(),
        mass: 0,
        instructions: vec![instruction],
    });
    function
}

fn signature_types(
    module: &HirModule,
    signature: &pseudolearn_semantic::function_model::FunctionSignature,
) -> (Vec<IrType>, IrType) {
    let mut parameters = vec![IrType::Str];
    for (kind, passing) in &signature.parameters {
        if *passing == Passing::Reference {
            parameters.push(IrType::Cell(Box::new(crate::types::lower_type(
                *kind, module,
            ))));
        } else {
            parameters.extend(leaves(*kind, module));
        }
    }
    let result = if crate::records::record_width(signature.result, module).is_some() {
        parameters.extend(
            leaves(signature.result, module)
                .into_iter()
                .map(|kind| IrType::Cell(Box::new(kind))),
        );
        IrType::Unit
    } else {
        crate::types::lower_type(signature.result, module)
    };
    (parameters, result)
}

fn leaves(kind: TypeId, module: &HirModule) -> Vec<IrType> {
    if let Type::Record(record) = module.types.representation(kind) {
        return usize::try_from(record.0)
            .ok()
            .and_then(|index| module.records.get(index))
            .map(|record| {
                record
                    .leaf_types
                    .iter()
                    .map(|kind| crate::types::lower_type(*kind, module))
                    .collect()
            })
            .unwrap_or_default();
    }
    vec![crate::types::lower_type(kind, module)]
}

pub(crate) fn name(record: u32) -> String {
    format!("@__signature{record}")
}
