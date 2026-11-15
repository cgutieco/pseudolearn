use super::{CollectionMachine, Collector};
use crate::machine::{Handle, Heap, Outcome, Shape, Trap, handle_from_word, word_from_handle};

impl Heap for CollectionMachine {
    fn array(&mut self, length: i64) -> Outcome<Handle> {
        self.allocate(
            usize::try_from(length).map_err(|_| Trap::NegativeSize)?,
            true,
        )
    }

    fn read(&mut self, array: Handle, index: i64) -> Outcome<i64> {
        if !self
            .allocations
            .get(&array.0)
            .is_some_and(|entry| entry.array)
        {
            return Err(Trap::InvalidHandle);
        }
        let address = self.slot(
            array,
            usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)?,
        )?;
        self.load_word(address)
    }

    fn write(&mut self, array: Handle, index: i64, value: i64) -> Outcome<()> {
        let index = usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)?;
        let address = self.slot(array, index)?;
        self.store_word(address, value)
    }

    fn read_link(&mut self, array: Handle, index: i64) -> Outcome<Handle> {
        handle_from_word(self.read(array, index)?)
    }

    fn write_link(&mut self, array: Handle, index: i64, target: Handle) -> Outcome<()> {
        let offset = usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)?;
        self.store_link(array, offset, target)
    }

    fn object(&mut self, shape: Shape) -> Outcome<Handle> {
        self.allocate(
            usize::from(shape.links).saturating_add(usize::from(shape.words)),
            false,
        )
    }

    fn field(&mut self, object: Handle, slot: u8) -> Outcome<i64> {
        self.load_word(self.slot(object, usize::from(slot))?)
    }

    fn set_field(&mut self, object: Handle, slot: u8, value: i64) -> Outcome<()> {
        self.store_word(self.slot(object, usize::from(slot))?, value)
    }

    fn link(&mut self, object: Handle, slot: u8) -> Outcome<Handle> {
        handle_from_word(self.field(object, slot)?)
    }

    fn set_link(&mut self, object: Handle, slot: u8, target: Handle) -> Outcome<()> {
        self.store_link(object, usize::from(slot), target)
    }
}

impl CollectionMachine {
    fn store_link(&mut self, owner: Handle, offset: usize, target: Handle) -> Outcome<()> {
        let address = self.slot(owner, offset)?;
        let previous = handle_from_word(self.load_word(address)?)?;
        if self.collector == Collector::ReferenceCounts {
            if let Some(entry) = self.allocations.get_mut(&previous.0) {
                entry.counts = entry.counts.checked_sub(1).ok_or(Trap::InvalidHandle)?;
            }
            if let Some(entry) = self.allocations.get_mut(&target.0) {
                entry.counts = entry.counts.checked_add(1).ok_or(Trap::CellLimit)?;
            }
        }
        self.allocations
            .get_mut(&owner.0)
            .ok_or(Trap::InvalidHandle)?
            .links
            .insert(offset);
        self.store_word(address, word_from_handle(target))
    }
}
