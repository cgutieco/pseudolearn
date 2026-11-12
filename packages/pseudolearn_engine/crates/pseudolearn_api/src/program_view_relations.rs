use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree};
use serde_json::{Value, json};
use std::collections::BTreeMap;

struct ClassFacts {
    name: String,
    syntax: usize,
    base: Option<String>,
    methods: Vec<MethodFacts>,
}

struct MethodFacts {
    name: String,
    syntax: usize,
}

struct MethodOverride<'facts> {
    class: &'facts ClassFacts,
    method: &'facts MethodFacts,
    owner: &'facts ClassFacts,
    overridden: &'facts MethodFacts,
}

pub(crate) struct RelationProjection<'view> {
    pub(crate) tree: &'view SyntaxTree,
    pub(crate) source: &'view SourceText,
    pub(crate) nodes: &'view [crate::program_view::ViewNode],
    pub(crate) revision: &'view str,
    pub(crate) source_identity: Option<crate::ApiSourceIdentity>,
}

impl RelationProjection<'_> {
    pub(crate) fn project(&self) -> (Value, Value) {
        let classes = class_facts(self.tree, self.source);
        let by_name: BTreeMap<&str, &ClassFacts> = classes
            .iter()
            .map(|class| (class.name.as_str(), class))
            .collect();
        let inheritance = self.inheritance_rows(&classes, &by_name);
        let methods = self.method_rows(&classes, &by_name);
        (Value::Array(inheritance), Value::Array(methods))
    }

    fn inheritance_rows(
        &self,
        classes: &[ClassFacts],
        by_name: &BTreeMap<&str, &ClassFacts>,
    ) -> Vec<Value> {
        classes
            .iter()
            .filter_map(|class| self.inheritance_relation(class, by_name))
            .collect()
    }

    fn inheritance_relation(
        &self,
        class: &ClassFacts,
        by_name: &BTreeMap<&str, &ClassFacts>,
    ) -> Option<Value> {
        let base = class.base.as_ref()?;
        let mut relation = json!({"class":class.name,"base":base});
        if let Some(fields) = relation.as_object_mut() {
            if let Some(identity) = self.identity_for(class.syntax) {
                fields.insert("class_node_id".to_owned(), json!(identity));
            }
            if let Some(owner) = by_name.get(base.as_str())
                && let Some(identity) = self.identity_for(owner.syntax)
            {
                fields.insert("base_node_id".to_owned(), json!(identity));
            }
        }
        Some(relation)
    }

    fn method_rows(
        &self,
        classes: &[ClassFacts],
        by_name: &BTreeMap<&str, &ClassFacts>,
    ) -> Vec<Value> {
        classes
            .iter()
            .flat_map(|class| {
                class.methods.iter().filter_map(|method| {
                    let (owner, overridden) = overridden_method(class, method, by_name)?;
                    Some(self.method_relation(MethodOverride {
                        class,
                        method,
                        owner,
                        overridden,
                    }))
                })
            })
            .collect()
    }

    fn method_relation(&self, relation: MethodOverride<'_>) -> Value {
        let mut value = json!({
            "class":relation.class.name,
            "name":relation.method.name,
            "overrides":format!("{}.{}", relation.owner.name, relation.overridden.name),
        });
        if let Some(fields) = value.as_object_mut() {
            self.insert_identity(fields, "class_node_id", relation.class.syntax);
            self.insert_identity(fields, "method_node_id", relation.method.syntax);
            self.insert_identity(
                fields,
                "overridden_method_node_id",
                relation.overridden.syntax,
            );
        }
        value
    }

    fn identity_for(&self, syntax: usize) -> Option<String> {
        let ordinal = self
            .nodes
            .iter()
            .position(|node| node.syntax_index == syntax)?;
        Some(crate::program_view::node_identifier(
            self.revision,
            self.source_identity,
            ordinal,
        ))
    }

    fn insert_identity(
        &self,
        fields: &mut serde_json::Map<String, Value>,
        name: &str,
        syntax: usize,
    ) {
        if let Some(identity) = self.identity_for(syntax) {
            fields.insert(name.to_owned(), json!(identity));
        }
    }
}

fn overridden_method<'class>(
    class: &'class ClassFacts,
    method: &MethodFacts,
    by_name: &'class BTreeMap<&str, &'class ClassFacts>,
) -> Option<(&'class ClassFacts, &'class MethodFacts)> {
    let mut visited = vec![class.name.as_str()];
    let mut current = class.base.as_deref();
    while let Some(name) = current {
        if visited.contains(&name) {
            return None;
        }
        visited.push(name);
        let ancestor = by_name.get(name)?;
        if let Some(overridden) = ancestor
            .methods
            .iter()
            .find(|candidate| candidate.name == method.name)
        {
            return Some((ancestor, overridden));
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
        .filter_map(|index| {
            Some(MethodFacts {
                name: identifier_children(tree, source, *index)
                    .into_iter()
                    .next()?,
                syntax: *index,
            })
        })
        .collect();
    Some(ClassFacts {
        name,
        syntax: class,
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
