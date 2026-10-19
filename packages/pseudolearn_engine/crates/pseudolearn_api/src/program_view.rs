use crate::program_view_kind::{ViewKind, classify};
use crate::{AnalyzeRequest, ApiError};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::{NodeKind, SyntaxTree, parse_source_with_terminator};
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) type Position = (u32, u32);
pub(crate) type SpanKey = (Position, Position);

pub(crate) struct ViewNode {
    pub(crate) kind: ViewKind,
    pub(crate) start_byte: u32,
    pub(crate) end_byte: u32,
    pub(crate) start: Position,
    pub(crate) end: Position,
    pub(crate) parent: Option<usize>,
    pub(crate) children: Vec<usize>,
}

pub(crate) struct ProgramView {
    revision: String,
    nodes: Vec<ViewNode>,
    by_span: BTreeMap<SpanKey, Vec<usize>>,
    units: Value,
    inheritance: Value,
    methods: Value,
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
        let nodes = collect_nodes(&tree, &source);
        let mut by_span: BTreeMap<SpanKey, Vec<usize>> = BTreeMap::new();
        for (ordinal, node) in nodes.iter().enumerate() {
            by_span
                .entry((node.start, node.end))
                .or_default()
                .push(ordinal);
        }
        let schema = crate::diagnostic_conversion::schema(&tree, &source);
        let (inheritance, methods) =
            crate::program_view_relations::inheritance_and_methods(&tree, &source);
        Ok(Self {
            revision,
            nodes,
            by_span,
            units: crate::program_view_relations::units(&schema),
            inheritance,
            methods,
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
            "span": span_json(node),
            "child_node_ids": node.children.iter().map(|child| self.node_identifier(*child)).collect::<Vec<_>>(),
        });
        if let (Some(parent), Some(fields)) = (node.parent, value.as_object_mut()) {
            fields.insert(
                "parent_node_id".to_owned(),
                json!(self.node_identifier(parent)),
            );
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
        })
    }
}

pub(crate) fn span_json(node: &ViewNode) -> Value {
    json!({
        "start_byte": node.start_byte.to_string(),
        "end_byte": node.end_byte.to_string(),
        "start": {"line": node.start.0, "column": node.start.1},
        "end": {"line": node.end.0, "column": node.end.1},
    })
}

fn collect_nodes(tree: &SyntaxTree, source: &SourceText) -> Vec<ViewNode> {
    let mut nodes: Vec<ViewNode> = Vec::new();
    let Some(root) = tree.nodes.len().checked_sub(1) else {
        return nodes;
    };
    let mut pending: Vec<(usize, Option<usize>, Option<NodeKind>)> = vec![(root, None, None)];
    while let Some((index, view_parent, syntax_parent)) = pending.pop() {
        let Some(syntax_node) = tree.node(index) else {
            continue;
        };
        let mut next_parent = view_parent;
        if let (Some(kind), Some(span)) = (
            classify(syntax_node.kind, syntax_parent),
            tree.span_for_node(index),
        ) {
            let ordinal = nodes.len();
            nodes.push(ViewNode {
                kind,
                start_byte: span.start,
                end_byte: span.ending,
                start: source.line_and_column(span.start),
                end: source.line_and_column(span.ending),
                parent: view_parent,
                children: Vec::new(),
            });
            if let Some(owner) = view_parent.and_then(|parent| nodes.get_mut(parent)) {
                owner.children.push(ordinal);
            }
            next_parent = Some(ordinal);
        }
        for child in tree.child_indices(index).iter().rev() {
            pending.push((*child, next_parent, Some(syntax_node.kind)));
        }
    }
    nodes
}
