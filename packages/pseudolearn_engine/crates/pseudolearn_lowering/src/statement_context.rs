#![forbid(unsafe_code)]

use crate::builder::FunctionBuilder;
use crate::environment::VariableEnvironment;
use crate::expressions::ExpressionContext;
use pseudolearn_ir::OriginEntry;

pub struct StatementContext<'context_lifetime, 'module_lifetime> {
    pub expression_context: &'context_lifetime ExpressionContext<'module_lifetime>,
    pub environment: &'context_lifetime mut VariableEnvironment,
    pub builder: &'context_lifetime mut FunctionBuilder,
    pub origins: &'context_lifetime mut Vec<OriginEntry>,
}
