use crate::program_view::ViewNode;
use crate::program_view_annotations::AnnotationContext;
use pseudolearn_semantic::{SemanticOptions, analyze_for_service};
use serde_json::json;

pub(crate) fn annotate(nodes: &mut [ViewNode], context: &AnnotationContext<'_>, revision: &str) {
    let analysis = analyze_for_service(
        context.tree,
        context.source,
        SemanticOptions {
            profile: context.profile,
            strict: context.strict,
        },
    );
    let identifiers: std::collections::BTreeMap<_, _> = nodes
        .iter()
        .enumerate()
        .map(|(ordinal, node)| (node.syntax_index, identifier(node, revision, ordinal)))
        .collect();
    let interfaces: std::collections::BTreeMap<_, _> = analysis
        .module
        .interfaces
        .iter()
        .enumerate()
        .filter_map(|(ordinal, interface)| {
            Some((
                u32::try_from(ordinal).ok()?,
                identifiers.get(&interface.syntax)?.clone(),
            ))
        })
        .collect();
    interface_nodes(nodes, &analysis, &identifiers);
    realizations(nodes, &analysis, &interfaces);
    constraints(nodes, &analysis, &interfaces);
}

fn identifier(node: &ViewNode, revision: &str, ordinal: usize) -> String {
    match node.source {
        Some(source) => format!(
            "p{:x}.r{:x}.f{:x}.n{ordinal:x}",
            source.project_id, source.revision_id, source.source_id
        ),
        None => format!("{revision}.n{ordinal:x}"),
    }
}

pub(crate) fn child_role(
    tree: &pseudolearn_syntax::SyntaxTree,
    parent: usize,
    child: usize,
) -> Option<&'static str> {
    use pseudolearn_syntax::NodeKind;
    let parent_node = tree.node(parent)?;
    let child_node = tree.node(child)?;
    Some(match parent_node.kind {
        NodeKind::InterfaceUnit => {
            if child_node.kind == NodeKind::InterfaceSignature {
                "method_signature"
            } else {
                "name"
            }
        }
        NodeKind::Realization => "interface",
        NodeKind::TypeParameters => "type_parameter",
        NodeKind::TypeParameter => {
            if child == *tree.child_indices(parent).first().unwrap_or(&usize::MAX) {
                "name"
            } else {
                "constraint"
            }
        }
        NodeKind::TypeArguments => "type_argument",
        NodeKind::IterationBindings => "binding",
        NodeKind::ForEachLoop => match child_node.kind {
            NodeKind::IterationBindings => "bindings",
            NodeKind::Body => "body",
            _ => "collection",
        },
        NodeKind::DeferStatement => "cleanup_body",
        NodeKind::InterfaceSignature => match child_node.kind {
            NodeKind::Parameters => "parameters",
            _ => "signature",
        },
        _ => return None,
    })
}

fn realizations(
    nodes: &mut [ViewNode],
    analysis: &pseudolearn_semantic::ServiceAnalysis,
    interfaces: &std::collections::BTreeMap<u32, String>,
) {
    for (class, realized) in &analysis.module.realizations {
        let Some(model) = usize::try_from(class.0)
            .ok()
            .and_then(|slot| analysis.module.classes.get(slot))
        else {
            continue;
        };
        if let Some(node) = nodes
            .iter_mut()
            .find(|node| node.syntax_kind == "class_unit" && node.start_byte == model.span.start)
        {
            node.attributes.push((
                "realized_interfaces",
                json!(
                    realized
                        .iter()
                        .filter_map(|interface| interfaces.get(&interface.0))
                        .collect::<Vec<_>>()
                ),
            ));
        }
    }
}

fn interface_nodes(
    nodes: &mut [ViewNode],
    analysis: &pseudolearn_semantic::ServiceAnalysis,
    identifiers: &std::collections::BTreeMap<usize, String>,
) {
    for interface in &analysis.module.interfaces {
        if let Some(node) = nodes
            .iter_mut()
            .find(|node| node.syntax_index == interface.syntax)
            && let Some(identity) = identifiers.get(&interface.syntax)
        {
            node.attributes
                .push(("interface_identity", json!(identity)));
        }
    }
}

fn constraints(
    nodes: &mut [ViewNode],
    analysis: &pseudolearn_semantic::ServiceAnalysis,
    interfaces: &std::collections::BTreeMap<u32, String>,
) {
    for constraint in &analysis.module.constraints {
        if let Some(node) = nodes.iter_mut().find(|node| {
            node.syntax_kind == "type_parameter"
                && node.start_byte <= constraint.span.start
                && node.end_byte >= constraint.span.ending
        }) && let Some(identity) = interfaces.get(&constraint.interface.0)
        {
            node.attributes
                .push(("constraint_interface", json!(identity)));
        }
    }
}
