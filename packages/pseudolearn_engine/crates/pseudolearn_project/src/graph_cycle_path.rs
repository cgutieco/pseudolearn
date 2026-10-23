use crate::graph_adjacency::{Adjacency, UNSET, read, write};
use std::collections::VecDeque;

pub(crate) struct CycleSearch<'graph> {
    graph: &'graph Adjacency,
    assignment: &'graph [usize],
    parent: Vec<usize>,
}

impl<'graph> CycleSearch<'graph> {
    pub(crate) fn new(graph: &'graph Adjacency, assignment: &'graph [usize]) -> Self {
        Self {
            graph,
            assignment,
            parent: vec![UNSET; graph.vertex_count()],
        }
    }

    pub(crate) fn shortest_through(&mut self, start: usize) -> Vec<usize> {
        let component = read(self.assignment, start);
        let mut queue = VecDeque::from([start]);
        write(&mut self.parent, start, start);
        while let Some(vertex) = queue.pop_front() {
            let neighbors = self.graph.neighbors(vertex);
            if neighbors.binary_search(&start).is_ok() {
                return self.close(start, vertex);
            }
            for next in neighbors {
                let same = read(self.assignment, *next) == component;
                if same && read(&self.parent, *next) == UNSET {
                    write(&mut self.parent, *next, vertex);
                    queue.push_back(*next);
                }
            }
        }
        Vec::new()
    }

    fn close(&self, start: usize, last: usize) -> Vec<usize> {
        let mut path = vec![start, last];
        let mut current = last;
        while current != start {
            current = match read(&self.parent, current) {
                UNSET => start,
                parent => parent,
            };
            path.push(current);
        }
        path.reverse();
        path
    }
}
