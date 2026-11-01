use crate::program_view::ViewNode;
use crate::program_view_annotations::AnnotationContext;
use details::{
    AncestorRealizations, ClassRealization, ExplicitTarget, RealizationValue, ResolvedRealization,
    UnresolvedRealization,
};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_semantic::interface_model::HirInterface;
use pseudolearn_semantic::{ClassId, ServiceAnalysis};
use pseudolearn_source::Span;
use pseudolearn_syntax::NodeKind;
use serde_json::{Value, json};
use std::collections::{BTreeMap, BTreeSet};

#[path = "program_view_static_details.rs"]
mod details;

pub(crate) struct StaticProjection<'view> {
    pub(crate) nodes: &'view mut [ViewNode],
    pub(crate) context: &'view AnnotationContext<'view>,
    pub(crate) analysis: &'view ServiceAnalysis,
    pub(crate) identifiers: &'view BTreeMap<usize, String>,
}

impl StaticProjection<'_> {
    pub(crate) fn project(mut self) -> Value {
        let realizations = self.realization_rows();
        self.attach_realizations(&realizations);
        self.attach_constraints();
        self.attach_iterations();
        Value::Array(realizations)
    }

    fn realization_rows(&self) -> Vec<Value> {
        let mut rows = Vec::new();
        for (index, class) in self.analysis.module.classes.iter().enumerate() {
            let Some(class_id) = u32::try_from(index).ok().map(ClassId) else {
                continue;
            };
            let Some(class_node_id) = self.identifiers.get(&class.syntax) else {
                continue;
            };
            self.append_explicit(
                ClassRealization {
                    class_id,
                    class,
                    class_node_id,
                },
                &mut rows,
            );
            self.append_inherited(class_id, class_node_id, &mut rows);
        }
        rows
    }

    fn append_explicit(&self, realization: ClassRealization<'_>, rows: &mut Vec<Value>) {
        for realization_index in self.context.tree.child_indices(realization.class.syntax) {
            if !matches!(self.context.tree.node(*realization_index), Some(node) if node.kind == NodeKind::Realization)
            {
                continue;
            }
            for target in self.context.tree.child_indices(*realization_index) {
                self.append_explicit_target(
                    ExplicitTarget {
                        realization: ClassRealization {
                            class_id: realization.class_id,
                            class: realization.class,
                            class_node_id: realization.class_node_id,
                        },
                        target: *target,
                    },
                    rows,
                );
            }
        }
    }

    fn append_explicit_target(&self, target: ExplicitTarget<'_>, rows: &mut Vec<Value>) {
        let class_id = target.realization.class_id;
        let class = target.realization.class;
        let class_node_id = target.realization.class_node_id;
        let target_syntax = target.target;
        if !matches!(self.context.tree.node(target_syntax), Some(node) if node.kind == NodeKind::Identifier)
        {
            return;
        }
        let target_node_id = self.identifiers.get(&target_syntax);
        let target_name = self
            .context
            .tree
            .span_for_node(target_syntax)
            .and_then(|span| self.context.source.slice(span));
        let interface = target_name.and_then(|name| self.interface_for(class_id, name));
        let Some(target_node_id) = target_node_id else {
            return;
        };
        let Some(interface) = interface else {
            rows.push(self.unresolved_realization(UnresolvedRealization {
                class_node_id,
                origin_node_id: class_node_id,
                target: target_syntax,
                target_node_id,
            }));
            return;
        };
        self.append_resolved_realization(
            ResolvedRealization {
                class_node_id,
                class_span: class.span,
                interface,
                target_node_id,
            },
            rows,
        );
    }

    fn append_resolved_realization(
        &self,
        target: ResolvedRealization<'_, '_>,
        rows: &mut Vec<Value>,
    ) {
        let Some(interface_node_id) = self.identifiers.get(&target.interface.syntax) else {
            return;
        };
        let diagnostics = self.interface_diagnostics(target.class_span, target.interface);
        rows.push(details::realization_value(RealizationValue {
            class_node_id: target.class_node_id,
            interface_node_id: Some(interface_node_id),
            origin_node_id: target.class_node_id,
            target_node_id: Some(target.target_node_id),
            origin: "explicit",
            diagnostics,
        }));
    }

    fn unresolved_realization(&self, target: UnresolvedRealization<'_>) -> Value {
        let mut diagnostic_codes = self
            .context
            .tree
            .span_for_node(target.target)
            .map(|span| self.unknown_interface_diagnostics(span))
            .unwrap_or_default();
        if diagnostic_codes.is_empty() {
            diagnostic_codes.push(DiagnosticCode::UnknownInterface.as_str().to_owned());
        }
        details::realization_value(RealizationValue {
            class_node_id: target.class_node_id,
            interface_node_id: None,
            origin_node_id: target.origin_node_id,
            target_node_id: Some(target.target_node_id),
            origin: "explicit",
            diagnostics: diagnostic_codes,
        })
    }

    fn append_inherited(&self, class_id: ClassId, class_node_id: &str, rows: &mut Vec<Value>) {
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
        let diagnostics = self.interface_diagnostics(projection.ancestor.span, interface);
        projection
            .rows
            .push(details::realization_value(RealizationValue {
                class_node_id: projection.class_node_id,
                interface_node_id: Some(interface_node_id),
                origin_node_id,
                target_node_id: Some(interface_node_id),
                origin: "inherited",
                diagnostics,
            }));
    }

    fn interface_for(&self, class: ClassId, name: &str) -> Option<&HirInterface> {
        let unit = self.analysis.module.units.class_unit(class);
        self.analysis
            .module
            .interfaces
            .iter()
            .find(|interface| interface.unit == unit && interface.name == name)
    }

    fn interface_diagnostics(&self, class: Span, interface: &HirInterface) -> Vec<String> {
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
                    && diagnostic
                        .related
                        .iter()
                        .any(|related| details::span_contains(interface.span, *related))
            })
            .map(|diagnostic| diagnostic.code.as_str().to_owned())
            .collect()
    }

    fn unknown_interface_diagnostics(&self, target: Span) -> Vec<String> {
        self.analysis
            .diagnostics
            .iter()
            .filter(|diagnostic| {
                diagnostic.code == DiagnosticCode::UnknownInterface
                    && diagnostic.span.start == target.start
                    && diagnostic.span.ending == target.ending
            })
            .map(|diagnostic| diagnostic.code.as_str().to_owned())
            .collect()
    }

    fn attach_realizations(&mut self, realizations: &[Value]) {
        for node in self.nodes.iter_mut() {
            if node.syntax_kind != "class_unit" {
                continue;
            }
            let Some(class_node_id) = self.identifiers.get(&node.syntax_index) else {
                continue;
            };
            let entries = realizations
                .iter()
                .filter(|entry| {
                    entry.get("class_node_id").and_then(Value::as_str) == Some(class_node_id)
                })
                .cloned()
                .collect::<Vec<_>>();
            node.attributes
                .push(("interface_realizations", json!(entries)));
        }
    }
}
