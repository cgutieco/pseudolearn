use crate::frame_banks::FrameBanks;
use crate::machine::{CELL_LIMIT, Handle, Outcome, Trap};
use std::collections::BTreeSet;

pub(crate) struct Allocation {
    pub(crate) words: Vec<Option<i64>>,
    pub(crate) references: BTreeSet<usize>,
    pub(crate) array: bool,
}

pub struct SemanticMachine {
    pub(crate) banks: FrameBanks,
    pub(crate) frames: Vec<Vec<Handle>>,
    pub(crate) allocations: Vec<Option<Allocation>>,
    cells: u64,
    allocated: u64,
    live: u64,
    limit: u64,
    forced: bool,
}

impl Default for SemanticMachine {
    fn default() -> Self {
        Self::with_limit(CELL_LIMIT)
    }
}

impl SemanticMachine {
    pub fn with_limit(limit: u64) -> Self {
        Self {
            banks: FrameBanks::default(),
            frames: vec![Vec::new()],
            allocations: vec![None],
            cells: 0,
            allocated: 0,
            live: 0,
            limit,
            forced: false,
        }
    }

    pub fn reset(&mut self) {
        self.banks.reset();
        self.frames.clear();
        self.frames.push(Vec::new());
        self.allocations.clear();
        self.allocations.push(None);
        self.cells = 0;
        self.allocated = 0;
        self.live = 0;
    }

    pub fn force_collection(&mut self) {
        self.forced = true;
    }

    pub fn collect(&mut self) -> Outcome<()> {
        let mut marked = BTreeSet::new();
        let mut pending: Vec<_> = self.frames.iter().flatten().copied().collect();
        while let Some(handle) = pending.pop() {
            if handle.0 == 0 || !marked.insert(handle.0) {
                continue;
            }
            let allocation = self.allocation(handle)?;
            pending.extend(reference_handles(allocation)?);
        }
        for (index, allocation) in self.allocations.iter_mut().enumerate() {
            if !marked.contains(&u32::try_from(index).map_err(|_| Trap::CellLimit)?) {
                *allocation = None;
            }
        }
        self.cells = self
            .allocations
            .iter()
            .flatten()
            .try_fold(0_u64, |total, allocation| {
                total
                    .checked_add(allocation_cells(allocation)?)
                    .ok_or(Trap::CellLimit)
            })?;
        self.live = self.cells;
        self.allocated = 0;
        Ok(())
    }

    pub(crate) fn allocate(&mut self, allocation: Allocation) -> Outcome<Handle> {
        let cells = allocation_cells(&allocation)?;
        if self.forced
            || self.allocated >= self.live.max(4096)
            || self.cells.checked_add(cells).ok_or(Trap::CellLimit)? > self.limit
        {
            self.collect()?;
        }
        let total = self.cells.checked_add(cells).ok_or(Trap::CellLimit)?;
        if total > self.limit {
            return Err(Trap::CellLimit);
        }
        let handle = Handle(u32::try_from(self.allocations.len()).map_err(|_| Trap::CellLimit)?);
        self.allocations
            .try_reserve(1)
            .map_err(|_| Trap::CellLimit)?;
        self.frames
            .last_mut()
            .ok_or(Trap::InvalidHandle)?
            .push(handle);
        self.allocations.push(Some(allocation));
        self.cells = total;
        self.allocated = self.allocated.checked_add(cells).ok_or(Trap::CellLimit)?;
        Ok(handle)
    }

    pub(crate) fn allocation(&self, handle: Handle) -> Outcome<&Allocation> {
        usize::try_from(handle.0)
            .ok()
            .and_then(|index| self.allocations.get(index))
            .and_then(Option::as_ref)
            .ok_or(Trap::InvalidHandle)
    }

    pub(crate) fn allocation_mut(&mut self, handle: Handle) -> Outcome<&mut Allocation> {
        usize::try_from(handle.0)
            .ok()
            .and_then(|index| self.allocations.get_mut(index))
            .and_then(Option::as_mut)
            .ok_or(Trap::InvalidHandle)
    }
}

fn allocation_cells(allocation: &Allocation) -> Outcome<u64> {
    u64::try_from(allocation.words.len())
        .ok()
        .and_then(|count| count.checked_add(1))
        .ok_or(Trap::CellLimit)
}

fn reference_handles(allocation: &Allocation) -> Outcome<Vec<Handle>> {
    allocation
        .references
        .iter()
        .filter_map(|position| allocation.words.get(*position).copied().flatten())
        .map(crate::machine::handle_from_word)
        .collect()
}
