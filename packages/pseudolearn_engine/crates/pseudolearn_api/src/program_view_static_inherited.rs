use super::StaticProjection;
use super::details::{self, AncestorRealizations, RealizationValue};
use crate::program_view::ViewNode;
use pseudolearn_diagnostics::{Diagnostic, DiagnosticCode};
use pseudolearn_semantic::interface_model::HirInterface;
use pseudolearn_semantic::{ClassId, HirClass};
use pseudolearn_source::Span;
use pseudolearn_syntax::NodeKind;
use serde_json::{Value, json};
use std::collections::BTreeSet;

pub(super) fn attach_method_signature_spans(projection: &mut StaticProjection<'_>) {
    let signatures = projection
        .analysis
        .diagnostics
        .iter()
        .filter(|diagnostic| {
            diagnostic.code == DiagnosticCode::IncompatibleMethodOverride
                && !diagnostic.related.is_empty()
        })
        .filter_map(|diagnostic| {
            let node = projection.method_node_for_span(diagnostic.span)?;
            Some((
                node.syntax_index,
                projection.method_signature_span(node.syntax_index)?,
            ))
        })
        .collect::<Vec<_>>();
    for (syntax_index, signature) in signatures {
        let Some(node) = projection
            .nodes
            .iter_mut()
            .find(|node| node.syntax_index == syntax_index && node.syntax_kind == "method_member")
        else {
            continue;
        };
        if node
            .attributes
            .iter()
            .all(|(name, _)| *name != "method_signature_span")
        {
            node.attributes.push(("method_signature_span", signature));
        }
    }
}

