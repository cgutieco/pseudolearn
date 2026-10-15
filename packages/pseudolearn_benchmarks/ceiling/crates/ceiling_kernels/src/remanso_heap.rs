use crate::differential::Recording;
use crate::machine::{Handle, Heap, Outcome, Shape, Trap, handle_from_word, word_from_handle};
use crate::remanso::{IndexPolicy, RemansoMachine};

fn field_address(object: Handle, slot: u8) -> Outcome<usize> {
    let base = usize::try_from(object.0).map_err(|_| Trap::InvalidHandle)?;
    Ok(base.wrapping_add(1).wrapping_add(usize::from(slot)))
}

impl<Policy: Recording, Indexing: IndexPolicy> Heap for RemansoMachine<Policy, Indexing> {
    #[inline(always)]
    fn array(&mut self, length: i64) -> Outcome<Handle> {
        let cells = u64::try_from(length).map_err(|_| Trap::NegativeSize)?;
        self.heap.allocate(length, cells)
    }

    #[inline(always)]
    fn read(&mut self, array: Handle, index: i64) -> Outcome<i64> {
        self.heap.load(self.element(array, index)?)
    }

    #[inline(always)]
    fn write(&mut self, array: Handle, index: i64, value: i64) -> Outcome<()> {
        let address = self.element(array, index)?;
        self.recording.written(address);
        self.heap.store(address, value)
    }

    #[inline(always)]
    fn read_link(&mut self, array: Handle, index: i64) -> Outcome<Handle> {
        handle_from_word(self.read(array, index)?)
    }

    #[inline(always)]
    fn write_link(&mut self, array: Handle, index: i64, target: Handle) -> Outcome<()> {
        self.write(array, index, word_from_handle(target))
    }

    #[inline(always)]
    fn object(&mut self, shape: Shape) -> Outcome<Handle> {
        self.ordinal = self.ordinal.wrapping_add(1);
        self.heap.allocate(
            self.ordinal,
            u64::from(shape.links).saturating_add(u64::from(shape.words)),
        )
    }

    #[inline(always)]
    fn field(&mut self, object: Handle, slot: u8) -> Outcome<i64> {
        self.heap.load(field_address(object, slot)?)
    }

    #[inline(always)]
    fn set_field(&mut self, object: Handle, slot: u8, value: i64) -> Outcome<()> {
        let address = field_address(object, slot)?;
        self.recording.written(address);
        self.heap.store(address, value)
    }

    #[inline(always)]
    fn link(&mut self, object: Handle, slot: u8) -> Outcome<Handle> {
        handle_from_word(self.field(object, slot)?)
    }

    #[inline(always)]
    fn set_link(&mut self, object: Handle, slot: u8, target: Handle) -> Outcome<()> {
        self.set_field(object, slot, word_from_handle(target))
    }
}
