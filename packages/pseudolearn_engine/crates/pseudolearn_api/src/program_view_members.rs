use crate::program_view::ViewNode;
use pseudolearn_lexicon::KeywordKind;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, TokenKind};
use serde_json::{Value, json};

pub(crate) struct MemberProjection<'view> {
    pub(crate) tree: &'view SyntaxTree,
    pub(crate) source: &'view SourceText,
    pub(crate) nodes: &'view [ViewNode],
    pub(crate) revision: &'view str,
}

pub(crate) fn members(projection: MemberProjection<'_>) -> Value {
    projection.members()
}

impl MemberProjection<'_> {
    fn members(&self) -> Value {
        let Some(root) = self.tree.nodes.len().checked_sub(1) else {
            return Value::Array(Vec::new());
        };
        let mut members = Vec::new();
        for class_index in class_indices(self.tree, root) {
            self.append_class_members(class_index, &mut members);
        }
        Value::Array(members)
    }

    fn append_class_members(&self, class_index: usize, members: &mut Vec<Value>) {
        let Some(class_name) = identifier_children(self.tree, self.source, class_index)
            .into_iter()
            .next()
        else {
            return;
        };
        for member_index in self.tree.child_indices(class_index).iter().copied() {
            self.append_member(&class_name, member_index, members);
        }
    }

    fn append_member(&self, class_name: &str, member_index: usize, members: &mut Vec<Value>) {
        let Some(member) = self.tree.node(member_index) else {
            return;
        };
        match member.kind {
            NodeKind::FieldDeclaration => self.append_fields(class_name, member_index, members),
            NodeKind::MethodMember | NodeKind::ConstructorMember => {
                if let Some(value) = self.method_member(class_name, member_index) {
                    members.push(value);
                }
            }
            _ => {}
        }
    }

    fn append_fields(&self, class_name: &str, field_index: usize, members: &mut Vec<Value>) {
        let field_type = member_type(self.tree, self.source, field_index);
        let visibility = member_visibility(self.tree, field_index);
        let node_id = view_identifier(self, field_index);
        for (name, dimensions) in field_members(self.tree, self.source, field_index) {
            members.push(json!({
                "class":class_name,
                "name":name,
                "kind":"field",
                "visibility":visibility,
                "type":field_type,
                "dimensions":dimensions,
                "node_id":node_id
            }));
        }
    }

    fn method_member(&self, class_name: &str, member_index: usize) -> Option<Value> {
        let member = self.tree.node(member_index)?;
        let name = identifier_children(self.tree, self.source, member_index)
            .into_iter()
            .next()?;
        let kind = if member.kind == NodeKind::MethodMember {
            "method"
        } else {
            "constructor"
        };
        Some(json!({
            "class":class_name,
            "name":name,
            "kind":kind,
            "visibility":member_visibility(self.tree, member_index),
            "arity":parameter_count(self.tree, member_index),
            "node_id":view_identifier(self, member_index)
        }))
    }
}

fn class_indices(tree: &SyntaxTree, root: usize) -> Vec<usize> {
    tree.child_indices(root)
        .iter()
        .copied()
        .filter(|index| matches!(tree.node(*index), Some(node) if node.kind == NodeKind::ClassUnit))
        .collect()
}

fn identifier_children(tree: &SyntaxTree, source: &SourceText, index: usize) -> Vec<String> {
    crate::program_view_relations::identifier_children(tree, source, index)
}

fn view_identifier(projection: &MemberProjection<'_>, index: usize) -> Value {
    let Some(span) = projection.tree.span_for_node(index) else {
        return Value::Null;
    };
    let Some(ordinal) = projection
        .nodes
        .iter()
        .position(|node| node.start_byte == span.start && node.end_byte == span.ending)
    else {
        return Value::Null;
    };
    json!(format!("{}.n{ordinal:x}", projection.revision))
}

fn field_members(tree: &SyntaxTree, source: &SourceText, field: usize) -> Vec<(String, usize)> {
    let mut names = Vec::new();
    for child in tree.child_indices(field).iter().copied() {
        match tree.node(child).map(|node| node.kind) {
            Some(NodeKind::Declaration) => names.extend(
                identifier_children(tree, source, child)
                    .into_iter()
                    .map(|name| (name, 0)),
            ),
            Some(NodeKind::DimensionDeclaration) => {
                names.extend(dimensioned_members(tree, source, child));
            }
            _ => {}
        }
    }
    names
}

fn dimensioned_members(
    tree: &SyntaxTree,
    source: &SourceText,
    declaration: usize,
) -> Vec<(String, usize)> {
    tree.child_indices(declaration)
        .iter()
        .copied()
        .filter(
            |index| matches!(tree.node(*index), Some(node) if node.kind == NodeKind::Dimensioned),
        )
        .filter_map(|index| dimensioned_member(tree, source, index))
        .collect()
}

fn dimensioned_member(
    tree: &SyntaxTree,
    source: &SourceText,
    dimension: usize,
) -> Option<(String, usize)> {
    let name = identifier_children(tree, source, dimension)
        .into_iter()
        .next()?;
    let dimensions = tree
        .child_indices(dimension)
        .iter()
        .filter(
            |index| matches!(tree.node(**index), Some(node) if node.kind != NodeKind::Identifier),
        )
        .count();
    Some((name, dimensions))
}

fn member_type(tree: &SyntaxTree, source: &SourceText, member: usize) -> Option<String> {
    let mut pending = vec![member];
    while let Some(index) = pending.pop() {
        if let Some(found) = type_at(tree, source, index) {
            return Some(found);
        }
        pending.extend(tree.child_indices(index).iter().copied());
    }
    None
}

fn type_at(tree: &SyntaxTree, source: &SourceText, index: usize) -> Option<String> {
    if tree.node(index)?.kind != NodeKind::Type {
        return None;
    }
    let span = tree.span_for_node(index)?;
    source.slice(span).map(str::to_owned)
}

fn parameter_count(tree: &SyntaxTree, member: usize) -> usize {
    let Some(parameters) =
        tree.child_indices(member).iter().copied().find(
            |index| matches!(tree.node(*index), Some(node) if node.kind == NodeKind::Parameters),
        )
    else {
        return 0;
    };
    tree.child_indices(parameters)
        .iter()
        .filter(
            |index| matches!(tree.node(**index), Some(node) if node.kind == NodeKind::Parameter),
        )
        .count()
}

fn member_visibility(tree: &SyntaxTree, member: usize) -> &'static str {
    let Some(token) = tree
        .node(member)
        .and_then(|node| usize::try_from(node.first_token).ok())
    else {
        return "public";
    };
    match tree.tokens.kind(token) {
        Some(TokenKind::Keyword(KeywordKind::PrivateVisibility)) => "private",
        _ => "public",
    }
}
