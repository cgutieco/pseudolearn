#![forbid(unsafe_code)]

use pseudolearn_bytecode::SourceSpan;

pub(crate) type Fault = &'static str;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct VmTrap {
    pub code: &'static str,
    pub span: Option<SourceSpan>,
    pub related: Vec<SourceSpan>,
    pub arguments:
        std::collections::BTreeMap<&'static str, pseudolearn_diagnostics::DiagnosticArgument>,
}

impl VmTrap {
    #[cold]
    #[inline(never)]
    pub(crate) const fn new(code: &'static str, span: Option<SourceSpan>) -> Self {
        Self {
            code,
            span,
            related: Vec::new(),
            arguments: std::collections::BTreeMap::new(),
        }
    }
}
