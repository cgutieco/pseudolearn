use crate::machine::{
    Arithmetic, CELL_LIMIT, Calls, DEPTH_LIMIT, Handle, Heap, Outcome, RealOperation, Shape, Trap,
    apply, finite,
};

const OBJECT_CELLS: usize = 16;
const SLOT_MASK: usize = OBJECT_CELLS - 1;

type Object = [i64; OBJECT_CELLS];

#[derive(Default)]
pub struct DirectMachine {
    arrays: Vec<Vec<i64>>,
    objects: Vec<Object>,
    cells: u64,
    depth: u32,
    words: [i64; 4],
    links: [Handle; 4],
}

impl DirectMachine {
    fn charge(&mut self, cells: u64) -> Outcome<()> {
        let total = self.cells.saturating_add(cells).saturating_add(1);
        if total > CELL_LIMIT {
            return Err(Trap::CellLimit);
        }
        self.cells = total;
        Ok(())
    }

    fn cells(&mut self, array: Handle) -> Outcome<&mut Vec<i64>> {
        self.arrays
            .get_mut(usize::try_from(array.0).map_err(|_| Trap::InvalidHandle)?)
            .ok_or(Trap::InvalidHandle)
    }

    pub fn reset(&mut self) {
        self.arrays.clear();
        self.objects.clear();
        self.cells = 0;
        self.depth = 0;
    }

    fn instance(&mut self, object: Handle) -> Outcome<&mut Object> {
        self.objects
            .get_mut(usize::try_from(object.0).map_err(|_| Trap::InvalidHandle)?)
            .ok_or(Trap::InvalidHandle)
    }
}

fn position(index: i64) -> Outcome<usize> {
    usize::try_from(index).map_err(|_| Trap::IndexOutOfRange)
}

fn next_handle(count: usize) -> Outcome<Handle> {
    u32::try_from(count)
        .map(Handle)
        .map_err(|_| Trap::CellLimit)
}

impl Arithmetic for DirectMachine {
    fn add(&mut self, left: i64, right: i64) -> Outcome<i64> {
        left.checked_add(right).ok_or(Trap::IntegerOverflow)
    }

    fn subtract(&mut self, left: i64, right: i64) -> Outcome<i64> {
        left.checked_sub(right).ok_or(Trap::IntegerOverflow)
    }

    fn multiply(&mut self, left: i64, right: i64) -> Outcome<i64> {
        left.checked_mul(right).ok_or(Trap::IntegerOverflow)
    }

    fn quotient(&mut self, left: i64, right: i64) -> Outcome<i64> {
        if right == 0 {
            return Err(Trap::DivisionByZero);
        }
        left.checked_div(right).ok_or(Trap::IntegerOverflow)
    }

    fn remainder(&mut self, left: i64, right: i64) -> Outcome<i64> {
        if right == 0 {
            return Err(Trap::DivisionByZero);
        }
        Ok(left.checked_rem(right).unwrap_or(0))
    }

    fn real(&mut self, operation: RealOperation, left: f64, right: f64) -> Outcome<f64> {
        if operation == RealOperation::Divide && right == 0.0 {
            return Err(Trap::DivisionByZero);
        }
        finite(apply(operation, left, right))
    }

    fn root(&mut self, value: f64) -> Outcome<f64> {
        finite(value.sqrt())
    }

    fn settle(&mut self) -> Outcome<()> {
        Ok(())
    }
}

impl Heap for DirectMachine {
    fn array(&mut self, length: i64) -> Outcome<Handle> {
        let size = usize::try_from(length).map_err(|_| Trap::NegativeSize)?;
        self.charge(u64::try_from(size).map_err(|_| Trap::CellLimit)?)?;
        let handle = next_handle(self.arrays.len())?;
        self.arrays.push(vec![0; size]);
        Ok(handle)
    }

    fn read(&mut self, array: Handle, index: i64) -> Outcome<i64> {
        let slot = position(index)?;
        self.cells(array)?
            .get(slot)
            .copied()
            .ok_or(Trap::IndexOutOfRange)
    }

    fn write(&mut self, array: Handle, index: i64, value: i64) -> Outcome<()> {
        let slot = position(index)?;
        let cell = self
            .cells(array)?
            .get_mut(slot)
            .ok_or(Trap::IndexOutOfRange)?;
        *cell = value;
        Ok(())
    }

    fn read_link(&mut self, array: Handle, index: i64) -> Outcome<Handle> {
        crate::machine::handle_from_word(self.read(array, index)?)
    }

    fn write_link(&mut self, array: Handle, index: i64, target: Handle) -> Outcome<()> {
        self.write(array, index, crate::machine::word_from_handle(target))
    }

    fn object(&mut self, shape: Shape) -> Outcome<Handle> {
        self.charge(u64::from(shape.links).saturating_add(u64::from(shape.words)))?;
        let handle = next_handle(self.objects.len())?;
        self.objects.push([0; OBJECT_CELLS]);
        Ok(handle)
    }

    fn field(&mut self, object: Handle, slot: u8) -> Outcome<i64> {
        let cells = self.instance(object)?;
        Ok(cells
            .get(usize::from(slot) & SLOT_MASK)
            .copied()
            .unwrap_or_default())
    }

    fn set_field(&mut self, object: Handle, slot: u8, value: i64) -> Outcome<()> {
        let cells = self.instance(object)?;
        if let Some(cell) = cells.get_mut(usize::from(slot) & SLOT_MASK) {
            *cell = value;
        }
        Ok(())
    }

    fn link(&mut self, object: Handle, slot: u8) -> Outcome<Handle> {
        crate::machine::handle_from_word(self.field(object, slot)?)
    }

    fn set_link(&mut self, object: Handle, slot: u8, target: Handle) -> Outcome<()> {
        self.set_field(object, slot, crate::machine::word_from_handle(target))
    }
}

impl Calls for DirectMachine {
    fn enter(&mut self, words: &[i64], links: &[Handle]) -> Outcome<()> {
        if self.depth >= DEPTH_LIMIT {
            return Err(Trap::DepthLimit);
        }
        self.depth = self.depth.saturating_add(1);
        for (target, word) in self.words.iter_mut().zip(words) {
            *target = *word;
        }
        for (target, link) in self.links.iter_mut().zip(links) {
            *target = *link;
        }
        Ok(())
    }

    fn word(&self, slot: usize) -> i64 {
        self.words.get(slot).copied().unwrap_or_default()
    }

    fn handle(&self, slot: usize) -> Handle {
        self.links.get(slot).copied().unwrap_or_default()
    }

    fn leave(&mut self) {
        self.depth = self.depth.saturating_sub(1);
    }

    fn tick(&mut self) {}
}
