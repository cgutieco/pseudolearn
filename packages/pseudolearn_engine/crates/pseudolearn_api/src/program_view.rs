use crate::program_view_annotations::AnnotationContext;
use crate::program_view_kind::ViewKind;
use crate::{AnalyzeRequest, ApiError};
use pseudolearn_diagnostics::DiagnosticCode;
use pseudolearn_lexicon::Profile;
use pseudolearn_syntax::parse_source_with_terminator;
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) type Position = (u32, u32);
pub(crate) type SpanKey = (pseudolearn_source::SourceId, Position, Position);

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
    pub(crate) source: Option<crate::ApiSourceIdentity>,
}

pub(crate) struct ProgramView {
    revision: String,
    nodes: Vec<ViewNode>,
    by_span: BTreeMap<SpanKey, Vec<usize>>,
    units: Value,
    inheritance: Value,
    methods: Value,
    members: Value,
    source_id: pseudolearn_source::SourceId,
    source: Option<crate::ApiSourceIdentity>,
}

impl ProgramView {
    pub(crate) fn build(request: &AnalyzeRequest, revision: String) -> Result<Self, ApiError> {
        Self::build_with_mode(request, revision, false)
    }

    pub(crate) fn build_project(
        request: &AnalyzeRequest,
        revision: String,
    ) -> Result<Self, ApiError> {
        Self::build_with_mode(request, revision, true)
    }

    fn build_with_mode(
        request: &AnalyzeRequest,
        revision: String,
        project: bool,
    ) -> Result<Self, ApiError> {
        let profile = Profile::from_name(&request.profile).unwrap_or(Profile::Spanish);
        let strict = request.strictness != "flexible";
        let (source, tree) = parse_view_source(request, strict, profile, project)?;
        let nodes = annotated_nodes(&tree, &source, (profile, strict), &revision);
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
            source_id: pseudolearn_source::source_id(&source),
            source: crate::source_identity::api_identity(&source),
        })
    }

    pub(crate) fn revision(&self) -> &str {
        &self.revision
    }

    pub(crate) fn node_identifier(&self, ordinal: usize) -> String {
        match self.source {
            Some(source) => format!(
                "p{:x}.r{:x}.f{:x}.n{ordinal:x}",
                source.project_id, source.revision_id, source.source_id
            ),
            None => format!("{}.n{ordinal:x}", self.revision),
        }
    }

    pub(crate) fn source_id(&self) -> pseudolearn_source::SourceId {
        self.source_id
    }

    pub(crate) fn node(&self, ordinal: usize) -> Option<&ViewNode> {
        self.nodes.get(ordinal)
    }

    pub(crate) fn exact_matches(&self, key: &SpanKey) -> &[usize] {
        self.by_span.get(key).map_or(&[], Vec::as_slice)
    }

    pub(crate) fn ordinal_of(&self, identifier: &str) -> Option<usize> {
        let prefix = self.source.map_or_else(
            || format!("{}.n", self.revision),
            |source| {
                format!(
                    "p{:x}.r{:x}.f{:x}.n",
                    source.project_id, source.revision_id, source.source_id
                )
            },
        );
        let suffix = identifier.strip_prefix(&prefix)?;
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
        let mut value = json!({
            "revision_id": self.revision,
            "child_order": "source",
            "units": self.units,
            "nodes": nodes,
            "inheritance": self.inheritance,
            "methods": self.methods,
            "members": self.members,
        });
        if let (Some(source), Some(fields)) = (self.source, value.as_object_mut()) {
            fields.insert("source".to_owned(), json!(source));
        }
        value
    }
}

fn annotated_nodes(
    tree: &pseudolearn_syntax::SyntaxTree,
    source: &pseudolearn_source::SourceText,
    mode: (Profile, bool),
    revision: &str,
) -> Vec<ViewNode> {
    let mut nodes = crate::program_view_tree::collect_nodes(tree, source);
    let context = AnnotationContext {
        tree,
        source,
        profile: mode.0,
        strict: mode.1,
    };
    crate::program_view_annotations::annotate(&mut nodes, &context);
    crate::program_view_nominal::annotate(&mut nodes, &context, revision);
    nodes
}

fn parse_view_source(
    request: &AnalyzeRequest,
    strict: bool,
    profile: Profile,
    project: bool,
) -> Result<
    (
        pseudolearn_source::SourceText,
        pseudolearn_syntax::SyntaxTree,
    ),
    ApiError,
> {
    let source = crate::source_identity::source_text(request.program.clone(), request.source);
    let terminator = strict.then_some(DiagnosticCode::MissingStatementTerminator);
    let (tree, _) = if project {
        pseudolearn_syntax::parse_module_source(&source, profile, terminator)
    } else {
        parse_source_with_terminator(&source, profile, terminator)
    };
    if tree.has_errors {
        return Err(crate::execution_resource::usage("analysis has errors"));
    }
    Ok((source, tree))
}

fn index_by_span(nodes: &[ViewNode]) -> BTreeMap<SpanKey, Vec<usize>> {
    let mut by_span: BTreeMap<SpanKey, Vec<usize>> = BTreeMap::new();
    for (ordinal, node) in nodes.iter().enumerate() {
        by_span
            .entry((
                node.source
                    .map_or(pseudolearn_source::SourceId::STANDALONE, |source| {
                        pseudolearn_source::SourceId::new(source.source_id)
                    }),
                node.start,
                node.end,
            ))
            .or_default()
            .push(ordinal);
    }
    by_span
}

pub(crate) fn span_json(node: &ViewNode) -> Value {
    let mut span = json!({
        "start_byte": node.start_byte.to_string(),
        "end_byte": node.end_byte.to_string(),
        "start": {"line": node.start.0, "column": node.start.1},
        "end": {"line": node.end.0, "column": node.end.1},
    });
    if let (Some(source), Some(fields)) = (node.source, span.as_object_mut()) {
        fields.insert("source".to_owned(), json!(source));
    }
    span
}
