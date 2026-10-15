#![forbid(unsafe_code)]

use pseudolearn_bytecode::{BytecodeFunction, Register, RegisterClass, ValueType};

use crate::{RuntimeValue, VmTrap};
use banks::{bank_size, grow_bank, grow_reference_bank};

mod banks;

#[derive(Clone)]
pub(crate) struct Frame {
    pub function_index: u16,
    pub program_counter: u32,
    pub needs_block_charge: bool,
    pub pending_block_mass: u32,
    pub scalar_bank: Vec<u64>,
    pub reference_bank: Vec<u32>,
    scalar_kinds: Vec<ScalarKind>,
    integer_defined: Vec<bool>,
    reference_register_count: usize,
    pub return_destination: Option<Register>,
    pub return_point: Option<u32>,
}

impl Frame {
    pub fn new(
        function_index: u16,
        function: &BytecodeFunction,
        return_destination: Option<Register>,
        return_point: Option<u32>,
    ) -> Result<Self, VmTrap> {
        let scalar_size = bank_size(function.scalar_types.len())?;
        let reference_size = bank_size(function.reference_types.len())?;
        let pending_block_mass = function.fast.blocks.first().map_or(0, |block| block.mass);
        let scalar_kinds = function
            .scalar_types
            .iter()
            .map(ScalarKind::from_type)
            .collect();
        Ok(Self {
            function_index,
            program_counter: 0,
            needs_block_charge: true,
            pending_block_mass,
            scalar_bank: vec![0; scalar_size],
            reference_bank: vec![0; reference_size],
            scalar_kinds,
            integer_defined: vec![false; scalar_size],
            reference_register_count: function.reference_types.len(),
            return_destination,
            return_point,
        })
    }

    pub fn read(&self, register: Register) -> Result<RuntimeValue, VmTrap> {
        let position = usize::from(register.index);
        match register.class {
            RegisterClass::Scalar => self
                .scalar_bank
                .get(position)
                .copied()
                .map(RuntimeValue::Scalar)
                .ok_or_else(|| VmTrap::new("invalidBytecode", None)),
            RegisterClass::Reference => self
                .reference_bank
                .get(position)
                .copied()
                .map(RuntimeValue::Reference)
                .ok_or_else(|| VmTrap::new("invalidBytecode", None)),
        }
    }

    pub fn write(&mut self, register: Register, value: RuntimeValue) -> Result<(), VmTrap> {
        match (register.class, value) {
            (RegisterClass::Scalar, RuntimeValue::Scalar(word)) => {
                let position = usize::from(register.index);
                let kind = self
                    .scalar_kinds
                    .get(position)
                    .copied()
                    .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
                grow_bank(&mut self.scalar_bank, position)?;
                if let Some(slot) = self.scalar_bank.get_mut(position) {
                    *slot = word;
                    if kind == ScalarKind::Integer
                        && let Some(initialized) = self.integer_defined.get_mut(position)
                    {
                        *initialized = true;
                    }
                    Ok(())
                } else {
                    Err(VmTrap::new("invalidBytecode", None))
                }
            }
            (RegisterClass::Reference, RuntimeValue::Reference(handle)) => {
                let position = usize::from(register.index);
                if position >= self.reference_register_count {
                    return Err(VmTrap::new("invalidBytecode", None));
                }
                grow_reference_bank(&mut self.reference_bank, position)?;
                if let Some(slot) = self.reference_bank.get_mut(position) {
                    *slot = handle;
                    Ok(())
                } else {
                    Err(VmTrap::new("invalidBytecode", None))
                }
            }
            _ => Err(VmTrap::new("invalidBytecode", None)),
        }
    }

