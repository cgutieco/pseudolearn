use super::StaticProjection;
use pseudolearn_semantic::interface_model::HirInterface;
use pseudolearn_semantic::{ClassId, HirClass, ServiceAnalysis};
use pseudolearn_source::Span;
use pseudolearn_syntax::NodeKind;
use serde_json::{Value, json};

pub(super) struct ClassRealization<'class> {
    pub(super) class_id: ClassId,
    pub(super) class: &'class HirClass,
    pub(super) class_node_id: &'class str,
}

pub(super) struct ExplicitTarget<'class> {
    pub(super) realization: ClassRealization<'class>,
    pub(super) target: usize,
}

pub(super) struct UnresolvedRealization<'node> {
    pub(super) class_node_id: &'node str,
    pub(super) origin_node_id: &'node str,
    pub(super) target: usize,
    pub(super) target_node_id: &'node str,
}

pub(super) struct ResolvedRealization<'node, 'class> {
    pub(super) class_node_id: &'node str,
    pub(super) class_span: Span,
    pub(super) interface: &'class HirInterface,
    pub(super) target_node_id: &'node str,
}

pub(super) struct AncestorRealizations<'node, 'class> {
    pub(super) class_node_id: &'node str,
    pub(super) descendant_id: ClassId,
    pub(super) ancestor_id: ClassId,
    pub(super) ancestor: &'class HirClass,
    pub(super) seen_interfaces: &'node mut std::collections::BTreeSet<u32>,
    pub(super) rows: &'node mut Vec<Value>,
}

pub(super) struct RealizationValue<'node> {
    pub(super) class_node_id: &'node str,
    pub(super) interface_node_id: Option<&'node str>,
    pub(super) origin_node_id: &'node str,
    pub(super) target_node_id: Option<&'node str>,
    pub(super) origin: &'node str,
    pub(super) diagnostics: Vec<String>,
}

pub(super) fn realization_value(value: RealizationValue<'_>) -> Value {
    json!({
        "class_node_id": value.class_node_id,
        "interface_node_id": value.interface_node_id,
        "origin_node_id": value.origin_node_id,
        "target_node_id": value.target_node_id,
        "origin": value.origin,
        "status": if value.diagnostics.is_empty() { "valid" } else { "invalid" },
        "diagnostics": value.diagnostics,
    })
}

pub(super) fn class_index(analysis: &ServiceAnalysis, class: ClassId) -> Option<&HirClass> {
    analysis.module.classes.get(usize::try_from(class.0).ok()?)
}

pub(super) fn span_contains(owner: Span, target: Span) -> bool {
    owner.source_id == target.source_id
        && owner.start <= target.start
        && owner.ending >= target.ending
}

struct IterationNode {
    ordinal: usize,
    children: Vec<usize>,
    roles: Vec<&'static str>,
    syntax: usize,
}

impl StaticProjection<'_> {
    pub(super) fn attach_constraints(&mut self) {
        let parameters = self
            .nodes
            .iter()
            .enumerate()
            .filter(|(_, node)| node.syntax_kind == "type_parameter")
            .map(|(ordinal, node)| (ordinal, node.start_byte, node.end_byte))
            .collect::<Vec<_>>();
        for (ordinal, start, end) in parameters {
            let entries = self.constraints_for(start, end);
            let Some(node) = self.nodes.get_mut(ordinal) else {
                continue;
            };
            node.attributes.push(("constraints", json!(entries)));
            if let Some(interface) = entries
                .first()
                .and_then(|entry| entry.get("interface_node_id"))
                .filter(|value| !value.is_null())
            {
                node.attributes
                    .push(("constraint_interface", interface.clone()));
            }
        }
    }

    fn constraints_for(&self, start: u32, end: u32) -> Vec<Value> {
        let valid = self
            .analysis
            .module
            .constraints
            .iter()
            .find(|constraint| constraint.span.start == start && constraint.span.ending == end);
        if let Some(constraint) = valid {
            return self.valid_constraint(constraint.interface.0);
        }
        self.unresolved_constraint(start, end)
    }

    fn valid_constraint(&self, interface_id: u32) -> Vec<Value> {
        let Some(interface_index) = usize::try_from(interface_id).ok() else {
            return Vec::new();
        };
        self.analysis
            .module
            .interfaces
            .get(interface_index)
            .and_then(|interface| self.identifiers.get(&interface.syntax))
            .map(|interface| vec![json!({"interface_node_id":interface,"status":"valid"})])
            .unwrap_or_default()
    }

    fn unresolved_constraint(&self, start: u32, end: u32) -> Vec<Value> {
        let Some(parameter) = self.nodes.iter().find(|node| {
            node.syntax_kind == "type_parameter" && node.start_byte == start && node.end_byte == end
        }) else {
            return Vec::new();
        };
        let names = crate::program_view_relations::identifier_children(
            self.context.tree,
            self.context.source,
            parameter.syntax_index,
        );
        if names.len() < 2 {
            return Vec::new();
        }
        let target = self
            .context
            .tree
            .child_indices(parameter.syntax_index)
            .iter()
            .copied()
            .filter(|index| matches!(self.context.tree.node(*index), Some(node) if node.kind == NodeKind::Identifier))
            .nth(1)
            .and_then(|syntax| self.identifiers.get(&syntax));
        vec![json!({
            "interface_node_id": Value::Null,
            "target_node_id": target,
            "status": "invalid",
            "diagnostics": ["unknownInterface"]
        })]
    }

    pub(super) fn attach_iterations(&mut self) {
        let iterations = self
            .nodes
            .iter()
            .enumerate()
            .filter(|(_, node)| node.syntax_kind == "for_each_loop")
            .map(|(ordinal, node)| IterationNode {
                ordinal,
                children: node.children.clone(),
                roles: node.child_roles.clone(),
                syntax: node.syntax_index,
            })
            .collect::<Vec<_>>();
        for iteration in iterations {
            self.attach_iteration(iteration);
        }
    }

    fn attach_iteration(&mut self, iteration: IterationNode) {
        let owner = self.identifiers.get(&iteration.syntax).cloned();
        let collection = related_node(&iteration.children, &iteration.roles, "collection");
        let bindings = related_node(&iteration.children, &iteration.roles, "bindings");
        let body = related_node(&iteration.children, &iteration.roles, "body");
        let relation = json!({
            "collection_node_id": collection.and_then(|index| self.node_identity(index)),
            "bindings_node_id": bindings.and_then(|index| self.node_identity(index)),
            "body_node_id": body.and_then(|index| self.node_identity(index)),
            "scope_owner_node_id": owner,
        });
        if let Some(node) = self.nodes.get_mut(iteration.ordinal) {
            node.attributes.push(("iteration", relation));
        }
        self.attach_scope_owner(bindings, owner);
    }

    fn attach_scope_owner(&mut self, bindings: Option<usize>, owner: Option<String>) {
        if let (Some(binding_index), Some(owner)) = (bindings, owner)
            && let Some(binding) = self.nodes.get_mut(binding_index)
        {
            binding
                .attributes
                .push(("scope_owner_node_id", json!(owner)));
        }
    }

    fn node_identity(&self, ordinal: usize) -> Option<String> {
        self.nodes
            .get(ordinal)
            .and_then(|node| self.identifiers.get(&node.syntax_index))
            .cloned()
    }
}

fn related_node(children: &[usize], roles: &[&str], role: &str) -> Option<usize> {
    children
        .iter()
        .zip(roles)
        .find(|(_, child_role)| **child_role == role)
        .map(|(child, _)| *child)
}
