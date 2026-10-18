#![forbid(unsafe_code)]

use crate::error::CodegenError;
use pseudolearn_aot_rt::{FaultSite, SourceRange};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_ir::IrSpan;

#[derive(Debug, Default)]
pub(crate) struct FaultTable {
    sites: Vec<FaultSite>,
}

impl FaultTable {
    pub(crate) fn register(
        &mut self,
        code_name: &'static str,
        span: Option<IrSpan>,
        lexeme: String,
    ) -> Result<u32, CodegenError> {
        let code = DiagnosticCode::from_name(code_name)
            .ok_or(CodegenError::InvalidModule("unknown diagnostic code"))?;
        let identifier = u32::try_from(self.sites.len())
            .map_err(|_| CodegenError::InvalidModule("too many fault sites"))?;
        self.sites.push(FaultSite {
            lexeme,
            code,
            range: range_of(span),
        });
        Ok(identifier)
    }

    pub(crate) fn into_sites(self) -> Vec<FaultSite> {
        self.sites
    }
}

fn range_of(span: Option<IrSpan>) -> SourceRange {
    span.map_or_else(SourceRange::default, |entry| SourceRange {
        start_line: entry.start_line,
        start_column: entry.start_column,
        end_line: entry.end_line,
        end_column: entry.end_column,
    })
}
