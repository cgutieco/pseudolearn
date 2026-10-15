#![forbid(unsafe_code)]

use crate::Fault;
use crate::evaluate::INVALID_BYTECODE;
use crate::load::{Definition, Move, Sentinel};
use crate::machine::{Flow, Machine};

const UNINITIALIZED: Fault = "uninitializedVariableRead";

impl Machine<'_> {
    #[inline(always)]
    pub(crate) fn scalar(&self, register: u16) -> Result<u64, Fault> {
        self.scalars
            .get(self.cursor.scalar_base.wrapping_add(usize::from(register)))
            .copied()
            .ok_or(INVALID_BYTECODE)
    }

    #[inline(always)]
    pub(crate) fn set_scalar(&mut self, register: u16, word: u64) -> Result<(), Fault> {
        let slot = self
            .scalars
            .get_mut(self.cursor.scalar_base.wrapping_add(usize::from(register)))
            .ok_or(INVALID_BYTECODE)?;
        *slot = word;
        Ok(())
    }

    #[inline(always)]
    pub(crate) fn reference(&self, register: u16) -> Result<u32, Fault> {
        self.references
            .get(
                self.cursor
                    .reference_base
                    .wrapping_add(usize::from(register)),
            )
            .copied()
            .ok_or(INVALID_BYTECODE)
    }

    #[inline(always)]
    pub(crate) fn set_reference(&mut self, register: u16, handle: u32) -> Result<(), Fault> {
        let slot = self
            .references
            .get_mut(
                self.cursor
                    .reference_base
                    .wrapping_add(usize::from(register)),
            )
            .ok_or(INVALID_BYTECODE)?;
        *slot = handle;
        Ok(())
    }

    pub(crate) fn is_defined(&self, register: u16) -> Result<bool, Fault> {
        self.defined
            .get(self.cursor.scalar_base.wrapping_add(usize::from(register)))
            .copied()
            .ok_or(INVALID_BYTECODE)
    }

    pub(crate) fn set_defined(&mut self, position: usize, value: bool) -> Result<(), Fault> {
        let slot = self.defined.get_mut(position).ok_or(INVALID_BYTECODE)?;
        *slot = value;
        Ok(())
    }

    #[inline(always)]
    pub(crate) fn move_within(&mut self, entry: &Move) -> Result<(), Fault> {
        match entry.class {
            pseudolearn_bytecode::RegisterClass::Scalar => {
                let word = self.scalar(entry.source)?;
                self.set_scalar(entry.destination, word)?;
                self.copy_definition(entry)
            }
            pseudolearn_bytecode::RegisterClass::Reference => {
                let handle = self.reference(entry.source)?;
                self.set_reference(entry.destination, handle)
            }
        }
    }

    fn copy_definition(&mut self, entry: &Move) -> Result<(), Fault> {
        let value = match entry.definition {
            Definition::Untracked => return Ok(()),
            Definition::Defined => true,
            Definition::Undefined => false,
            Definition::Copied => self.is_defined(entry.source)?,
        };
        let position = self
            .cursor
            .scalar_base
            .wrapping_add(usize::from(entry.destination));
        self.set_defined(position, value)
    }

    pub(crate) fn load_word(&mut self, destination: u16, word: u64) -> Result<Flow, Fault> {
        self.set_scalar(destination, word)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn mark_undefined(&mut self, destination: u16, word: u64) -> Result<Flow, Fault> {
        self.load_word(destination, word)
    }

    pub(crate) fn mark_undefined_reference(&mut self, destination: u16) -> Result<Flow, Fault> {
        self.set_reference(destination, 0)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn move_scalar(&mut self, destination: u16, source: u16) -> Result<Flow, Fault> {
        let word = self.scalar(source)?;
        self.load_word(destination, word)
    }

    pub(crate) fn move_reference(&mut self, destination: u16, source: u16) -> Result<Flow, Fault> {
        let handle = self.reference(source)?;
        self.set_reference(destination, handle)?;
        Ok(Flow::Continue)
    }

    pub(crate) fn require_defined_integer(
        &mut self,
        destination: u16,
        source: u16,
    ) -> Result<Flow, Fault> {
        if !self.is_defined(source)? {
            return Err(UNINITIALIZED);
        }
        self.move_scalar(destination, source)
    }

    pub(crate) fn require_sentinel(
        &mut self,
        destination: u16,
        source: u16,
        sentinel: Sentinel,
    ) -> Result<Flow, Fault> {
        let word = self.scalar(source)?;
        let defined = match sentinel {
            Sentinel::Real => !f64::from_bits(word).is_nan(),
            Sentinel::Boolean => word <= 1,
            Sentinel::Character => u32::try_from(word).ok().and_then(char::from_u32).is_some(),
            Sentinel::Unit => true,
        };
        if !defined {
            return Err(UNINITIALIZED);
        }
        self.load_word(destination, word)
    }

    pub(crate) fn require_reference(
        &mut self,
        destination: u16,
        source: u16,
    ) -> Result<Flow, Fault> {
        if self.reference(source)? == 0 {
            return Err(UNINITIALIZED);
        }
        self.move_reference(destination, source)
    }

    pub(crate) fn require_failed(&mut self) -> Result<Flow, Fault> {
        Err(UNINITIALIZED)
    }

    pub(crate) fn observe(&mut self) -> Result<Flow, Fault> {
        Ok(Flow::Continue)
    }
}
