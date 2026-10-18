#![forbid(unsafe_code)]

use crate::error::CodegenError;
use cranelift_codegen::ir::{AbiParam, FuncRef, Function, Signature, Type, types};
use cranelift_module::{FuncId, Linkage, Module};
use cranelift_object::ObjectModule;

pub const FAULT_SYMBOL: &str = "rt_aot_fault";
pub const MATH_UNARY_SYMBOL: &str = "rt_aot_math_unary";
pub const REAL_POWER_SYMBOL: &str = "rt_aot_real_power";
pub const INTEGER_POWER_SYMBOL: &str = "rt_aot_integer_power";

pub(crate) struct RuntimeImports {
    fault: FuncId,
    math_unary: FuncId,
    real_power: FuncId,
    integer_power: FuncId,
}

#[derive(Clone, Copy)]
pub(crate) struct RuntimeRefs {
    pub(crate) fault: FuncRef,
    pub(crate) math_unary: FuncRef,
    pub(crate) real_power: FuncRef,
    pub(crate) integer_power: FuncRef,
}

impl RuntimeImports {
    pub(crate) fn declare(module: &mut ObjectModule, pointer: Type) -> Result<Self, CodegenError> {
        let fault = declare_import(module, FAULT_SYMBOL, &[pointer, types::I32])?;
        let math_unary = declare_import(
            module,
            MATH_UNARY_SYMBOL,
            &[pointer, types::I32, types::I32, types::I64],
        )?;
        let power = [pointer, types::I32, types::I64, types::I64];
        Ok(Self {
            fault,
            math_unary,
            real_power: declare_import(module, REAL_POWER_SYMBOL, &power)?,
            integer_power: declare_import(module, INTEGER_POWER_SYMBOL, &power)?,
        })
    }

    pub(crate) fn import_into(
        &self,
        module: &mut ObjectModule,
        function: &mut Function,
    ) -> RuntimeRefs {
        RuntimeRefs {
            fault: module.declare_func_in_func(self.fault, function),
            math_unary: module.declare_func_in_func(self.math_unary, function),
            real_power: module.declare_func_in_func(self.real_power, function),
            integer_power: module.declare_func_in_func(self.integer_power, function),
        }
    }
}

fn declare_import(
    module: &mut ObjectModule,
    symbol: &str,
    parameters: &[Type],
) -> Result<FuncId, CodegenError> {
    let mut signature: Signature = module.make_signature();
    for parameter in parameters {
        signature.params.push(AbiParam::new(*parameter));
    }
    signature.returns.push(AbiParam::new(types::I32));
    module
        .declare_function(symbol, Linkage::Import, &signature)
        .map_err(CodegenError::backend)
}
