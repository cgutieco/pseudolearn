use crate::machine::{Arithmetic, CELL_LIMIT, Handle, Outcome, RealOperation, Trap, apply};
use crate::paged_heap::PagedHeap;
use crate::timeline::Timeline;

pub(crate) const BANK_SLOTS: usize = 1 << 16;
pub(crate) const BANK_MASK: usize = BANK_SLOTS - 1;
pub(crate) const FRAME_SLOTS: usize = 4;

pub struct ClepsydraMachine {
    pub(crate) heap: PagedHeap,
    pub(crate) trap: Option<Trap>,
    pub(crate) cells: u64,
    pub(crate) ordinal: i64,
    pub(crate) scalars: Box<[i64; BANK_SLOTS]>,
    pub(crate) references: Box<[u32; BANK_SLOTS]>,
    pub(crate) base: usize,
    pub(crate) depth: u32,
    pub(crate) timeline: Option<Timeline>,
}

impl ClepsydraMachine {
    pub fn new(timeline: Option<Timeline>) -> Outcome<Self> {
        Ok(Self {
            heap: PagedHeap::default(),
            trap: None,
            cells: 0,
            ordinal: 0,
            scalars: vec![0; BANK_SLOTS]
                .into_boxed_slice()
                .try_into()
                .map_err(|_| Trap::CellLimit)?,
            references: vec![0; BANK_SLOTS]
                .into_boxed_slice()
                .try_into()
                .map_err(|_| Trap::CellLimit)?,
            base: 0,
            depth: 0,
            timeline,
        })
    }

    pub fn reset(&mut self) {
        self.heap.reset();
        self.trap = None;
        self.cells = 0;
        self.ordinal = 0;
        self.base = 0;
        self.depth = 0;
    }

    pub fn checkpoints(&self) -> u64 {
        self.timeline.as_ref().map_or(0, Timeline::taken)
    }

    pub(crate) fn allocate(&mut self, header: i64, cells: u64) -> Outcome<Handle> {
        self.settle()?;
        let total = self.cells.saturating_add(cells).saturating_add(1);
        if total > CELL_LIMIT {
            return Err(Trap::CellLimit);
        }
        self.cells = total;
        let address = self.heap.allocate(cells.saturating_add(1))?;
        self.heap.store(address, header)?;
        u32::try_from(address)
            .map(Handle)
            .map_err(|_| Trap::CellLimit)
    }

    pub(crate) fn element(&self, array: Handle, index: i64) -> Outcome<u64> {
        let length = self.heap.load(u64::from(array.0))?;
        if index < 0 || index >= length {
            return Err(Trap::IndexOutOfRange);
        }
        let offset = u64::try_from(index).map_err(|_| Trap::IndexOutOfRange)?;
        Ok(u64::from(array.0).wrapping_add(1).wrapping_add(offset))
    }
}

pub(crate) fn cell(object: Handle, slot: u8) -> u64 {
    u64::from(object.0)
        .wrapping_add(1)
        .wrapping_add(u64::from(slot))
}

impl Arithmetic for ClepsydraMachine {
    fn add(&mut self, left: i64, right: i64) -> Outcome<i64> {
        let (value, overflow) = left.overflowing_add(right);
        if overflow {
            self.trap.get_or_insert(Trap::IntegerOverflow);
        }
        Ok(value)
    }

    fn subtract(&mut self, left: i64, right: i64) -> Outcome<i64> {
        let (value, overflow) = left.overflowing_sub(right);
        if overflow {
            self.trap.get_or_insert(Trap::IntegerOverflow);
        }
        Ok(value)
    }

    fn multiply(&mut self, left: i64, right: i64) -> Outcome<i64> {
        let (value, overflow) = left.overflowing_mul(right);
        if overflow {
            self.trap.get_or_insert(Trap::IntegerOverflow);
        }
        Ok(value)
    }

    fn quotient(&mut self, left: i64, right: i64) -> Outcome<i64> {
        if right == 0 {
            self.trap.get_or_insert(Trap::DivisionByZero);
        }
        let divisor = if right == 0 { 1 } else { right };
        let (value, overflow) = left.overflowing_div(divisor);
        if overflow {
            self.trap.get_or_insert(Trap::IntegerOverflow);
        }
        Ok(value)
    }

    fn remainder(&mut self, left: i64, right: i64) -> Outcome<i64> {
        if right == 0 {
            self.trap.get_or_insert(Trap::DivisionByZero);
        }
        let divisor = if right == 0 { 1 } else { right };
        Ok(left.checked_rem(divisor).unwrap_or_default())
    }

    fn real(&mut self, operation: RealOperation, left: f64, right: f64) -> Outcome<f64> {
        if operation == RealOperation::Divide && right == 0.0 {
            self.trap.get_or_insert(Trap::DivisionByZero);
        }
        let value = apply(operation, left, right);
        if !value.is_finite() {
            self.trap.get_or_insert(Trap::NonFiniteReal);
        }
        Ok(value)
    }

    fn root(&mut self, value: f64) -> Outcome<f64> {
        let result = value.sqrt();
        if !result.is_finite() {
            self.trap.get_or_insert(Trap::NonFiniteReal);
        }
        Ok(result)
    }

    fn settle(&mut self) -> Outcome<()> {
        self.trap.map_or(Ok(()), Err)
    }
}
