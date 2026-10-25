use super::memory::memory_fault;
use super::{Flow, Machine};
use crate::{Fault, evaluate::INVALID_BYTECODE, load::memory::MemoryOp};
use pseudolearn_bytecode::{Register, RegisterClass};
use pseudolearn_runtime::{self as runtime, Handle, MemoryCell, ValueKind};

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Cell {
    Local {
        slot: Register,
        absolute: usize,
        kind: ValueKind,
    },
    Managed(MemoryCell),
}

impl Machine<'_> {
    pub(super) fn memory_cell(&mut self, operation: &MemoryOp) -> Result<Flow, Fault> {
        match operation {
            MemoryOp::CellLocal {
                destination,
                kind,
                slot,
            } => {
                self.local_cell(*destination, *kind, *slot)?;
            }
            MemoryOp::CellElement {
                destination,
                array,
                indices,
            } => {
                let array = Handle(self.reference(*array)?);
                let cell = self.array_cell(array, indices)?;
                self.save_cell(*destination, Cell::Managed(cell))?;
            }
            MemoryOp::CellField {
                destination,
                receiver,
                offset,
            } => {
                self.save_field(*destination, *receiver, *offset)?;
            }
            MemoryOp::CellLoad { destination, cell }
            | MemoryOp::CellLoadRaw { destination, cell } => {
                self.load_transport(
                    *destination,
                    *cell,
                    matches!(operation, MemoryOp::CellLoadRaw { .. }),
                )?;
            }
            MemoryOp::CellStore { cell, source } => {
                self.store_cell(self.cell(*cell)?, self.read_value(source.source)?)?
            }
            _ => return Err(INVALID_BYTECODE),
        }
        Ok(Flow::Continue)
    }

    fn save_field(&mut self, destination: u16, receiver: u16, offset: usize) -> Result<(), Fault> {
        let owner = Handle(self.reference(receiver)?);
        let cell = runtime::field_cell(&self.heap, owner, offset).map_err(memory_fault)?;
        self.save_cell(destination, Cell::Managed(cell))
    }

    fn load_transport(&mut self, destination: Register, cell: u16, raw: bool) -> Result<(), Fault> {
        let cell = self.cell(cell)?;
        let word = if raw {
            self.read_transport_cell(cell)?
        } else {
            self.read_cell(cell)?
        };
        self.write_result(destination, word)
    }

    fn array_cell(
        &self,
        array: Handle,
        sources: &[crate::load::Source],
    ) -> Result<MemoryCell, Fault> {
        if sources.len() <= 8 {
            let mut values = [0_i64; 8];
            let count = self.read_indices_into(sources, &mut values)?;
            let indices = values.get(..count).ok_or(INVALID_BYTECODE)?;
            return runtime::element_cell(&self.heap, array, indices).map_err(memory_fault);
        }
        let mut values = [0_i64; 255];
        let count = self.read_indices_into(sources, &mut values)?;
        let indices = values.get(..count).ok_or(INVALID_BYTECODE)?;
        runtime::element_cell(&self.heap, array, indices).map_err(memory_fault)
    }

    fn local_cell(
        &mut self,
        destination: u16,
        kind: ValueKind,
        slot: Register,
    ) -> Result<(), Fault> {
        let base = if slot.class == RegisterClass::Reference {
            self.cursor.reference_base
        } else {
            self.cursor.scalar_base
        };
        let absolute = base
            .checked_add(usize::from(slot.index))
            .ok_or(INVALID_BYTECODE)?;
        self.write_result(slot, kind.absent())?;
        if slot.class == RegisterClass::Scalar {
            self.set_defined(absolute, false)?;
        }
        self.save_cell(
            destination,
            Cell::Local {
                slot,
                absolute,
                kind,
            },
        )?;
        Ok(())
    }

    fn save_cell(&mut self, destination: u16, cell: Cell) -> Result<(), Fault> {
        let index = u32::try_from(self.cells.len())
            .map_err(|_| "resourceLimit")?
            .checked_add(1)
            .ok_or("resourceLimit")?;
        self.cells.try_reserve(1).map_err(|_| "resourceLimit")?;
        self.cells.push(cell);
        self.set_reference(destination, index)
    }

    pub(super) fn cell(&self, register: u16) -> Result<Cell, Fault> {
        let index = usize::try_from(
            self.reference(register)?
                .checked_sub(1)
                .ok_or(INVALID_BYTECODE)?,
        )
        .map_err(|_| INVALID_BYTECODE)?;
        self.cells.get(index).copied().ok_or(INVALID_BYTECODE)
    }

    fn read_cell(&self, cell: Cell) -> Result<u64, Fault> {
        match cell {
            Cell::Managed(cell) => {
                runtime::read_memory_cell(&self.heap, cell).map_err(memory_fault)
            }
            Cell::Local {
                slot,
                absolute,
                kind,
            } => {
                let word = if slot.class == RegisterClass::Reference {
                    u64::from(*self.references.get(absolute).ok_or(INVALID_BYTECODE)?)
                } else {
                    *self.scalars.get(absolute).ok_or(INVALID_BYTECODE)?
                };
                let defined = match kind {
                    ValueKind::Integer => *self.defined.get(absolute).ok_or(INVALID_BYTECODE)?,
                    ValueKind::Real => !f64::from_bits(word).is_nan(),
                    _ => word != kind.absent(),
                };
                if defined {
                    Ok(word)
                } else {
                    Err("uninitializedVariableRead")
                }
            }
        }
    }

    fn read_transport_cell(&self, cell: Cell) -> Result<u64, Fault> {
        match cell {
            Cell::Local { slot, absolute, .. } if slot.class == RegisterClass::Reference => self
                .references
                .get(absolute)
                .copied()
                .map(u64::from)
                .ok_or(INVALID_BYTECODE),
            Cell::Local { absolute, .. } => {
                self.scalars.get(absolute).copied().ok_or(INVALID_BYTECODE)
            }
            Cell::Managed(_) => self.read_cell(cell),
        }
    }

    fn store_cell(&mut self, cell: Cell, word: u64) -> Result<(), Fault> {
        match cell {
            Cell::Managed(cell) => {
                runtime::write_memory_cell(&mut self.heap, cell, word).map_err(memory_fault)
            }
            Cell::Local { slot, absolute, .. } if slot.class == RegisterClass::Reference => {
                self.mark_reference_dirty(absolute);
                *self.references.get_mut(absolute).ok_or(INVALID_BYTECODE)? =
                    u32::try_from(word).map_err(|_| INVALID_BYTECODE)?;
                self.reference_watermark = self.reference_watermark.max(absolute.saturating_add(1));
                Ok(())
            }
            Cell::Local { absolute, .. } => {
                self.mark_scalar_dirty(absolute);
                *self.scalars.get_mut(absolute).ok_or(INVALID_BYTECODE)? = word;
                self.scalar_watermark = self.scalar_watermark.max(absolute.saturating_add(1));
                self.set_defined(absolute, true)
            }
        }
    }
}
