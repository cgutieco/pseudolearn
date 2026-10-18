#![forbid(unsafe_code)]

use cranelift_codegen::ir::{AbiParam, InstBuilder, Signature, Type, Value, types};
use cranelift_frontend::FunctionBuilder;
use pseudolearn_ir::{Function, IrType};

pub(crate) fn clif_type(value_type: &IrType) -> Option<Type> {
    match value_type {
        IrType::I64 => Some(types::I64),
        IrType::F64 => Some(types::F64),
        IrType::Bool => Some(types::I8),
        IrType::Char | IrType::Str | IrType::Array { .. } | IrType::Object(_) | IrType::Cell(_) => {
            Some(types::I32)
        }
        IrType::Unit => None,
    }
}

pub(crate) fn extend_signature(signature: &mut Signature, pointer_type: Type, function: &Function) {
    signature.params.push(AbiParam::new(pointer_type));
    for (_, parameter_type) in &function.parameters {
        if let Some(clif) = clif_type(parameter_type) {
            signature.params.push(AbiParam::new(clif));
        }
    }
    if let Some(clif) = clif_type(&function.return_type) {
        signature.returns.push(AbiParam::new(clif));
    }
}

pub(crate) fn zero_value(builder: &mut FunctionBuilder<'_>, value_type: Type) -> Value {
    if value_type == types::F64 {
        builder.ins().f64const(0.0)
    } else {
        builder.ins().iconst(value_type, 0)
    }
}
