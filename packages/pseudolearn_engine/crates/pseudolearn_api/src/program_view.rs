use crate::program_view_annotations::AnnotationContext;
use crate::program_view_kind::ViewKind;
use crate::{AnalyzeRequest, ApiError};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source_with_terminator;
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) type Position = (u32, u32);
pub(crate) type SpanKey = (Position, Position);

pub(crate) struct ViewNode {
    pub(crate) syntax_index: usize,
    pub(crate) kind: ViewKind,
    pub(crate) syntax_kind: &'static str,
    pub(crate) start_byte: u32,
    pub(crate) end_byte: u32,
    pub(crate) start: Position,
    pub(crate) end: Position,
    pub(crate) parent: Option<usize>,
    pub(crate) children: Vec<usize>,
    pub(crate) child_roles: Vec<&'static str>,
    pub(crate) dimensions: Option<usize>,
    pub(crate) attributes: crate::program_view_annotations::Attributes,
}

pub(crate) struct ProgramView {
    revision: String,
    nodes: Vec<ViewNode>,
    by_span: BTreeMap<SpanKey, Vec<usize>>,
    units: Value,
    inheritance: Value,
    methods: Value,
    members: Value,
}

impl ProgramView {
    pub(crate) fn build(request: &AnalyzeRequest, revision: String) -> Result<Self, ApiError> {
        let profile = Profile::from_name(&request.profile).unwrap_or(Profile::Spanish);
        let strict = request.strictness != "flexible";
        let source = SourceText::new(request.program.clone());
        let terminator = strict.then_some(DiagnosticCode::MissingStatementTerminator);
        let (tree, _) = parse_source_with_terminator(&source, profile, terminator);
        if tree.has_errors {
            return Err(crate::execution_resource::usage("analysis has errors"));
        }
        let mut nodes = crate::program_view_tree::collect_nodes(&tree, &source);
        let context = AnnotationContext {
            tree: &tree,
            source: &source,
            profile,
            strict,
        };
        crate::program_view_annotations::annotate(&mut nodes, &context);
        let by_span = index_by_span(&nodes);
        let schema = crate::diagnostic_conversion::schema(&tree, &source);
        let (inheritance, methods) =
            crate::program_view_relations::inheritance_and_methods(&tree, &source);
        let units = crate::program_view_relations::units(&schema, &nodes, &revision);
        let members =
            crate::program_view_members::members(crate::program_view_members::MemberProjection {
                tree: &tree,
                source: &source,
                nodes: &nodes,
                revision: &revision,
            });
        Ok(Self {
            revision,
            nodes,
            by_span,
            units,
            inheritance,
            methods,
            members,
        })
    }

    pub(crate) fn revision(&self) -> &str {
        &self.revision
    }

    pub(crate) fn node_identifier(&self, ordinal: usize) -> String {
        format!("{}.n{ordinal:x}", self.revision)
    }

    pub(crate) fn node(&self, ordinal: usize) -> Option<&ViewNode> {
        self.nodes.get(ordinal)
    }

    pub(crate) fn exact_matches(&self, key: &SpanKey) -> &[usize] {
        self.by_span.get(key).map_or(&[], Vec::as_slice)
    }

    pub(crate) fn ordinal_of(&self, identifier: &str) -> Option<usize> {
        let suffix = identifier
            .strip_prefix(self.revision.as_str())?
            .strip_prefix(".n")?;
        usize::from_str_radix(suffix, 16)
            .ok()
            .filter(|ordinal| *ordinal < self.nodes.len())
    }

    pub(crate) fn node_json(&self, ordinal: usize) -> Option<Value> {
        let node = self.nodes.get(ordinal)?;
        let mut value = json!({
            "node_id": self.node_identifier(ordinal),
            "kind": node.kind.as_str(),
            "syntax_kind": node.syntax_kind,
            "span": span_json(node),
            "child_node_ids": node.children.iter().map(|child| self.node_identifier(*child)).collect::<Vec<_>>(),
            "child_roles": node.children.iter().zip(&node.child_roles).map(|(child, role)| json!({"node_id":self.node_identifier(*child),"role":role})).collect::<Vec<_>>(),
        });
        if let (Some(parent), Some(fields)) = (node.parent, value.as_object_mut()) {
            fields.insert(
                "parent_node_id".to_owned(),
                json!(self.node_identifier(parent)),
            );
        }
        if let (Some(dimensions), Some(fields)) = (node.dimensions, value.as_object_mut()) {
            fields.insert("dimensions".to_owned(), json!(dimensions));
        }
        if let Some(fields) = value.as_object_mut() {
            for (name, attribute) in &node.attributes {
                fields.insert((*name).to_owned(), attribute.clone());
            }
        }
        Some(value)
    }

    pub(crate) fn to_json(&self) -> Value {
        let nodes: Vec<Value> = (0..self.nodes.len())
            .filter_map(|ordinal| self.node_json(ordinal))
            .collect();
        json!({
            "revision_id": self.revision,
            "child_order": "source",
            "units": self.units,
            "nodes": nodes,
            "inheritance": self.inheritance,
            "methods": self.methods,
            "members": self.members,
        })
    }
}

fn index_by_span(nodes: &[ViewNode]) -> BTreeMap<SpanKey, Vec<usize>> {
    let mut by_span: BTreeMap<SpanKey, Vec<usize>> = BTreeMap::new();
    for (ordinal, node) in nodes.iter().enumerate() {
        by_span
            .entry((node.start, node.end))
            .or_default()
            .push(ordinal);
    }
    by_span
}

pub(crate) fn span_json(node: &ViewNode) -> Value {
    json!({
        "start_byte": node.start_byte.to_string(),
        "end_byte": node.end_byte.to_string(),
        "start": {"line": node.start.0, "column": node.start.1},
        "end": {"line": node.end.0, "column": node.end.1},
    })
}
