use roxmltree::{Document, Node};

pub fn step_count(source: &str) -> usize {
    let Ok(document) = Document::parse(source) else {
        return 0;
    };
    document
        .descendants()
        .filter_map(|node| step_attribute(node, "data-paso"))
        .max()
        .unwrap_or(0)
}

pub fn step_range(node: Node<'_, '_>) -> Option<(usize, Option<usize>)> {
    let until = step_attribute(node, "data-hasta");
    let from = step_attribute(node, "data-paso");
    if from.is_none() && until.is_none() {
        return None;
    }
    Some((from.unwrap_or(1), until))
}

fn step_attribute(node: Node<'_, '_>, name: &str) -> Option<usize> {
    node.attribute(name)?.parse().ok()
}
