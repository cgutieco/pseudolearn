use pseudolearn_project::find_cycles;

struct Generator(u64);

impl Generator {
    fn next(&mut self, bound: u64) -> u64 {
        self.0 = self
            .0
            .wrapping_mul(6_364_136_223_846_793_005)
            .wrapping_add(1_442_695_040_888_963_407);
        self.0
            .checked_shr(33)
            .unwrap_or(0)
            .checked_rem(bound)
            .unwrap_or(0)
    }

    fn below(&mut self, bound: usize) -> usize {
        usize::try_from(self.next(u64::try_from(bound).unwrap_or(1))).unwrap_or(0)
    }

    fn shuffle<Content>(&mut self, values: &mut [Content]) {
        for position in (1..values.len()).rev() {
            let other = self.below(position.saturating_add(1));
            values.swap(position, other);
        }
    }
}

fn names(count: usize) -> Vec<String> {
    (0..count).map(|index| format!("node-{index:03}")).collect()
}

fn named_chains(labels: &[String], edges: &[(usize, usize)]) -> Vec<Vec<String>> {
    find_cycles(labels, edges)
        .into_iter()
        .map(|chain| {
            chain
                .into_iter()
                .filter_map(|vertex| labels.get(vertex).cloned())
                .collect()
        })
        .collect()
}

fn random_edges(generator: &mut Generator, count: usize) -> Vec<(usize, usize)> {
    let total = generator.below(count.saturating_mul(2).saturating_add(1));
    (0..total)
        .map(|_| (generator.below(count), generator.below(count)))
        .collect()
}

fn permuted(
    generator: &mut Generator,
    labels: &[String],
    edges: &[(usize, usize)],
) -> (Vec<String>, Vec<(usize, usize)>) {
    let mut placement: Vec<usize> = (0..labels.len()).collect();
    generator.shuffle(&mut placement);
    let mut moved = labels.to_vec();
    for (old, new) in placement.iter().enumerate() {
        if let (Some(slot), Some(label)) = (moved.get_mut(*new), labels.get(old)) {
            slot.clone_from(label);
        }
    }
    let mut relabeled: Vec<(usize, usize)> = edges
        .iter()
        .filter_map(|(from, target)| Some((*placement.get(*from)?, *placement.get(*target)?)))
        .collect();
    relabeled.extend(relabeled.clone());
    generator.shuffle(&mut relabeled);
    (moved, relabeled)
}

#[test]
fn chains_do_not_depend_on_vertex_numbering_or_edge_order() {
    for seed in 1..=200_u64 {
        let mut generator = Generator(seed);
        let count = generator.below(11).saturating_add(1);
        let labels = names(count);
        let edges = random_edges(&mut generator, count);
        let expected = named_chains(&labels, &edges);
        let (moved, relabeled) = permuted(&mut generator, &labels, &edges);
        assert_eq!(named_chains(&moved, &relabeled), expected, "seed {seed}");
    }
}

#[test]
fn every_reported_chain_is_closed_and_follows_existing_edges() {
    for seed in 1..=200_u64 {
        let mut generator = Generator(seed);
        let count = generator.below(11).saturating_add(1);
        let edges = random_edges(&mut generator, count);
        for chain in find_cycles(&names(count), &edges) {
            assert_eq!(chain.first(), chain.last(), "seed {seed}");
            assert!(chain.windows(2).all(|pair| match pair {
                [from, target] => edges.contains(&(*from, *target)),
                _ => false,
            }));
        }
    }
}
