use crate::error::CodegenError;
use cranelift_codegen::ir::Endianness;
use cranelift_module::{DataDescription, DataId, FuncId, Linkage, Module as ClifModule};
use cranelift_object::ObjectModule;
use pseudolearn_ir::{IrType, Module, Operation};
use std::collections::{BTreeMap, BTreeSet};

type Signature = (Vec<IrType>, IrType);

pub(crate) fn tags(module: &Module) -> Vec<u32> {
    let keys: Vec<Signature> = module
        .functions
        .iter()
        .map(|function| {
            (
                function
                    .parameters
                    .iter()
                    .map(|(_, kind)| kind.clone())
                    .collect(),
                function.return_type.clone(),
            )
        })
        .collect();
    let unique: BTreeSet<_> = keys.iter().cloned().collect();
    let indices: BTreeMap<_, _> = unique
        .into_iter()
        .enumerate()
        .filter_map(|(index, key)| Some((key, u32::try_from(index).ok()?)))
        .collect();
    keys.iter()
        .map(|key| indices.get(key).copied().unwrap_or(u32::MAX))
        .collect()
}

pub(crate) fn define(
    object: &mut ObjectModule,
    module: &Module,
    functions: &[FuncId],
    tags: &[u32],
) -> Result<Option<DataId>, CodegenError> {
    if !module.functions.iter().any(|function| {
        function.blocks.iter().any(|block| {
            block
                .instructions
                .iter()
                .any(|id| function.columns.operation(*id) == Some(Operation::CallIndirect))
        })
    }) {
        return Ok(None);
    }
    let stride = usize::try_from(stride(object.isa().pointer_type())?)
        .map_err(|_| CodegenError::InvalidModule("function table stride"))?;
    let bytes = table_bytes(object, tags)?;
    let mut description = DataDescription::new();
    description.define(bytes.into_boxed_slice());
    description.set_align(u64::from(object.isa().pointer_type().bytes()));
    for (index, function) in functions.iter().enumerate() {
        let offset = index
            .checked_mul(stride)
            .and_then(|offset| u32::try_from(offset).ok())
            .ok_or(CodegenError::InvalidModule("function table offset"))?;
        let reference = object.declare_func_in_data(*function, &mut description);
        description.write_function_addr(offset, reference);
    }
    let table = object
        .declare_data("__pl_function_table", Linkage::Local, false, false)
        .map_err(CodegenError::backend)?;
    object
        .define_data(table, &description)
        .map_err(CodegenError::backend)?;
    Ok(Some(table))
}

fn table_bytes(object: &ObjectModule, tags: &[u32]) -> Result<Vec<u8>, CodegenError> {
    let width = usize::try_from(object.isa().pointer_type().bytes())
        .map_err(|_| CodegenError::InvalidModule("pointer width"))?;
    let stride = width
        .checked_mul(2)
        .ok_or(CodegenError::InvalidModule("function table stride"))?;
    let size = stride
        .checked_mul(tags.len())
        .ok_or(CodegenError::InvalidModule("function table size"))?;
    let mut bytes = vec![0u8; size];
    for (index, tag) in tags.iter().enumerate() {
        let offset = index
            .checked_mul(stride)
            .and_then(|start| start.checked_add(width))
            .ok_or(CodegenError::InvalidModule("signature table offset"))?;
        let word = match object.isa().endianness() {
            Endianness::Little => tag.to_le_bytes(),
            Endianness::Big => tag.to_be_bytes(),
        };
        bytes
            .get_mut(offset..offset.saturating_add(4))
            .ok_or(CodegenError::InvalidModule("signature table range"))?
            .copy_from_slice(&word);
    }
    Ok(bytes)
}

pub(crate) fn stride(pointer: cranelift_codegen::ir::Type) -> Result<i64, CodegenError> {
    i64::from(pointer.bytes())
        .checked_mul(2)
        .ok_or(CodegenError::InvalidModule("function table stride"))
}

pub(crate) fn tag_offset(pointer: cranelift_codegen::ir::Type) -> Result<i32, CodegenError> {
    i32::try_from(pointer.bytes()).map_err(|_| CodegenError::InvalidModule("signature offset"))
}
