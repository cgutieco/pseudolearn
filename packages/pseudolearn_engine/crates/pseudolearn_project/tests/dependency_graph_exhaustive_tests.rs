use pseudolearn_project::find_cycles;
use std::collections::BTreeSet;

type Edges = BTreeSet<(usize, usize)>;

fn keys(count: usize) -> Vec<String> {
    (0..count).map(|index| format!("v{index:02}")).collect()
}

fn closure(edges: &Edges) -> Edges {
    let mut reach = edges.clone();
    loop {
        let mut grown = reach.clone();
        for (first, middle) in &reach {
            for (other, last) in &reach {
                if middle == other {
                    grown.insert((*first, *last));
                }
            }
        }
        if grown == reach {
            return reach;
        }
        reach = grown;
    }
}

fn better(candidate: &[usize], best: &Option<Vec<usize>>) -> bool {
    match best {
        None => true,
        Some(current) => (candidate.len(), candidate) < (current.len(), current.as_slice()),
    }
}

fn extend(path: &mut Vec<usize>, edges: &Edges, best: &mut Option<Vec<usize>>) {
    let (Some(start), Some(last)) = (path.first().copied(), path.last().copied()) else {
        return;
    };
    if edges.contains(&(last, start)) {
        let mut candidate = path.clone();
        candidate.push(start);
        if better(&candidate, best) {
            *best = Some(candidate);
        }
    }
    let successors: Vec<usize> = edges
        .iter()
        .filter(|(from, target)| *from == last && !path.contains(target))
        .map(|(_, target)| *target)
        .collect();
    for next in successors {
        path.push(next);
        extend(path, edges, best);
        path.pop();
    }
}

fn oracle(count: usize, edges: &Edges) -> Vec<Vec<usize>> {
    let reach = closure(edges);
    let mut expected = Vec::new();
    for start in 0..count {
        let minimal = (0..start)
            .all(|other| !(reach.contains(&(other, start)) && reach.contains(&(start, other))));
        if reach.contains(&(start, start)) && minimal {
            let mut best = None;
            extend(&mut vec![start], edges, &mut best);
            expected.extend(best);
        }
    }
    expected
}

fn graph_from_mask(count: usize, mask: u32) -> Edges {
    let mut edges = Edges::new();
    let mut bit = 0_u32;
    for from in 0..count {
        for target in 0..count {
            if mask.checked_shr(bit).unwrap_or(0) & 1 == 1 {
                edges.insert((from, target));
            }
            bit = bit.saturating_add(1);
        }
    }
    edges
}

fn assert_all_graphs(count: usize) {
    let labels = keys(count);
    let total = 2_u32.pow(u32::try_from(count.saturating_mul(count)).unwrap_or(0));
    for mask in 0..total {
        let edges = graph_from_mask(count, mask);
        let listed: Vec<(usize, usize)> = edges.iter().copied().collect();
        assert_eq!(
            find_cycles(&labels, &listed),
            oracle(count, &edges),
            "count {count} mask {mask}"
        );
    }
}

#[test]
fn every_graph_up_to_three_vertices_matches_the_oracle() {
    for count in 0..=3 {
        assert_all_graphs(count);
    }
}

#[test]
fn every_graph_of_four_vertices_matches_the_oracle() {
    assert_all_graphs(4);
}
