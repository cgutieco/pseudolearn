use crate::graph_adjacency::Adjacency;
use crate::graph_components::strongly_connected;
use crate::graph_cycle_path::CycleSearch;

pub fn find_cycles<Key: Ord>(keys: &[Key], edges: &[(usize, usize)]) -> Vec<Vec<usize>> {
    let order = canonical_order(keys);
    let graph = Adjacency::build(keys.len(), &ranked_edges(&order, edges));
    let components = strongly_connected(&graph);
    let mut search = CycleSearch::new(&graph, &components.assignment);
    let mut starts: Vec<usize> = components
        .members
        .iter()
        .filter(|group| is_cyclic(&graph, group))
        .filter_map(|group| group.first().copied())
        .collect();
    starts.sort_unstable();
    starts
        .into_iter()
        .map(|start| search.shortest_through(start))
        .map(|chain| {
            chain
                .into_iter()
                .filter_map(|vertex| order.get(vertex).copied())
                .collect()
        })
        .collect()
}

fn canonical_order<Key: Ord>(keys: &[Key]) -> Vec<usize> {
    let mut order: Vec<usize> = (0..keys.len()).collect();
    order.sort_by(|first, second| keys.get(*first).cmp(&keys.get(*second)));
    order
}

fn ranked_edges(order: &[usize], edges: &[(usize, usize)]) -> Vec<(usize, usize)> {
    let mut rank = vec![usize::MAX; order.len()];
    for (position, vertex) in order.iter().enumerate() {
        if let Some(slot) = rank.get_mut(*vertex) {
            *slot = position;
        }
    }
    edges
        .iter()
        .filter_map(|(from, target)| Some((*rank.get(*from)?, *rank.get(*target)?)))
        .collect()
}

fn is_cyclic(graph: &Adjacency, group: &[usize]) -> bool {
    match group {
        [only] => graph.has_self_edge(*only),
        [] => false,
        _ => true,
    }
}
