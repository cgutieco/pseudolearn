use crate::program_view_annotations::AnnotationContext;
use crate::program_view_kind::ViewKind;
use crate::program_view_source::{ParseMode, index_by_span, parse_view_source};
use crate::{AnalyzeRequest, ApiError};
use pseudolearn_lexicon::Profile;
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
    realizations: Value,
    dependencies: Option<Value>,
    source_id: pseudolearn_source::SourceId,
    source: Option<crate::ApiSourceIdentity>,
}

impl ProgramView {
    pub(crate) fn build(request: &AnalyzeRequest, revision: String) -> Result<Self, ApiError> {
        Self::build_with_mode(request, revision, ParseMode::Standalone)
    }

    pub(crate) fn build_project(
        request: &AnalyzeRequest,
        revision: String,
    ) -> Result<Self, ApiError> {
        Self::build_with_mode(request, revision, ParseMode::Project)
    }

    pub(crate) fn build_with_pending_links(
        request: &AnalyzeRequest,
        revision: String,
    ) -> Result<Self, ApiError> {
        Self::build_with_mode(request, revision, ParseMode::PendingLinks)
    }

    fn build_with_mode(
        request: &AnalyzeRequest,
        revision: String,
        mode: ParseMode,
    ) -> Result<Self, ApiError> {
        let profile = Profile::from_name(&request.profile).unwrap_or(Profile::Spanish);
        let strict = request.strictness != "flexible";
        let (source, tree) = parse_view_source(request, strict, profile, mode)?;
        let (nodes, realizations) = annotated_nodes(&tree, &source, (profile, strict), &revision);
        let schema = crate::diagnostic_conversion::schema(&tree, &source);
        let source_identity = crate::source_identity::api_identity(&source);
        let (inheritance, methods, members) = relations(&tree, &source, (&nodes, &revision));
        let units = crate::program_view_units::units(&schema, &nodes, &revision, source_identity);
        let dependencies = crate::program_view_dependencies::pending(
            (mode == ParseMode::PendingLinks).then_some(&tree),
            &source,
            (&revision, source_identity),
        );
        Ok(Self {
            revision,
            by_span: index_by_span(&nodes),
            nodes,
            units,
            inheritance,
            methods,
            members,
            realizations,
            dependencies,
            source_id: pseudolearn_source::source_id(&source),
            source: source_identity,
        })
    }

    pub(crate) fn revision(&self) -> &str {
        &self.revision
    }

    pub(crate) fn node_identifier(&self, ordinal: usize) -> String {
        node_identifier(&self.revision, self.source, ordinal)
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
            "realizations": self.realizations,
        });
        if let (Some(source), Some(fields)) = (self.source, value.as_object_mut()) {
            fields.insert("source".to_owned(), json!(source));
        }
        if let (Some(dependencies), Some(fields)) = (&self.dependencies, value.as_object_mut()) {
            fields.insert("dependencies".to_owned(), dependencies.clone());
        }
        value
    }
}

fn relations(
    tree: &pseudolearn_syntax::SyntaxTree,
    source: &pseudolearn_source::SourceText,
    (nodes, revision): (&[ViewNode], &str),
) -> (Value, Value, Value) {
    let (inheritance, methods) = crate::program_view_relations::RelationProjection {
        tree,
        source,
        nodes,
        revision,
        source_identity: crate::source_identity::api_identity(source),
    }
    .project();
    let members =
        crate::program_view_members::members(crate::program_view_members::MemberProjection {
            tree,
            source,
            nodes,
            revision,
        });
    (inheritance, methods, members)
}

fn annotated_nodes(
    tree: &pseudolearn_syntax::SyntaxTree,
    source: &pseudolearn_source::SourceText,
    mode: (Profile, bool),
    revision: &str,
) -> (Vec<ViewNode>, Value) {
    let mut nodes = crate::program_view_tree::collect_nodes(tree, source);
    let context = AnnotationContext {
        tree,
        source,
        profile: mode.0,
        strict: mode.1,
    };
    crate::program_view_annotations::annotate(&mut nodes, &context);
    let analysis = pseudolearn_semantic::analyze_for_service(
        tree,
        source,
        pseudolearn_semantic::SemanticOptions {
            profile: mode.0,
            strict: mode.1,
        },
    );
    let realizations =
        crate::program_view_nominal::annotate(&mut nodes, &context, revision, &analysis);
    crate::program_view_exits::annotate(&mut nodes, revision);
    (nodes, realizations)
}

pub(crate) fn node_identifier(
    revision: &str,
    source: Option<crate::ApiSourceIdentity>,
    ordinal: usize,
) -> String {
    match source {
        Some(source) => format!(
            "p{:x}.r{:x}.f{:x}.n{ordinal:x}",
            source.project_id, source.revision_id, source.source_id
        ),
        None => format!("{revision}.n{ordinal:x}"),
    }
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
