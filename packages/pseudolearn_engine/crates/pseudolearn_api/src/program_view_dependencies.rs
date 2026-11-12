use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_source::{SourceText, Span};
use pseudolearn_syntax::{NodeKind, SyntaxTree};
use serde_json::{Value, json};

pub(crate) fn pending(
    tree: Option<&SyntaxTree>,
    source: &SourceText,
    (revision, source_identity): (&str, Option<crate::ApiSourceIdentity>),
) -> Option<Value> {
    tree.map(|tree| {
        DependencyProjection {
            tree,
            source,
            revision,
            source_identity,
        }
        .project()
    })
}

pub(crate) struct DependencyProjection<'tree> {
    pub(crate) tree: &'tree SyntaxTree,
    pub(crate) source: &'tree SourceText,
    pub(crate) revision: &'tree str,
    pub(crate) source_identity: Option<crate::ApiSourceIdentity>,
}

struct Directive {
    kind: &'static str,
    visibility: &'static str,
    index: usize,
    span: Span,
}

impl DependencyProjection<'_> {
    pub(crate) fn project(&self) -> Value {
        let mut directives: Vec<Directive> = (0..self.tree.node_count())
            .filter_map(|index| self.directive(index))
            .collect();
        directives.sort_by_key(|directive| directive.span.start);
        Value::Array(
            directives
                .iter()
                .enumerate()
                .map(|(order, directive)| self.dependency(order, directive))
                .collect(),
        )
    }

    fn directive(&self, index: usize) -> Option<Directive> {
        let (kind, visibility) = match self.tree.node(index)?.kind {
            NodeKind::ImportDeclaration => ("import", "local"),
            NodeKind::ExportDeclaration => ("export", "exported"),
            _ => return None,
        };
        Some(Directive {
            kind,
            visibility,
            index,
            span: self.tree.span_for_node(index)?,
        })
    }

    fn dependency(&self, order: usize, directive: &Directive) -> Value {
        json!({
            "dependency_id": self.identifier(order),
            "order": order,
            "kind": directive.kind,
            "visibility": directive.visibility,
            "path": self.path_segments(directive.index),
            "alias": self.alias(directive.index),
            "status": "unlinked",
            "diagnostic": DiagnosticCode::ModuleSyntaxOutsideProject.as_str(),
            "span": self.span_value(directive.span),
        })
    }

    fn identifier(&self, order: usize) -> String {
        match self.source_identity {
            Some(source) => format!(
                "p{:x}.r{:x}.f{:x}.d{order:x}",
                source.project_id, source.revision_id, source.source_id
            ),
            None => format!("{}.d{order:x}", self.revision),
        }
    }

    fn path_segments(&self, index: usize) -> Vec<String> {
        let path = self
            .child_of_kind(index, NodeKind::ModulePath)
            .map(|path| self.tree.child_indices(path).to_vec())
            .unwrap_or_default();
        path.into_iter()
            .filter_map(|segment| self.text_of(segment))
            .collect()
    }

    fn alias(&self, index: usize) -> Option<String> {
        let alias = self
            .tree
            .child_indices(index)
            .iter()
            .copied()
            .find(|child| self.kind_of(*child) == Some(NodeKind::Identifier))?;
        self.text_of(alias)
    }

    fn child_of_kind(&self, index: usize, kind: NodeKind) -> Option<usize> {
        self.tree
            .child_indices(index)
            .iter()
            .copied()
            .find(|child| self.kind_of(*child) == Some(kind))
    }

    fn kind_of(&self, index: usize) -> Option<NodeKind> {
        self.tree.node(index).map(|node| node.kind)
    }

    fn text_of(&self, index: usize) -> Option<String> {
        let span = self.tree.span_for_node(index)?;
        self.source.slice(span).map(str::to_owned)
    }

    fn span_value(&self, span: Span) -> Value {
        let mut value = json!({
            "start_byte": span.start.to_string(),
            "end_byte": span.ending.to_string(),
            "start": position(self.source, span.start),
            "end": position(self.source, span.ending),
        });
        if let (Some(source), Some(fields)) = (self.source_identity, value.as_object_mut()) {
            fields.insert("source".to_owned(), json!(source));
        }
        value
    }
}

fn position(source: &SourceText, offset: u32) -> Value {
    let (line, column) = source.line_and_column(offset);
    json!({"line": line, "column": column})
}
