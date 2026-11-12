use crate::graph_adjacency::{Adjacency, UNSET, read, write};

pub(crate) struct Components {
    pub assignment: Vec<usize>,
    pub members: Vec<Vec<usize>>,
}

struct Walker<'graph> {
    graph: &'graph Adjacency,
    discovery: Vec<usize>,
    low: Vec<usize>,
    on_stack: Vec<bool>,
    stack: Vec<usize>,
    assignment: Vec<usize>,
    counter: usize,
    components: usize,
}

pub(crate) fn strongly_connected(graph: &Adjacency) -> Components {
    let count = graph.vertex_count();
    let mut walker = Walker {
        graph,
        discovery: vec![UNSET; count],
        low: vec![UNSET; count],
        on_stack: vec![false; count],
        stack: Vec::new(),
        assignment: vec![UNSET; count],
        counter: 0,
        components: 0,
    };
    for root in 0..count {
        if read(&walker.discovery, root) == UNSET {
            walker.visit(root);
        }
    }
    let mut members = vec![Vec::new(); walker.components];
    for (vertex, component) in walker.assignment.iter().enumerate() {
        if let Some(group) = members.get_mut(*component) {
            group.push(vertex);
        }
    }
    Components {
        assignment: walker.assignment,
        members,
    }
}

impl Walker<'_> {
    fn visit(&mut self, root: usize) {
        let mut frames: Vec<(usize, usize)> = Vec::new();
        self.open(root);
        frames.push((root, 0));
        while let Some((vertex, cursor)) = frames.pop() {
            match self.graph.neighbors(vertex).get(cursor).copied() {
                Some(next) => {
                    frames.push((vertex, cursor.saturating_add(1)));
                    self.advance(vertex, next, &mut frames);
                }
                None => {
                    self.close(vertex);
                    if let Some((parent, _)) = frames.last() {
                        self.lower(*parent, read(&self.low, vertex));
                    }
                }
            }
        }
    }

    fn open(&mut self, vertex: usize) {
        write(&mut self.discovery, vertex, self.counter);
        write(&mut self.low, vertex, self.counter);
        self.counter = self.counter.saturating_add(1);
        self.stack.push(vertex);
        if let Some(flag) = self.on_stack.get_mut(vertex) {
            *flag = true;
        }
    }

    fn advance(&mut self, vertex: usize, next: usize, frames: &mut Vec<(usize, usize)>) {
        if read(&self.discovery, next) == UNSET {
            self.open(next);
            frames.push((next, 0));
        } else if self.on_stack.get(next).copied().unwrap_or(false) {
            self.lower(vertex, read(&self.discovery, next));
        }
    }

    fn lower(&mut self, vertex: usize, candidate: usize) {
        let current = read(&self.low, vertex);
        write(&mut self.low, vertex, current.min(candidate));
    }

    fn close(&mut self, vertex: usize) {
        if read(&self.low, vertex) != read(&self.discovery, vertex) {
            return;
        }
        while let Some(member) = self.stack.pop() {
            write(&mut self.assignment, member, self.components);
            if let Some(flag) = self.on_stack.get_mut(member) {
                *flag = false;
            }
            if member == vertex {
                break;
            }
        }
        self.components = self.components.saturating_add(1);
    }
}
