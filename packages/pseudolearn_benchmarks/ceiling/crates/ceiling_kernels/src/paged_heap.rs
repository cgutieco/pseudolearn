use crate::machine::{Outcome, Trap};
use std::rc::Rc;

pub const PAGE_WORDS: usize = 4096;
const PAGE_SHIFT: u32 = 12;
const OFFSET_MASK: usize = PAGE_WORDS - 1;

type Words = [i64; PAGE_WORDS];

#[derive(Clone)]
pub struct Page {
    epoch: u32,
    words: Rc<Words>,
}

pub struct Snapshot {
    pub pages: Vec<Page>,
}

#[derive(Default)]
pub struct PagedHeap {
    pages: Vec<Page>,
    epoch: u32,
    next: u64,
}

fn page_index(address: u64) -> Outcome<usize> {
    usize::try_from(address.wrapping_shr(PAGE_SHIFT)).map_err(|_| Trap::InvalidHandle)
}

fn offset(address: u64) -> Outcome<usize> {
    usize::try_from(address)
        .map(|value| value & OFFSET_MASK)
        .map_err(|_| Trap::InvalidHandle)
}

impl PagedHeap {
    pub fn allocate(&mut self, words: u64) -> Outcome<u64> {
        let start = self.next;
        let end = start.checked_add(words).ok_or(Trap::CellLimit)?;
        while u64::try_from(self.pages.len())
            .map_err(|_| Trap::CellLimit)?
            .wrapping_shl(PAGE_SHIFT)
            < end
        {
            self.pages.push(Page {
                epoch: self.epoch,
                words: Rc::new([0; PAGE_WORDS]),
            });
        }
        self.next = end;
        Ok(start)
    }

    pub fn load(&self, address: u64) -> Outcome<i64> {
        let page = self
            .pages
            .get(page_index(address)?)
            .ok_or(Trap::InvalidHandle)?;
        Ok(page
            .words
            .get(offset(address)?)
            .copied()
            .unwrap_or_default())
    }

    pub fn store(&mut self, address: u64, value: i64) -> Outcome<()> {
        let epoch = self.epoch;
        let page = self
            .pages
            .get_mut(page_index(address)?)
            .ok_or(Trap::InvalidHandle)?;
        if page.epoch != epoch {
            Rc::make_mut(&mut page.words);
            page.epoch = epoch;
        }
        let words = Rc::get_mut(&mut page.words).ok_or(Trap::InvalidHandle)?;
        if let Some(word) = words.get_mut(offset(address)?) {
            *word = value;
        }
        Ok(())
    }

    pub fn checkpoint(&mut self) -> Snapshot {
        self.epoch = self.epoch.wrapping_add(1);
        Snapshot {
            pages: self.pages.clone(),
        }
    }

    pub fn dirty_pages(&self, snapshot: &Snapshot) -> usize {
        self.pages
            .iter()
            .zip(&snapshot.pages)
            .filter(|(current, saved)| !Rc::ptr_eq(&current.words, &saved.words))
            .count()
    }

    pub fn reset(&mut self) {
        self.pages.clear();
        self.next = 0;
    }
}
