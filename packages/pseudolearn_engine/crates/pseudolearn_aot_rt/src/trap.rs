use crate::context::AotRuntimeContext;
use crate::guard::run_entry;
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_library::LibraryError;
use pseudolearn_runtime::{ArithmeticError, MemoryError};

pub(crate) struct Trap {
    pub(crate) code: Option<DiagnosticCode>,
    pub(crate) arguments: Vec<(String, String)>,
}

impl Trap {
    pub(crate) fn named(name: &str) -> Self {
        Self::with_code(DiagnosticCode::from_name(name).unwrap_or(DiagnosticCode::InternalFault))
    }

    pub(crate) fn with_code(code: DiagnosticCode) -> Self {
        Self {
            code: Some(code),
            arguments: Vec::new(),
        }
    }

    pub(crate) fn exhausted_input() -> Self {
        Self {
            code: None,
            arguments: Vec::new(),
        }
    }
}

impl From<MemoryError> for Trap {
    fn from(error: MemoryError) -> Self {
        Self::named(match error {
            MemoryError::Resource => "resourceLimit",
            MemoryError::Internal => "internalFault",
            MemoryError::CellLimit => "cellLimitExceeded",
            MemoryError::NegativeSize => "negativeArraySize",
            MemoryError::IndexOutOfRange => "arrayIndexOutOfRange",
            MemoryError::Uninitialized => "uninitializedVariableRead",
            MemoryError::StringPositionOutOfRange => "stringPositionOutOfRange",
        })
    }
}

impl From<ArithmeticError> for Trap {
    fn from(error: ArithmeticError) -> Self {
        Self::named(match error {
            ArithmeticError::DivisionByZero => "divisionByZero",
            ArithmeticError::IntegerOverflow => "integerOverflow",
            ArithmeticError::NegativeExponent => "negativeIntegerExponent",
            ArithmeticError::NonFiniteRealResult => "nonFiniteRealResult",
        })
    }
}

impl From<LibraryError> for Trap {
    fn from(error: LibraryError) -> Self {
        match error {
            LibraryError::Arithmetic(arithmetic) => arithmetic.into(),
            LibraryError::NegativeSquareRoot
            | LibraryError::NonFiniteInput
            | LibraryError::NonFiniteResult => Self::named("nonFiniteRealResult"),
            LibraryError::PrecisionExhausted => Self::named("internalFault"),
        }
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn rt_aot_fault(context: *mut AotRuntimeContext, site: u32) -> u32 {
    run_entry(context, site, |entry| {
        let code = entry.engine.site_code(site)?;
        Err(Trap::with_code(code))
    })
}
