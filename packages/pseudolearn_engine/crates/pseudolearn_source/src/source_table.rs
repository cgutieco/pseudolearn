use crate::identity::{ProjectId, RevisionId, SourceIdentity, SourceLocation};
use crate::source_text::{SourceText, is_valid_span, source_text_with_identity};
use crate::span::{SourceId, Span};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceFileInput {
    pub source_id: SourceId,
    pub name: String,
    pub text: String,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceFile {
    source_id: SourceId,
    name: String,
    text: SourceText,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct SourceNodeInput {
    pub source_id: SourceId,
    pub node_id: crate::identity::NodeId,
    pub span: Span,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct SourceNode {
    source_id: SourceId,
    node_id: crate::identity::NodeId,
    span: Span,
}

impl SourceFile {
    pub fn source_id(&self) -> SourceId {
        self.source_id
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn text(&self) -> &SourceText {
        &self.text
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum SourceTableFailure {
    InvalidIdentity,
    ReservedSourceId,
    DuplicateSourceId,
    MissingNodeSource,
    DuplicateNodeId,
    SourceTooLarge,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum SourceLookupFailure {
    ForeignProject,
    ForeignRevision,
    MissingSource,
    MissingNode,
    InvalidRange,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct SourceTable {
    project_id: ProjectId,
    revision_id: RevisionId,
    files: Vec<SourceFile>,
    nodes: Vec<SourceNode>,
}

impl SourceTable {
    pub fn new(
        project_id: ProjectId,
        revision_id: RevisionId,
        inputs: Vec<SourceFileInput>,
    ) -> Result<Self, SourceTableFailure> {
        if project_id.value() == 0 || revision_id.value() == 0 {
            return Err(SourceTableFailure::InvalidIdentity);
        }
        let files = files_for_revision(project_id, revision_id, inputs)?;
        Ok(Self {
            project_id,
            revision_id,
            files,
            nodes: Vec::new(),
        })
    }

    pub fn with_nodes(
        mut self,
        mut inputs: Vec<SourceNodeInput>,
    ) -> Result<Self, SourceTableFailure> {
        inputs.sort_by_key(|input| (input.source_id, input.node_id));
        let mut nodes = Vec::with_capacity(inputs.len());
        let mut previous = None;
        for input in inputs {
            let key = (input.source_id, input.node_id);
            if previous == Some(key) {
                return Err(SourceTableFailure::DuplicateNodeId);
            }
            let file = self
                .file(input.source_id)
                .ok_or(SourceTableFailure::MissingNodeSource)?;
            if !is_valid_span(&file.text, input.span) {
                return Err(SourceTableFailure::MissingNodeSource);
            }
            previous = Some(key);
            nodes.push(SourceNode {
                source_id: input.source_id,
                node_id: input.node_id,
                span: input.span,
            });
        }
        self.nodes = nodes;
        Ok(self)
    }

    pub fn identity(&self, source_id: SourceId) -> Option<SourceIdentity> {
        self.file(source_id)?;
        Some(SourceIdentity {
            project_id: self.project_id,
            revision_id: self.revision_id,
            source_id,
        })
    }

    pub fn file(&self, source_id: SourceId) -> Option<&SourceFile> {
        self.files
            .binary_search_by_key(&source_id, SourceFile::source_id)
            .ok()
            .and_then(|index| self.files.get(index))
    }

    pub fn files(&self) -> &[SourceFile] {
        &self.files
    }

    pub fn locate(
        &self,
        source_id: SourceId,
        node_id: Option<crate::identity::NodeId>,
        span: Span,
    ) -> Result<SourceLocation, SourceLookupFailure> {
        let identity = self
            .identity(source_id)
            .ok_or(SourceLookupFailure::MissingSource)?;
        let file = self
            .file(source_id)
            .ok_or(SourceLookupFailure::MissingSource)?;
        if !is_valid_span(&file.text, span) {
            return Err(SourceLookupFailure::InvalidRange);
        }
        let location = SourceLocation {
            identity,
            node_id,
            span,
        };
        self.resolve(location)?;
        Ok(location)
    }

    pub fn resolve(&self, location: SourceLocation) -> Result<&SourceFile, SourceLookupFailure> {
        if location.identity.project_id != self.project_id {
            return Err(SourceLookupFailure::ForeignProject);
        }
        if location.identity.revision_id != self.revision_id {
            return Err(SourceLookupFailure::ForeignRevision);
        }
        let file = self
            .file(location.identity.source_id)
            .ok_or(SourceLookupFailure::MissingSource)?;
        if !is_valid_span(&file.text, location.span) {
            return Err(SourceLookupFailure::InvalidRange);
        }
        if let Some(node_id) = location.node_id {
            let key = (location.identity.source_id, node_id);
            let node_index = self
                .nodes
                .binary_search_by_key(&key, |node| (node.source_id, node.node_id))
                .map_err(|_| SourceLookupFailure::MissingNode)?;
            let node = self
                .nodes
                .get(node_index)
                .ok_or(SourceLookupFailure::MissingNode)?;
            if location.span.start < node.span.start || location.span.ending > node.span.ending {
                return Err(SourceLookupFailure::InvalidRange);
            }
        }
        Ok(file)
    }
}

fn files_for_revision(
    project_id: ProjectId,
    revision_id: RevisionId,
    mut inputs: Vec<SourceFileInput>,
) -> Result<Vec<SourceFile>, SourceTableFailure> {
    inputs.sort_by_key(|input| input.source_id);
    let mut files = Vec::with_capacity(inputs.len());
    let mut previous = None;
    for input in inputs {
        if input.source_id == SourceId::STANDALONE {
            return Err(SourceTableFailure::ReservedSourceId);
        }
        if previous == Some(input.source_id) {
            return Err(SourceTableFailure::DuplicateSourceId);
        }
        if u32::try_from(input.text.len()).is_err() {
            return Err(SourceTableFailure::SourceTooLarge);
        }
        previous = Some(input.source_id);
        let identity = SourceIdentity {
            project_id,
            revision_id,
            source_id: input.source_id,
        };
        let text = source_text_with_identity(identity, input.text);
        files.push(SourceFile {
            source_id: input.source_id,
            name: input.name,
            text,
        });
    }
    Ok(files)
}
