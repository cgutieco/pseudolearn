use crate::ApiUnit;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree};
use serde_json::{Value, json};
use std::collections::BTreeMap;

struct ClassFacts {
    name: String,
    base: Option<String>,
    methods: Vec<String>,
}

pub(crate) fn units(
    schema: &[ApiUnit],
    nodes: &[super::program_view::ViewNode],
    revision: &str,
) -> Value {
    UnitProjection { nodes, revision }.project(schema)
}

struct UnitProjection<'unit> {
    nodes: &'unit [super::program_view::ViewNode],
    revision: &'unit str,
}

impl UnitProjection<'_> {
    fn project(&self, schema: &[ApiUnit]) -> Value {
        Value::Array(
            schema
                .iter()
                .enumerate()
                .map(|(order, unit)| self.unit_value(order, unit))
                .collect(),
        )
    }

    fn unit_value(&self, order: usize, unit: &ApiUnit) -> Value {
        let syntax_kind = match unit.kind.as_str() {
            "algorithm" => "algorithm_unit",
            "class" => "class_unit",
            _ => "subroutine",
        };
        let (node_id, span) = self.node_reference(unit, syntax_kind);
        json!({
            "kind":unit.kind,
            "name":unit.name,
            "order":order,
            "node_id":node_id,
            "span":span
        })
    }

    fn node_reference(&self, unit: &ApiUnit, syntax_kind: &str) -> (Value, Value) {
        let node = self.nodes.iter().enumerate().find(|(_, node)| {
            node.syntax_kind == syntax_kind
                && node.start == (unit.span.start.line, unit.span.start.column)
                && node.end == (unit.span.end.line, unit.span.end.column)
        });
        node.map_or_else(
            || (Value::Null, Value::Null),
            |(index, node)| {
                (
                    json!(format!("{}.n{index:x}", self.revision)),
                    json!({
                        "start_byte": node.start_byte.to_string(),
                        "end_byte": node.end_byte.to_string(),
                        "start": {"line": node.start.0, "column": node.start.1},
                        "end": {"line": node.end.0, "column": node.end.1}
                    }),
                )
            },
        )
    }
}

pub(crate) fn inheritance_and_methods(tree: &SyntaxTree, source: &SourceText) -> (Value, Value) {
    let classes = class_facts(tree, source);
    let by_name: BTreeMap<&str, &ClassFacts> = classes
        .iter()
        .map(|class| (class.name.as_str(), class))
        .collect();
    let inheritance = classes
        .iter()
        .filter_map(|class| {
            class
                .base
                .as_ref()
                .map(|base| json!({"class":class.name,"base":base}))
        })
        .collect();
    let mut methods = Vec::new();
    for class in &classes {
        for method in &class.methods {
            if let Some(owner) = overridden_owner(class, method, &by_name) {
                methods.push(json!({
                    "class": class.name,
                    "name": method,
                    "overrides": format!("{owner}.{method}"),
                }));
            }
        }
    }
    (Value::Array(inheritance), Value::Array(methods))
}

fn overridden_owner(
    class: &ClassFacts,
    method: &str,
    by_name: &BTreeMap<&str, &ClassFacts>,
) -> Option<String> {
    let mut visited = vec![class.name.as_str()];
    let mut current = class.base.as_deref();
    while let Some(name) = current {
        if visited.contains(&name) {
            return None;
        }
        visited.push(name);
        let ancestor = by_name.get(name)?;
        if ancestor.methods.iter().any(|candidate| candidate == method) {
            return Some(ancestor.name.clone());
        }
        current = ancestor.base.as_deref();
    }
    None
}

fn class_facts(tree: &SyntaxTree, source: &SourceText) -> Vec<ClassFacts> {
    let Some(root) = tree.nodes.len().checked_sub(1) else {
        return Vec::new();
    };
    tree.child_indices(root)
        .iter()
        .filter(
            |index| matches!(tree.node(**index), Some(node) if node.kind == NodeKind::ClassUnit),
        )
        .filter_map(|index| facts_of(tree, source, *index))
        .collect()
}

fn facts_of(tree: &SyntaxTree, source: &SourceText, class: usize) -> Option<ClassFacts> {
    let mut names = identifier_children(tree, source, class).into_iter();
    let name = names.next()?;
    let base = names.next();
    let methods = tree
        .child_indices(class)
        .iter()
        .filter(
            |index| matches!(tree.node(**index), Some(node) if node.kind == NodeKind::MethodMember),
        )
        .filter_map(|index| identifier_children(tree, source, *index).into_iter().next())
        .collect();
    Some(ClassFacts {
        name,
        base,
        methods,
    })
}

pub(crate) fn identifier_children(
    tree: &SyntaxTree,
    source: &SourceText,
    parent: usize,
) -> Vec<String> {
    tree.child_indices(parent)
        .iter()
        .filter(
            |index| matches!(tree.node(**index), Some(node) if node.kind == NodeKind::Identifier),
        )
        .filter_map(|index| tree.span_for_node(*index))
        .filter_map(|span| source.slice(span).map(str::to_owned))
        .collect()
}
