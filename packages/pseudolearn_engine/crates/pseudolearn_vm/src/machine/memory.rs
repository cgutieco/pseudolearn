use super::{Flow, Machine};
use crate::Fault;
use crate::evaluate::{INVALID_BYTECODE, integer_of};
use crate::load::{Source, memory::MemoryOp};
use pseudolearn_bytecode::{Register, RegisterClass};
use pseudolearn_runtime::{self as runtime, Handle, MemoryError};

impl Machine<'_> {
    pub(crate) fn memory_operation(&mut self, site: u32) -> Result<Flow, Fault> {
        let operation = self
            .current
            .memory
            .get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?)
            .ok_or(INVALID_BYTECODE)?;
        match operation {
            MemoryOp::ArrayNew {
                destination,
                element,
                dimensions,
            } => {
                self.allocate_array(*destination, *element, dimensions)?;
            }
            MemoryOp::ArrayRead {
                destination,
                array,
                indices,
            } => {
                let handle = Handle(self.reference(*array)?);
                let indices = self.read_indices(indices)?;
                let word =
                    runtime::read_element(&self.heap, handle, &indices).map_err(memory_fault)?;
                self.write_result(*destination, word)?;
            }
            MemoryOp::ArrayWrite {
                array,
                indices,
                source,
            } => {
                let handle = Handle(self.reference(*array)?);
                let indices = self.read_indices(indices)?;
                let word = self.read_value(source.source)?;
                runtime::write_element(&mut self.heap, handle, (&indices, word))
                    .map_err(memory_fault)?;
            }
            _ => return self.memory_object(operation),
        }
        Ok(Flow::Continue)
    }

    fn memory_object(&mut self, operation: &MemoryOp) -> Result<Flow, Fault> {
        match operation {
            MemoryOp::ObjectNew { destination, class } => {
                self.allocate_object(*destination, *class)?;
            }
            MemoryOp::ObjectCopy {
                destination,
                source,
            } => {
                let handle = Handle(self.reference(*source)?);
                let roots = self.memory_roots()?;
                let copy =
                    runtime::copy_object(&mut self.heap, handle, &roots).map_err(memory_fault)?;
                self.set_reference(*destination, copy.0)?;
            }
            MemoryOp::ReferenceCompare {
                destination,
                left,
                right,
                equal,
            } => {
                let comparison = self.reference(*left)? == self.reference(*right)?;
                self.set_scalar(*destination, u64::from(comparison == *equal))?;
            }
            MemoryOp::Random { destination } => {
                let value = self.random.next_real();
                self.set_scalar(*destination, value.to_bits())?;
            }
            MemoryOp::Text { .. } | MemoryOp::Output { .. } => return self.memory_text(operation),
            _ => return self.memory_cell(operation),
        }
        Ok(Flow::Continue)
    }

    fn allocate_array(
        &mut self,
        destination: u16,
        element: runtime::ValueKind,
        dimensions: &[Source],
    ) -> Result<(), Fault> {
        let dimensions = self.read_indices(dimensions)?;
        let roots = self.memory_roots()?;
        let handle = runtime::new_array(&mut self.heap, element, &dimensions, &roots)
            .map_err(memory_fault)?;
        self.set_reference(destination, handle.0)
    }

    fn allocate_object(&mut self, destination: u16, class: usize) -> Result<(), Fault> {
        let layout = self
            .program
            .layouts
            .get(class)
            .ok_or(INVALID_BYTECODE)?
            .clone();
        let roots = self.memory_roots()?;
        let handle =
            runtime::new_object_shared(&mut self.heap, layout, &roots).map_err(memory_fault)?;
        self.set_reference(destination, handle.0)?;
        Ok(())
    }

    pub(super) fn read_indices(&self, sources: &[Source]) -> Result<Vec<i64>, Fault> {
        sources
            .iter()
            .map(|source| self.source_word(*source).map(integer_of))
            .collect()
    }

    pub(super) fn source_word(&self, source: Source) -> Result<u64, Fault> {
        match source {
            Source::Immediate(word) => Ok(word),
            Source::Register(register) => self.scalar(register),
        }
    }

    pub(super) fn write_result(&mut self, destination: Register, word: u64) -> Result<(), Fault> {
        match destination.class {
            RegisterClass::Scalar => self.set_scalar(destination.index, word),
            RegisterClass::Reference => self.set_reference(
                destination.index,
                u32::try_from(word).map_err(|_| INVALID_BYTECODE)?,
            ),
        }
    }

    pub(super) fn read_value(
        &self,
        source: crate::load::memory::ValueSource,
    ) -> Result<u64, Fault> {
        match source {
            crate::load::memory::ValueSource::Scalar(source) => self.source_word(source),
            crate::load::memory::ValueSource::Reference(register) => {
                self.reference(register).map(u64::from)
            }
            crate::load::memory::ValueSource::LiteralText(index) => self
                .literals
                .get(usize::try_from(index).map_err(|_| INVALID_BYTECODE)?)
                .map(|handle| u64::from(handle.0))
                .ok_or(INVALID_BYTECODE),
        }
    }

    pub(super) fn initialize_literals(&mut self) -> Result<(), Fault> {
        for text in &self.program.literals {
            self.literals
                .push(runtime::new_text(&mut self.heap, text, true, &[]).map_err(memory_fault)?);
        }
        Ok(())
    }

    pub(crate) fn load_text(&mut self, destination: u16, index: u32) -> Result<Flow, Fault> {
        let handle = self
            .literals
            .get(usize::try_from(index).map_err(|_| INVALID_BYTECODE)?)
            .ok_or(INVALID_BYTECODE)?;
        self.set_reference(destination, handle.0)?;
        Ok(Flow::Continue)
    }
}

pub(super) fn memory_fault(error: MemoryError) -> Fault {
    match error {
        MemoryError::Resource => "resourceLimit",
        MemoryError::Internal => "internalFault",
        MemoryError::CellLimit => "cellLimitExceeded",
        MemoryError::NegativeSize => "negativeArraySize",
        MemoryError::IndexOutOfRange => "arrayIndexOutOfRange",
        MemoryError::Uninitialized => "uninitializedVariableRead",
        MemoryError::StringPositionOutOfRange => "stringPositionOutOfRange",
    }
}
