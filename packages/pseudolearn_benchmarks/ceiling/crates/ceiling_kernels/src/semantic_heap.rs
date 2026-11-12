use crate::immediate_arithmetic::ImmediateArithmetic;
use crate::machine::{Handle, Heap, Outcome, Shape, Trap, handle_from_word, word_from_handle};
use crate::semantic_memory::{Allocation, SemanticMachine};
use std::collections::BTreeSet;

impl ImmediateArithmetic for SemanticMachine {}

impl Heap for SemanticMachine {
    fn array(&mut self, length: i64) -> Outcome<Handle> {
        let length = usize::try_from(length).map_err(|_| Trap::NegativeSize)?;
        self.allocate(Allocation {
            words: empty_words(length)?,
            references: BTreeSet::new(),
            array: true,
        })
    }

    fn read(&mut self, array: Handle, index: i64) -> Outcome<i64> {
        let position = usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)?;
        read(self, array, (position, true))
    }

    fn write(&mut self, array: Handle, index: i64, value: i64) -> Outcome<()> {
        let position = usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)?;
        write(self, array, (position, true), value)
    }

    fn read_link(&mut self, array: Handle, index: i64) -> Outcome<Handle> {
        handle_from_word(self.read(array, index)?)
    }

    fn write_link(&mut self, array: Handle, index: i64, target: Handle) -> Outcome<()> {
        self.write(array, index, word_from_handle(target))?;
        let position = usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)?;
        self.allocation_mut(array)?.references.insert(position);
        Ok(())
    }

    fn object(&mut self, shape: Shape) -> Outcome<Handle> {
        let length = usize::from(shape.links)
            .checked_add(usize::from(shape.words))
            .ok_or(Trap::CellLimit)?;
        self.allocate(Allocation {
            words: empty_words(length)?,
            references: (0..usize::from(shape.links)).collect(),
            array: false,
        })
    }

    fn field(&mut self, object: Handle, slot: u8) -> Outcome<i64> {
        read(self, object, (usize::from(slot), false))
    }

    fn set_field(&mut self, object: Handle, slot: u8, value: i64) -> Outcome<()> {
        write(self, object, (usize::from(slot), false), value)
    }

    fn link(&mut self, object: Handle, slot: u8) -> Outcome<Handle> {
        handle_from_word(self.field(object, slot)?)
    }

    fn set_link(&mut self, object: Handle, slot: u8, target: Handle) -> Outcome<()> {
        self.set_field(object, slot, word_from_handle(target))
    }
}

fn empty_words(length: usize) -> Outcome<Vec<Option<i64>>> {
    if u64::try_from(length).map_err(|_| Trap::CellLimit)? >= crate::machine::CELL_LIMIT {
        return Err(Trap::CellLimit);
    }
    let mut words = Vec::new();
    words.try_reserve(length).map_err(|_| Trap::CellLimit)?;
    words.resize(length, None);
    Ok(words)
}

fn read(
    machine: &SemanticMachine,
    handle: Handle,
    (position, array): (usize, bool),
) -> Outcome<i64> {
    let allocation = machine.allocation(handle)?;
    if allocation.array != array {
        return Err(Trap::InvalidHandle);
    }
    allocation
        .words
        .get(position)
        .ok_or(Trap::IndexOutOfRange)?
        .ok_or(Trap::Uninitialized)
}

fn write(
    machine: &mut SemanticMachine,
    handle: Handle,
    (position, array): (usize, bool),
    value: i64,
) -> Outcome<()> {
    let allocation = machine.allocation_mut(handle)?;
    if allocation.array != array {
        return Err(Trap::InvalidHandle);
    }
    *allocation
        .words
        .get_mut(position)
        .ok_or(Trap::IndexOutOfRange)? = Some(value);
    Ok(())
}
