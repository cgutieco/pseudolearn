use crate::machine::{CELL_LIMIT, Handle, Outcome, Trap};

const BLOCK_WORDS: usize = 4096;

pub struct FlatHeap {
    pub words: Vec<i64>,
    pub top: usize,
}

impl Default for FlatHeap {
    fn default() -> Self {
        Self {
            words: Vec::new(),
            top: 1,
        }
    }
}

impl FlatHeap {
    pub fn reset(&mut self) {
        self.words.clear();
        self.top = 1;
    }

    pub fn allocate(&mut self, header: i64, cells: u64) -> Outcome<Handle> {
        let count = usize::try_from(cells.saturating_add(1)).map_err(|_| Trap::CellLimit)?;
        let ending = self.top.checked_add(count).ok_or(Trap::CellLimit)?;
        if u64::try_from(ending).map_err(|_| Trap::CellLimit)? > CELL_LIMIT.saturating_add(1) {
            return Err(Trap::CellLimit);
        }
        if ending > self.words.len() {
            let capacity = ending
                .checked_next_multiple_of(BLOCK_WORDS)
                .ok_or(Trap::CellLimit)?;
            self.words
                .try_reserve(capacity.saturating_sub(self.words.len()))
                .map_err(|_| Trap::CellLimit)?;
            self.words.resize(capacity, 0);
        }
        let handle = u32::try_from(self.top)
            .map(Handle)
            .map_err(|_| Trap::CellLimit)?;
        self.store(self.top, header)?;
        self.top = ending;
        Ok(handle)
    }

    #[inline(always)]
    pub fn load(&self, address: usize) -> Outcome<i64> {
        self.words.get(address).copied().ok_or(Trap::InvalidHandle)
    }

    #[inline(always)]
    pub fn store(&mut self, address: usize, word: i64) -> Outcome<()> {
        *self.words.get_mut(address).ok_or(Trap::InvalidHandle)? = word;
        Ok(())
    }
}
