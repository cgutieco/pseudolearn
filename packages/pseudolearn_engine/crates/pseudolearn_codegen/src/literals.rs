use crate::error::CodegenError;
use cranelift_module::{DataDescription, DataId, Linkage, Module as ClifModule};
use cranelift_object::ObjectModule;
use pseudolearn_ir::{Module, Operand, Operation};
use std::collections::BTreeSet;

pub(crate) fn define_literals(
    object: &mut ObjectModule,
    module: &Module,
) -> Result<Vec<(String, DataId)>, CodegenError> {
    let mut contents = BTreeSet::new();
    for function in &module.functions {
        for block in &function.blocks {
            for instruction in &block.instructions {
                collect_literal(function, *instruction, &mut contents);
            }
        }
    }
    let mut defined = Vec::new();
    for (position, content) in contents.into_iter().enumerate() {
        let name = format!("__pl_str_{position}");
        let storage = object
            .declare_data(&name, Linkage::Local, false, false)
            .map_err(CodegenError::backend)?;
        let mut description = DataDescription::new();
        let mut bytes = content.as_bytes().to_vec();
        bytes.push(0);
        description.define(bytes.into_boxed_slice());
        object
            .define_data(storage, &description)
            .map_err(CodegenError::backend)?;
        defined.push((content, storage));
    }
    Ok(defined)
}

fn collect_literal(
    function: &pseudolearn_ir::Function,
    instruction: pseudolearn_ir::InstructionId,
    contents: &mut BTreeSet<String>,
) {
    if function.columns.operation(instruction) != Some(Operation::ConstStr) {
        return;
    }
    if let Some(Operand::LiteralStr(content)) = function.columns.operands(instruction).first() {
        contents.insert(content.clone());
    }
}
