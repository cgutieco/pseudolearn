use pseudolearn_project::find_cycles;

fn keys(count: usize) -> Vec<String> {
    (0..count).map(|index| format!("v{index:05}")).collect()
}

fn chains(count: usize, edges: &[(usize, usize)]) -> Vec<Vec<usize>> {
    find_cycles(&keys(count), edges)
}

#[test]
fn empty_graph_has_no_cycles() {
    assert!(chains(0, &[]).is_empty());
}

#[test]
fn graph_without_edges_has_no_cycles() {
    assert!(chains(5, &[]).is_empty());
}

#[test]
fn self_edge_is_a_cycle_of_one_vertex() {
    assert_eq!(chains(3, &[(1, 1)]), [[1, 1]]);
}

#[test]
fn two_vertices_close_from_the_smaller_key() {
    assert_eq!(chains(2, &[(1, 0), (0, 1)]), [[0, 1, 0]]);
}

#[test]
fn repeated_edges_do_not_change_the_chain() {
    let edges = [(0, 1), (0, 1), (1, 0), (1, 0), (0, 1)];
    assert_eq!(chains(2, &edges), [[0, 1, 0]]);
}

#[test]
fn diamond_is_valid() {
    let edges = [(0, 1), (0, 2), (1, 3), (2, 3)];
    assert!(chains(4, &edges).is_empty());
}

#[test]
fn shortest_cycle_wins_over_longer_ones() {
    let edges = [(0, 2), (2, 3), (3, 0), (0, 1), (1, 0)];
    assert_eq!(chains(4, &edges), [[0, 1, 0]]);
}

#[test]
fn equal_length_cycles_choose_the_smaller_key_sequence() {
    let edges = [(0, 2), (0, 1), (1, 3), (2, 3), (3, 0)];
    assert_eq!(chains(4, &edges), [[0, 1, 3, 0]]);
}

#[test]
fn independent_cycles_are_ordered_by_their_smallest_key() {
    let edges = [(4, 3), (3, 4), (1, 0), (0, 1)];
    assert_eq!(chains(5, &edges), [vec![0, 1, 0], vec![3, 4, 3]]);
}

#[test]
fn cycle_start_is_the_smallest_key_even_when_reached_later() {
    let edges = [(2, 1), (1, 0), (0, 2)];
    assert_eq!(chains(3, &edges), [[0, 2, 1, 0]]);
}

#[test]
fn acyclic_tail_attached_to_a_cycle_is_not_part_of_the_chain() {
    let edges = [(0, 1), (1, 0), (1, 2), (2, 3)];
    assert_eq!(chains(4, &edges), [[0, 1, 0]]);
}

#[test]
fn edges_outside_the_vertex_range_are_ignored() {
    assert!(chains(2, &[(0, 9), (9, 0), (7, 8)]).is_empty());
}

#[test]
fn keys_decide_the_start_not_the_vertex_numbers() {
    let names = ["zeta", "alfa", "beta"];
    let edges = [(0, 1), (1, 2), (2, 0)];
    assert_eq!(find_cycles(&names, &edges), [[1, 2, 0, 1]]);
}

#[test]
fn deep_acyclic_chain_is_accepted_without_exhausting_the_stack() {
    let count = 10_000;
    let edges: Vec<(usize, usize)> = (0..count - 1).map(|index| (index, index + 1)).collect();
    assert!(chains(count, &edges).is_empty());
}

#[test]
fn deep_closed_chain_reports_every_vertex_once() {
    let count = 10_000;
    let edges: Vec<(usize, usize)> = (0..count)
        .map(|index| (index, (index + 1) % count))
        .collect();
    let found = chains(count, &edges);
    assert_eq!(found.len(), 1);
    let chain = found.first().map(Vec::len).unwrap_or(0);
    assert_eq!(chain, count + 1);
}

#[test]
#[ignore = "stress: one million vertices"]
fn million_vertex_chain_and_cycle_terminate() {
    let count = 1_000_000;
    let open: Vec<(usize, usize)> = (0..count - 1).map(|index| (index, index + 1)).collect();
    assert!(chains(count, &open).is_empty());
    let closed: Vec<(usize, usize)> = (0..count)
        .map(|index| (index, (index + 1) % count))
        .collect();
    assert_eq!(chains(count, &closed).len(), 1);
}