impl StaticProjection<'_> {
    pub(super) fn append_inherited(
        &self,
        class_id: ClassId,
        class_node_id: &str,
        rows: &mut Vec<Value>,
    ) {
        let Some(class) = details::class_index(self.analysis, class_id) else {
            return;
        };
        let mut current = class.superclass;
        let mut visited = vec![class_id];
        let mut seen_interfaces = BTreeSet::new();
        while let Some(ancestor_id) = current {
            if visited.contains(&ancestor_id) {
                break;
            }
            visited.push(ancestor_id);
            let Some(ancestor) = details::class_index(self.analysis, ancestor_id) else {
                break;
            };
            self.append_ancestor_realizations(AncestorRealizations {
                class_node_id,
                descendant_id: class_id,
                ancestor_id,
                ancestor,
                seen_interfaces: &mut seen_interfaces,
                rows,
            });
            current = ancestor.superclass;
        }
    }

    fn append_ancestor_realizations(&self, mut projection: AncestorRealizations<'_, '_>) {
        let Some(origin_node_id) = self.identifiers.get(&projection.ancestor.syntax) else {
            return;
        };
        for interface_id in self
            .analysis
            .module
            .realizations
            .get(&projection.ancestor_id)
            .into_iter()
            .flatten()
        {
            self.append_ancestor_interface(&mut projection, origin_node_id, interface_id.0);
        }
    }

    fn append_ancestor_interface(
        &self,
        projection: &mut AncestorRealizations<'_, '_>,
        origin_node_id: &str,
        interface_id: u32,
    ) {
        if !projection.seen_interfaces.insert(interface_id) {
            return;
        }
        let Some(interface_index) = usize::try_from(interface_id).ok() else {
            return;
        };
        let Some(interface) = self.analysis.module.interfaces.get(interface_index) else {
            return;
        };
        let Some(interface_node_id) = self.identifiers.get(&interface.syntax) else {
            return;
        };
        let mut diagnostics = self.interface_diagnostics(projection.ancestor.span, interface);
        let override_diagnostics =
            self.override_diagnostics(projection.descendant_id, projection.ancestor_id, interface);
        let diagnostic_origin = override_diagnostics
            .first()
            .map(|(_, node_id)| node_id.as_str())
            .unwrap_or(origin_node_id)
            .to_owned();
        diagnostics.extend(override_diagnostics.into_iter().map(|(code, _)| code));
        projection
            .rows
            .push(details::realization_value(RealizationValue {
                class_node_id: projection.class_node_id,
                interface_node_id: Some(interface_node_id),
                origin_node_id: &diagnostic_origin,
                target_node_id: Some(interface_node_id),
                origin: "inherited",
                diagnostics,
            }));
    }

    pub(super) fn interface_diagnostics(
        &self,
        class: Span,
        interface: &HirInterface,
    ) -> Vec<String> {
        self.analysis
            .diagnostics
            .iter()
            .filter(|diagnostic| {
                matches!(
                    diagnostic.code,
                    DiagnosticCode::InterfaceMethodMissing
                        | DiagnosticCode::InterfaceMethodNotPublic
                        | DiagnosticCode::InterfaceMethodSignatureMismatch
                ) && details::span_contains(class, diagnostic.span)
                    && related_to_interface(diagnostic, interface)
            })
            .map(|diagnostic| diagnostic.code.as_str().to_owned())
            .collect()
    }

    fn override_diagnostics(
        &self,
        descendant: ClassId,
        ancestor: ClassId,
        interface: &HirInterface,
    ) -> Vec<(String, String)> {
        let mut matches = Vec::new();
        let mut visited = Vec::new();
        let mut current = Some(descendant);
        while let Some(class_id) = current {
            if class_id == ancestor || visited.contains(&class_id) {
                break;
            }
            visited.push(class_id);
            let Some(class) = details::class_index(self.analysis, class_id) else {
                break;
            };
            self.append_class_override_diagnostics(class, interface, &mut matches);
            current = class.superclass;
        }
        matches
    }

    fn append_class_override_diagnostics(
        &self,
        class: &HirClass,
        interface: &HirInterface,
        matches: &mut Vec<(String, String)>,
    ) {
        for diagnostic in self.analysis.diagnostics.iter().filter(|diagnostic| {
            diagnostic.code == DiagnosticCode::IncompatibleMethodOverride
                && details::span_contains(class.span, diagnostic.span)
                && related_to_interface(diagnostic, interface)
        }) {
            let Some(node) = self.method_node_for_span(diagnostic.span) else {
                continue;
            };
            let Some(node_id) = self.identifiers.get(&node.syntax_index) else {
                continue;
            };
            matches.push((diagnostic.code.as_str().to_owned(), node_id.clone()));
        }
    }

    fn method_node_for_span(&self, span: Span) -> Option<&ViewNode> {
        if span.source_id != pseudolearn_source::source_id(self.context.source) {
            return None;
        }
        self.nodes.iter().find(|node| {
            node.syntax_kind == "method_member"
                && node.start_byte == span.start
                && node.end_byte == span.ending
        })
    }

    fn method_signature_span(&self, syntax_index: usize) -> Option<Value> {
        let method_span = self.context.tree.span_for_node(syntax_index)?;
        let last_signature_node = self
            .context
            .tree
            .child_indices(syntax_index)
            .iter()
            .rev()
            .copied()
            .find(|child| {
                self.context
                    .tree
                    .node(*child)
                    .is_some_and(|node| node.kind != NodeKind::Body)
            })?;
        let signature_span = self.context.tree.span_for_node(last_signature_node)?;
        if method_span.start > signature_span.ending {
            return None;
        }
        let start = self.context.source.line_and_column(method_span.start);
        let end = self.context.source.line_and_column(signature_span.ending);
        Some(json!({
            "start_byte": method_span.start.to_string(),
            "end_byte": signature_span.ending.to_string(),
            "start": {"line": start.0, "column": start.1},
            "end": {"line": end.0, "column": end.1}
        }))
    }
}

fn related_to_interface(diagnostic: &Diagnostic, interface: &HirInterface) -> bool {
    diagnostic
        .related
        .iter()
        .any(|related| details::span_contains(interface.span, *related))
}
