use super::{Flow, Machine};
use crate::Fault;
use crate::evaluate::{INVALID_BYTECODE, integer_of};
use crate::load::{Source, memory::MemoryOp};
use crate::machine::memory::memory_fault;
use pseudolearn_runtime::{self as runtime, Handle};

impl Machine<'_> {
    pub(super) fn array_operation(&mut self, operation: &MemoryOp) -> Result<bool, Fault> {
        match operation {
            MemoryOp::ArrayNew {
                destination,
                element,
                dimensions,
            } => self.allocate_array(*destination, *element, dimensions)?,
            MemoryOp::ArrayRead {
                destination,
                array,
                indices,
            } => self.read_array_many(*destination, *array, indices)?,
            MemoryOp::ArrayWrite {
                array,
                indices,
                source,
            } => self.write_array_many(*array, indices, source.source)?,
            _ => return Ok(false),
        }
        Ok(true)
    }

    fn allocate_array(
        &mut self,
        destination: u16,
        element: runtime::ValueKind,
        dimensions: &[Source],
    ) -> Result<(), Fault> {
        if dimensions.len() <= 8 {
            let mut values = [0_i64; 8];
            let count = self.read_indices_into(dimensions, &mut values)?;
            let dimensions = values.get(..count).ok_or(INVALID_BYTECODE)?;
            return self.allocate_array_values(destination, element, dimensions);
        }
        let mut values = [0_i64; 255];
        let count = self.read_indices_into(dimensions, &mut values)?;
        let dimensions = values.get(..count).ok_or(INVALID_BYTECODE)?;
        self.allocate_array_values(destination, element, dimensions)
    }

    fn allocate_array_values(
        &mut self,
        destination: u16,
        element: runtime::ValueKind,
        dimensions: &[i64],
    ) -> Result<(), Fault> {
        let roots = estimated_array_cells(dimensions)
            .map(|cells| self.collection_roots(cells))
            .transpose()?
            .unwrap_or_default();
        let handle = runtime::new_array(&mut self.heap, element, dimensions, &roots)
            .map_err(memory_fault)?;
        self.set_reference(destination, handle.0)
    }

    pub(crate) fn read_array_1d(
        &mut self,
        destination: pseudolearn_bytecode::Register,
        array: u16,
        index: Source,
    ) -> Result<Flow, Fault> {
        let handle = Handle(self.reference(array)?);
        let index = integer_of(self.source_word(index)?);
        let word = runtime::read_element_1d(&self.heap, handle, index).map_err(memory_fault)?;
        self.write_result(destination, word)?;
        Ok(Flow::Continue)
    }

    fn read_array_many(
        &mut self,
        destination: pseudolearn_bytecode::Register,
        array: u16,
        sources: &[Source],
    ) -> Result<(), Fault> {
        let handle = Handle(self.reference(array)?);
        let word = self.read_array_values(handle, sources)?;
        self.write_result(destination, word)
    }

    fn read_array_values(&self, handle: Handle, sources: &[Source]) -> Result<u64, Fault> {
        if sources.len() <= 8 {
            let mut values = [0_i64; 8];
            let count = self.read_indices_into(sources, &mut values)?;
            let indices = values.get(..count).ok_or(INVALID_BYTECODE)?;
            return runtime::read_element(&self.heap, handle, indices).map_err(memory_fault);
        }
        let mut values = [0_i64; 255];
        let count = self.read_indices_into(sources, &mut values)?;
        let indices = values.get(..count).ok_or(INVALID_BYTECODE)?;
        runtime::read_element(&self.heap, handle, indices).map_err(memory_fault)
    }

    pub(crate) fn write_array_1d(
        &mut self,
        array: u16,
        index: Source,
        source: crate::load::memory::ValueSource,
    ) -> Result<Flow, Fault> {
        let handle = Handle(self.reference(array)?);
        let index = integer_of(self.source_word(index)?);
        let word = self.read_value(source)?;
        runtime::write_element_1d(&mut self.heap, handle, index, word).map_err(memory_fault)?;
        Ok(Flow::Continue)
    }

    fn write_array_many(
        &mut self,
        array: u16,
        indices: &[Source],
        source: crate::load::memory::ValueSource,
    ) -> Result<(), Fault> {
        let handle = Handle(self.reference(array)?);
        let word = self.read_value(source)?;
        if indices.len() <= 8 {
            let mut values = [0_i64; 8];
            let count = self.read_indices_into(indices, &mut values)?;
            let indices = values.get(..count).ok_or(INVALID_BYTECODE)?;
            return runtime::write_element(&mut self.heap, handle, (indices, word))
                .map_err(memory_fault);
        }
        let mut values = [0_i64; 255];
        let count = self.read_indices_into(indices, &mut values)?;
        let indices = values.get(..count).ok_or(INVALID_BYTECODE)?;
        runtime::write_element(&mut self.heap, handle, (indices, word)).map_err(memory_fault)
    }
}

impl Machine<'_> {
    pub(super) fn read_indices_into(
        &self,
        sources: &[Source],
        values: &mut [i64],
    ) -> Result<usize, Fault> {
        if sources.len() > values.len() {
            return Err(INVALID_BYTECODE);
        }
        for (position, source) in sources.iter().enumerate() {
            let value = integer_of(self.source_word(*source)?);
            *values.get_mut(position).ok_or(INVALID_BYTECODE)? = value;
        }
        Ok(sources.len())
    }
}

fn estimated_array_cells(dimensions: &[i64]) -> Option<u64> {
    if dimensions.is_empty() || dimensions.iter().any(|extent| *extent < 0) {
        return None;
    }
    if dimensions.contains(&0) {
        return Some(1);
    }
    dimensions
        .iter()
        .try_fold(1_u64, |total, extent| {
            u64::try_from(*extent)
                .ok()
                .and_then(|extent| total.checked_mul(extent))
        })
        .and_then(|total| total.checked_add(1))
}
