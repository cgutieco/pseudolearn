pub use crate::keywords::signature_for_builtin;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct BuiltinSignature {
    pub parameter_types: &'static [&'static str],
    pub return_type: &'static str,
}

impl BuiltinSignature {
    pub const fn new(parameter_types: &'static [&'static str], return_type: &'static str) -> Self {
        Self {
            parameter_types,
            return_type,
        }
    }

    pub fn arity(&self) -> usize {
        self.parameter_types.len()
    }
}
