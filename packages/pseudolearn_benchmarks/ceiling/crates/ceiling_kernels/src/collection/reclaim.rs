use super::{CollectionMachine, Collector, Pause};
use crate::machine::{Handle, Outcome, Trap, handle_from_word};
use std::collections::{BTreeMap, BTreeSet};
use std::time::Instant;

impl CollectionMachine {
    pub fn collect(&mut self) -> Outcome<()> {
        let start = Instant::now();
        let roots = self.frames.iter().flatten().copied().collect::<Vec<_>>();
        let seeds = if self.collector == Collector::ReferenceCounts {
            self.trial_roots(&roots)?
        } else {
            roots
        };
        let (marked, marked_words) = self.mark(seeds)?;
        let swept_words = self.sweep(&marked)?;
        self.statistics.pauses.push(Pause {
            elapsed: start.elapsed(),
            marked_words,
            swept_words,
        });
        self.statistics.collections = self.statistics.collections.saturating_add(1);
        Ok(())
    }

    fn mark(&self, mut pending: Vec<Handle>) -> Outcome<(BTreeSet<u32>, u64)> {
        let mut marked = BTreeSet::new();
        let mut words = 0_u64;
        while let Some(handle) = pending.pop() {
            if handle.0 == 0 || !marked.insert(handle.0) {
                continue;
            }
            let entry = self.allocations.get(&handle.0).ok_or(Trap::InvalidHandle)?;
            words = words
                .checked_add(u64::try_from(entry.words).map_err(|_| Trap::CellLimit)?)
                .ok_or(Trap::CellLimit)?;
            for offset in &entry.links {
                pending.push(handle_from_word(
                    self.load_word(self.slot(handle, *offset)?)?,
                )?);
            }
        }
        Ok((marked, words))
    }

    fn trial_roots(&self, roots: &[Handle]) -> Outcome<Vec<Handle>> {
        let mut trial = self
            .allocations
            .iter()
            .map(|(identity, entry)| (*identity, entry.counts))
            .collect::<BTreeMap<_, _>>();
        for root in roots {
            if let Some(count) = trial.get_mut(&root.0) {
                *count = count.checked_add(1).ok_or(Trap::CellLimit)?;
            }
        }
        for (identity, entry) in &self.allocations {
            for offset in &entry.links {
                let target =
                    handle_from_word(self.load_word(self.slot(Handle(*identity), *offset)?)?)?;
                if let Some(count) = trial.get_mut(&target.0) {
                    *count = count.checked_sub(1).ok_or(Trap::InvalidHandle)?;
                }
            }
        }
        Ok(trial
            .into_iter()
            .filter(|(_, count)| *count > 0)
            .map(|(identity, _)| Handle(identity))
            .collect())
    }

    fn sweep(&mut self, marked: &BTreeSet<u32>) -> Outcome<u64> {
        let swept = self.allocations.values().try_fold(0_u64, |total, entry| {
            total
                .checked_add(u64::try_from(entry.words).map_err(|_| Trap::CellLimit)?)
                .ok_or(Trap::CellLimit)
        })?;
        let dead = self
            .allocations
            .keys()
            .filter(|identity| !marked.contains(identity))
            .copied()
            .collect::<Vec<_>>();
        for identity in dead {
            self.release(identity)?;
        }
        if self.collector == Collector::Lines {
            self.reclaim_lines()?;
            return u64::try_from(self.top.saturating_sub(1)).map_err(|_| Trap::CellLimit);
        }
        Ok(swept)
    }

    fn release(&mut self, identity: u32) -> Outcome<()> {
        let entry = self
            .allocations
            .remove(&identity)
            .ok_or(Trap::InvalidHandle)?;
        if self.collector == Collector::ReferenceCounts {
            for offset in &entry.links {
                let address = entry.address.saturating_add(2).saturating_add(*offset);
                let target = handle_from_word(self.load_word(address)?)?;
                if let Some(target) = self.allocations.get_mut(&target.0) {
                    target.counts = target.counts.checked_sub(1).ok_or(Trap::InvalidHandle)?;
                }
            }
        }
        if self.collector != Collector::Lines {
            self.free
                .entry(entry.words)
                .or_default()
                .insert(entry.address);
        }
        Ok(())
    }
}
