use super::AwfyRandom;

enum Node {
    Leaf(Vec<i64>),
    Branch(Vec<Node>),
}

fn build(depth: usize, random: &mut AwfyRandom, count: &mut u64) -> Node {
    *count = count.wrapping_add(1);
    if depth == 1 {
        let size =
            usize::try_from(random.draw().checked_rem(10).unwrap_or_default()).unwrap_or_default();
        return Node::Leaf(vec![0; size.wrapping_add(1)]);
    }
    Node::Branch(
        (0..4)
            .map(|_| build(depth.wrapping_sub(1), random, count))
            .collect(),
    )
}

pub fn run(size: usize) -> String {
    let mut random = AwfyRandom::default();
    let mut count = 0_u64;
    let tree = build(size, &mut random, &mut count);
    let width = match &tree {
        Node::Branch(children) => children.len(),
        Node::Leaf(cells) => cells.len(),
    };
    std::hint::black_box(width);
    count.to_string()
}
