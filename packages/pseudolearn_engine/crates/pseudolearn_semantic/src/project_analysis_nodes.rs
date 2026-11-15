use crate::session::AnalysisSession;
use pseudolearn_syntax::NodeKind;

pub(crate) fn algorithm_nodes(session: &AnalysisSession<'_>) -> Vec<usize> {
    session
        .tree
        .nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.kind == NodeKind::AlgorithmUnit)
        .map(|(index, _)| index)
        .collect()
}

pub(crate) fn program_node(session: &AnalysisSession<'_>) -> usize {
    session
        .tree
        .nodes
        .iter()
        .rposition(|node| node.kind == NodeKind::Program)
        .unwrap_or(0)
}
