use std::sync::Arc;

use crate::load::LoadedFunction;
use pseudolearn_bytecode::Register;

#[derive(Clone, Copy, Default)]
pub(crate) struct Cursor {
    pub(crate) program_counter: usize,
    pub(crate) scalar_base: usize,
    pub(crate) reference_base: usize,
}

#[derive(Clone)]
pub(crate) struct ControlFrame {
    pub(crate) function: Arc<LoadedFunction>,
    pub(crate) function_index: usize,
    pub(crate) return_point: usize,
    pub(crate) destination: Option<Register>,
    pub(crate) scalar_base: usize,
    pub(crate) reference_base: usize,
    pub(crate) scalar_limit: usize,
    pub(crate) reference_limit: usize,
    pub(crate) cell_count: usize,
}
