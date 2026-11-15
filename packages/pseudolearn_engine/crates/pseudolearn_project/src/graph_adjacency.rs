pub(crate) const UNSET: usize = usize::MAX;

pub(crate) struct Adjacency {
    offsets: Vec<usize>,
    targets: Vec<usize>,
}

impl Adjacency {
    pub(crate) fn build(vertex_count: usize, edges: &[(usize, usize)]) -> Self {
        let mut sorted: Vec<(usize, usize)> = edges
            .iter()
            .copied()
            .filter(|(from, target)| *from < vertex_count && *target < vertex_count)
            .collect();
        sorted.sort_unstable();
        sorted.dedup();
        let mut offsets = vec![0_usize; vertex_count.saturating_add(1)];
        for (from, _) in &sorted {
            if let Some(slot) = offsets.get_mut(from.saturating_add(1)) {
                *slot = slot.saturating_add(1);
            }
        }
        let mut running = 0_usize;
        for slot in &mut offsets {
            running = running.saturating_add(*slot);
            *slot = running;
        }
        let targets = sorted.into_iter().map(|(_, target)| target).collect();
        Self { offsets, targets }
    }

    pub(crate) fn vertex_count(&self) -> usize {
        self.offsets.len().saturating_sub(1)
    }

    pub(crate) fn neighbors(&self, vertex: usize) -> &[usize] {
        let start = self.offsets.get(vertex).copied();
        let end = self.offsets.get(vertex.saturating_add(1)).copied();
        match (start, end) {
            (Some(start), Some(end)) => self.targets.get(start..end).unwrap_or_default(),
            _ => &[],
        }
    }

    pub(crate) fn has_self_edge(&self, vertex: usize) -> bool {
        self.neighbors(vertex).binary_search(&vertex).is_ok()
    }
}

pub(crate) fn read(values: &[usize], index: usize) -> usize {
    values.get(index).copied().unwrap_or(UNSET)
}

pub(crate) fn write(values: &mut [usize], index: usize, value: usize) {
    if let Some(slot) = values.get_mut(index) {
        *slot = value;
    }
}
