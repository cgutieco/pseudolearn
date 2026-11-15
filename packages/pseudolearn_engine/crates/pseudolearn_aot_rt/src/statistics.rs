use crate::engine::AotEngine;

#[derive(Clone, Copy, Debug, Default)]
pub struct AotStatistics {
    pub cell_loads: u64,
    pub cell_stores: u64,
    pub cells_created: u64,
    pub root_builds: u64,
    pub root_cells_scanned: u64,
}

impl AotEngine {
    pub fn statistics(&self) -> AotStatistics {
        self.statistics.get()
    }

    pub(crate) fn record(&self, update: impl FnOnce(&mut AotStatistics)) {
        let mut statistics = self.statistics.get();
        update(&mut statistics);
        self.statistics.set(statistics);
    }
}
