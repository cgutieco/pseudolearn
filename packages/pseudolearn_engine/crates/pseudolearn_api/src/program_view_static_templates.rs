use super::StaticProjection;
use super::details::{RealizationValue, UnresolvedRealization, realization_value};
use pseudolearn_semantic::template_model::{HirTemplate, TemplateKind};
use pseudolearn_syntax::NodeKind;
use serde_json::Value;

impl StaticProjection<'_> {
    pub(super) fn append_template_realizations(&self, rows: &mut Vec<Value>) {
        for template in &self.analysis.module.templates {
            if template.kind != TemplateKind::Class {
                continue;
            }
            let Some(class_syntax) = self.syntax_at(NodeKind::ClassUnit, template) else {
                continue;
            };
            let Some(class_node_id) = self.identifiers.get(&class_syntax) else {
                continue;
            };
            if rows.iter().any(|row| {
                row.get("class_node_id").and_then(Value::as_str) == Some(class_node_id.as_str())
            }) {
                continue;
            }
            for target in self.realization_targets(class_syntax) {
                self.append_template_target(class_node_id, target, rows);
            }
        }
    }

    fn realization_targets(&self, class_syntax: usize) -> Vec<usize> {
        let tree = self.context.tree;
        tree.child_indices(class_syntax)
            .iter()
            .filter(|child| matches!(tree.node(**child), Some(node) if node.kind == NodeKind::Realization))
            .flat_map(|realization| tree.child_indices(*realization).iter().copied())
            .filter(|target| matches!(tree.node(*target), Some(node) if node.kind == NodeKind::Identifier))
            .collect()
    }

    fn append_template_target(&self, class_node_id: &str, target: usize, rows: &mut Vec<Value>) {
        let Some(target_node_id) = self.identifiers.get(&target) else {
            return;
        };
        let name = self
            .context
            .tree
            .span_for_node(target)
            .and_then(|span| self.context.source.slice(span));
        let Some(interface_node_id) = name.and_then(|name| self.interface_node(name)) else {
            rows.push(self.unresolved_realization(UnresolvedRealization {
                class_node_id,
                origin_node_id: class_node_id,
                target,
                target_node_id,
            }));
            return;
        };
        rows.push(realization_value(RealizationValue {
            class_node_id,
            interface_node_id: Some(interface_node_id),
            origin_node_id: class_node_id,
            target_node_id: Some(target_node_id),
            origin: "explicit",
            diagnostics: Vec::new(),
        }));
    }

    fn interface_node(&self, name: &str) -> Option<&str> {
        let templated = self
            .analysis
            .module
            .templates
            .iter()
            .filter(|template| template.kind == TemplateKind::Interface && template.name == name)
            .find_map(|template| self.syntax_at(NodeKind::InterfaceUnit, template));
        let syntax = templated.or_else(|| {
            self.analysis
                .module
                .interfaces
                .iter()
                .find(|interface| interface.name == name)
                .map(|interface| interface.syntax)
        })?;
        self.identifiers.get(&syntax).map(String::as_str)
    }

    fn syntax_at(&self, kind: NodeKind, template: &HirTemplate) -> Option<usize> {
        let tree = self.context.tree;
        self.nodes
            .iter()
            .filter(|node| node.start_byte == template.span.start)
            .map(|node| node.syntax_index)
            .find(|syntax| matches!(tree.node(*syntax), Some(node) if node.kind == kind))
    }
}
