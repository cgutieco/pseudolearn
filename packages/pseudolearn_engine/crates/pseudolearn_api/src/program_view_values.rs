use crate::program_view::ViewNode;
use pseudolearn_semantic::ServiceAnalysis;
use serde_json::json;
use std::collections::BTreeMap;

pub(crate) fn child_role(
    parent: pseudolearn_syntax::NodeKind,
    child: pseudolearn_syntax::NodeKind,
) -> Option<&'static str> {
    use pseudolearn_syntax::NodeKind;
    Some(match (parent, child) {
        (NodeKind::EnumUnit, NodeKind::EnumMembers) => "members",
        (NodeKind::EnumUnit, _) | (NodeKind::RecordUnit, _) if child != NodeKind::RecordField => {
            "name"
        }
        (NodeKind::ForEachLoop, NodeKind::IterationBindings) => "bindings",
        (NodeKind::ForEachLoop, NodeKind::Body) => "body",
        (NodeKind::ForEachLoop, _) => "collection",
        (NodeKind::InterfaceSignature, NodeKind::Parameters) => "parameters",
        (NodeKind::InterfaceSignature, _) => "signature",
        (NodeKind::EnumMembers, _) => "member",
        (NodeKind::RecordUnit, _) => "field",
        _ => return None,
    })
}

pub(crate) fn annotate(
    nodes: &mut [ViewNode],
    analysis: &ServiceAnalysis,
    identifiers: &BTreeMap<usize, String>,
) {
    enumerations(nodes, analysis, identifiers);
    records(nodes, analysis, identifiers);
    captures(nodes, analysis, identifiers);
}

fn enumerations(
    nodes: &mut [ViewNode],
    analysis: &ServiceAnalysis,
    identifiers: &BTreeMap<usize, String>,
) {
    for enumeration in &analysis.module.enums {
        let Some(node) = nodes.iter_mut().find(|node| {
            node.syntax_kind == "enum_unit" && node.start_byte == enumeration.span.start
        }) else {
            continue;
        };
        if let Some(identity) = identifiers.get(&node.syntax_index) {
            node.attributes.push(("enum_identity", json!(identity)));
        }
        node.attributes
            .push(("enum_members", json!(enumeration.members)));
    }
}

fn records(
    nodes: &mut [ViewNode],
    analysis: &ServiceAnalysis,
    identifiers: &BTreeMap<usize, String>,
) {
    for record in &analysis.module.records {
        let Some(owner) = nodes
            .iter()
            .find(|node| node.syntax_index == record.syntax)
            .map(|node| (node.start_byte, node.end_byte))
        else {
            continue;
        };
        let fields = nodes
            .iter()
            .filter(|node| {
                node.syntax_kind == "record_field"
                    && node.start_byte >= owner.0
                    && node.end_byte <= owner.1
            })
            .filter_map(|node| identifiers.get(&node.syntax_index))
            .cloned()
            .collect::<Vec<_>>();
        if let Some(node) = nodes
            .iter_mut()
            .find(|node| node.syntax_index == record.syntax)
        {
            if let Some(identity) = identifiers.get(&node.syntax_index) {
                node.attributes.push(("record_identity", json!(identity)));
            }
            node.attributes.push(("record_fields", json!(fields)));
        }
    }
}

fn captures(
    nodes: &mut [ViewNode],
    analysis: &ServiceAnalysis,
    identifiers: &BTreeMap<usize, String>,
) {
    for (function, closure) in &analysis.module.closures {
        let Some(syntax) = usize::try_from(function.0)
            .ok()
            .and_then(|slot| analysis.module.functions.get(slot))
            .map(|function| function.syntax)
        else {
            continue;
        };
        let captured = closure
            .captures
            .iter()
            .filter_map(|(original, _)| {
                let local = analysis
                    .module
                    .locals
                    .get(usize::try_from(original.0).ok()?)?;
                declaration_identity(nodes, local.span.start, local.span.ending, identifiers)
            })
            .collect::<Vec<_>>();
        if let Some(node) = nodes.iter_mut().find(|node| node.syntax_index == syntax) {
            if let Some(identity) = identifiers.get(&syntax) {
                node.attributes.push(("closure_identity", json!(identity)));
            }
            node.attributes.push(("captured_bindings", json!(captured)));
        }
    }
}

fn declaration_identity(
    nodes: &[ViewNode],
    start: u32,
    ending: u32,
    identifiers: &BTreeMap<usize, String>,
) -> Option<String> {
    nodes
        .iter()
        .filter(|node| {
            matches!(node.syntax_kind, "declaration" | "parameter")
                && node.start_byte <= start
                && node.end_byte >= ending
        })
        .min_by_key(|node| node.end_byte.saturating_sub(node.start_byte))
        .and_then(|node| identifiers.get(&node.syntax_index).cloned())
}
