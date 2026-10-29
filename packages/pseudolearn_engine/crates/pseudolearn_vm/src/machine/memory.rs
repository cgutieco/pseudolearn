use super::{Flow, Machine};
use crate::Fault;
use crate::evaluate::{INVALID_BYTECODE, integer_of};
use crate::load::{Source, memory::MemoryOp};
use pseudolearn_bytecode::{Register, RegisterClass};
use pseudolearn_runtime::{self as runtime, Handle, MemoryError};

impl Machine<'_> {
    pub(crate) fn memory_operation(&mut self, site: u32) -> Result<Flow, Fault> {
        let function = std::sync::Arc::clone(&self.current);
        let operation = function
            .memory
            .get(usize::try_from(site).map_err(|_| INVALID_BYTECODE)?)
            .ok_or(INVALID_BYTECODE)?;
        if self.array_operation(operation)? {
            return Ok(Flow::Continue);
        }
        self.memory_object(operation)
    }

    fn memory_object(&mut self, operation: &MemoryOp) -> Result<Flow, Fault> {
        match operation {
            MemoryOp::Snapshot {
                sources,
                destinations,
            } => self.copy_snapshot(sources, destinations)?,
            MemoryOp::Collection(operation) => return self.collection_operation(operation),
            MemoryOp::ObjectNew { destination, class } => {
                self.allocate_object(*destination, *class)?
            }
            MemoryOp::ObjectCopy {
                destination,
                source,
            } => self.copy_object(*destination, *source)?,
            MemoryOp::ReferenceCompare {
                destination,
                left,
                right,
                equal,
            } => self.compare_references(*destination, (*left, *right), *equal)?,
            MemoryOp::Random { destination } => {
                let value = self.random.next_real();
                self.set_scalar(*destination, value.to_bits())?;
            }
            MemoryOp::Text { .. } | MemoryOp::Output { .. } => return self.memory_text(operation),
            _ => return self.memory_cell(operation),
        }
        Ok(Flow::Continue)
    }

    pub(crate) fn read_object_field(
        &mut self,
        destination: Register,
        receiver: u16,
        offset: usize,
    ) -> Result<Flow, Fault> {
        let handle = Handle(self.reference(receiver)?);
        let word = runtime::read_field(&self.heap, handle, offset).map_err(memory_fault)?;
        self.write_result(destination, word)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn read_object_field_raw(
        &mut self,
        destination: Register,
        receiver: u16,
        offset: usize,
    ) -> Result<Flow, Fault> {
        let handle = Handle(self.reference(receiver)?);
        let word = runtime::read_field_raw(&self.heap, handle, offset).map_err(memory_fault)?;
        self.write_result(destination, word)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn write_object_field(
        &mut self,
        receiver: u16,
        offset: usize,
        source: crate::load::memory::ValueSource,
    ) -> Result<Flow, Fault> {
        let handle = Handle(self.reference(receiver)?);
        let word = self.read_value(source)?;
        runtime::write_field(&mut self.heap, handle, (offset, word)).map_err(memory_fault)?;
        if self.probed {
            self.change_buffer
                .record_object_field(handle.0, offset, word);
        }
        Ok(Flow::Continue)
    }

    fn copy_object(&mut self, destination: u16, source: u16) -> Result<(), Fault> {
        let handle = Handle(self.reference(source)?);
        let cells = runtime::object_allocation_cells(&self.heap, handle).map_err(memory_fault)?;
        let roots = self.collection_roots(cells)?;
        let copy = runtime::copy_object(&mut self.heap, handle, &roots).map_err(memory_fault)?;
        self.set_reference(destination, copy.0)
    }

    fn compare_references(
        &mut self,
        destination: u16,
        sources: (u16, u16),
        equal: bool,
    ) -> Result<(), Fault> {
        let (left, right) = sources;
        let comparison = self.reference(left)? == self.reference(right)?;
        self.set_scalar(destination, u64::from(comparison == equal))
    }

    fn allocate_object(&mut self, destination: u16, class: usize) -> Result<(), Fault> {
        let layout = self
            .program
            .inner
            .layouts
            .get(class)
            .ok_or(INVALID_BYTECODE)?
            .clone();
        let cells = u64::try_from(layout.fields.len())
            .map_err(|_| "resourceLimit")?
            .checked_add(1)
            .ok_or("resourceLimit")?;
        let roots = self.collection_roots(cells)?;
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

    pub(super) fn collection_roots(&mut self, cells: u64) -> Result<Vec<Handle>, Fault> {
        if self.heap.needs_collection(cells) || self.options.inspect_memory {
            self.memory_roots()
        } else {
            Ok(Vec::new())
        }
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
        for text in &self.program.inner.literals {
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
        MemoryError::BytesRangeOutOfBounds => "bytesRangeOutOfBounds",
        MemoryError::EmptySeparator => "emptySeparator",
        MemoryError::JsonKindMismatch => "jsonKindMismatch",
        MemoryError::MissingDictionaryKey => "missingDictionaryKey",
        MemoryError::CollectionLimit => "collectionLimitExceeded",
        MemoryError::CollectionVersion => "collectionVersionExhausted",
        MemoryError::CollectionModified => "collectionModifiedDuringIteration",
    }
}
