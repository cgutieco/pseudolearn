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

pub(crate) fn units(schema: &[ApiUnit]) -> Value {
    Value::Array(
        schema
            .iter()
            .enumerate()
            .map(|(order, unit)| json!({"kind":unit.kind,"name":unit.name,"order":order}))
            .collect(),
    )
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

fn identifier_children(tree: &SyntaxTree, source: &SourceText, parent: usize) -> Vec<String> {
    tree.child_indices(parent)
        .iter()
        .filter(
            |index| matches!(tree.node(**index), Some(node) if node.kind == NodeKind::Identifier),
        )
        .filter_map(|index| tree.span_for_node(*index))
        .filter_map(|span| source.slice(span).map(str::to_owned))
        .collect()
}