    pub(crate) fn read_scalar(&self, index: u16) -> Result<u64, VmTrap> {
        self.scalar_bank
            .get(usize::from(index))
            .copied()
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))
    }

    pub(crate) fn write_scalar(&mut self, index: u16, value: u64) -> Result<(), VmTrap> {
        let position = usize::from(index);
        let kind = self
            .scalar_kinds
            .get(position)
            .copied()
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
        let slot = self
            .scalar_bank
            .get_mut(position)
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
        *slot = value;
        if kind == ScalarKind::Integer {
            let initialized = self
                .integer_defined
                .get_mut(position)
                .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
            *initialized = true;
        }
        Ok(())
    }

    pub fn copy_parallel(
        &mut self,
        sources: &[Register],
        destinations: &[Register],
    ) -> Result<(), VmTrap> {
        if sources.len() != destinations.len() {
            return Err(VmTrap::new("invalidBytecode", None));
        }
        if sources.is_empty() {
            return Ok(());
        }
        if sources.len() == 1 {
            let source = sources
                .first()
                .copied()
                .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
            let destination = destinations
                .first()
                .copied()
                .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
            return self.copy_one(source, destination);
        }
        let values = sources
            .iter()
            .copied()
            .zip(destinations.iter().copied())
            .map(|(source, destination)| {
                Ok((destination, self.read(source)?, self.is_defined(source)?))
            })
            .collect::<Result<Vec<_>, _>>()?;
        for (destination, value, is_defined) in values {
            self.write(destination, value)?;
            if !is_defined {
                self.mark_undefined(destination)?;
            }
        }
        Ok(())
    }

    fn copy_one(&mut self, source: Register, destination: Register) -> Result<(), VmTrap> {
        let value = self.read(source)?;
        let is_defined = self.is_defined(source)?;
        self.write(destination, value)?;
        if !is_defined {
            self.mark_undefined(destination)?;
        }
        Ok(())
    }

    pub fn mark_undefined(&mut self, register: Register) -> Result<(), VmTrap> {
        match register.class {
            RegisterClass::Scalar => self.mark_scalar_undefined(register),
            RegisterClass::Reference => self.write(register, RuntimeValue::Reference(0)),
        }
    }

    pub fn is_defined(&self, register: Register) -> Result<bool, VmTrap> {
        let position = usize::from(register.index);
        match register.class {
            RegisterClass::Scalar => {
                let kind = self
                    .scalar_kinds
                    .get(position)
                    .copied()
                    .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
                let word = self
                    .scalar_bank
                    .get(position)
                    .copied()
                    .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
                if kind == ScalarKind::Integer {
                    return self
                        .integer_defined
                        .get(position)
                        .copied()
                        .ok_or_else(|| VmTrap::new("invalidBytecode", None));
                }
                Ok(kind.is_defined(word))
            }
            RegisterClass::Reference => self
                .reference_bank
                .get(position)
                .map(|handle| *handle != 0)
                .filter(|_| position < self.reference_register_count)
                .ok_or_else(|| VmTrap::new("invalidBytecode", None)),
        }
    }

    fn mark_scalar_undefined(&mut self, register: Register) -> Result<(), VmTrap> {
        let position = usize::from(register.index);
        let kind = self
            .scalar_kinds
            .get(position)
            .copied()
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
        let sentinel = kind.sentinel();
        let slot = self
            .scalar_bank
            .get_mut(position)
            .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
        *slot = sentinel;
        if kind == ScalarKind::Integer {
            let initialized = self
                .integer_defined
                .get_mut(position)
                .ok_or_else(|| VmTrap::new("invalidBytecode", None))?;
            *initialized = false;
        }
        Ok(())
    }
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum ScalarKind {
    Integer,
    Real,
    Boolean,
    Character,
    Unit,
}

impl ScalarKind {
    fn from_type(value_type: &ValueType) -> Self {
        match value_type {
            ValueType::I64 => Self::Integer,
            ValueType::F64 => Self::Real,
            ValueType::Bool => Self::Boolean,
            ValueType::Char => Self::Character,
            _ => Self::Unit,
        }
    }

    fn sentinel(self) -> u64 {
        match self {
            Self::Integer | Self::Unit => 0,
            Self::Real => f64::NAN.to_bits(),
            Self::Boolean => 2,
            Self::Character => 0x11_0000,
        }
    }

    fn is_defined(self, word: u64) -> bool {
        match self {
            Self::Integer => false,
            Self::Real => word != self.sentinel(),
            Self::Boolean => word <= 1,
            Self::Character => u32::try_from(word).ok().and_then(char::from_u32).is_some(),
            Self::Unit => true,
        }
    }
}
