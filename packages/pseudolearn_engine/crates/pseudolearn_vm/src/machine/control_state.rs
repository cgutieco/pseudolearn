use crate::load::LoadedFunction;
use pseudolearn_bytecode::Register;

#[derive(Clone, Copy, Default)]
pub(crate) struct Cursor {
    pub(crate) program_counter: usize,
    pub(crate) scalar_base: usize,
    pub(crate) reference_base: usize,
}

#[derive(Clone, Copy)]
pub(crate) struct ControlFrame<'program> {
    pub(crate) function: &'program LoadedFunction,
    pub(crate) return_point: usize,
    pub(crate) destination: Option<Register>,
    pub(crate) scalar_base: usize,
    pub(crate) reference_base: usize,
    pub(crate) cell_count: usize,
}
