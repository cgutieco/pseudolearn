use crate::model::ApiSourceIdentity;
use pseudolearn_source::{
    ProjectId, RevisionId, SourceId, SourceIdentity, SourceText, source_identity,
    source_text_with_identity,
};

pub(crate) fn source_text(content: String, identity: Option<ApiSourceIdentity>) -> SourceText {
    let Some(identity) = identity.filter(|identity| identity.is_valid()) else {
        return SourceText::new(content);
    };
    source_text_with_identity(
        SourceIdentity {
            project_id: ProjectId::new(identity.project_id),
            revision_id: RevisionId::new(identity.revision_id),
            source_id: SourceId::new(identity.source_id),
        },
        content,
    )
}

pub(crate) fn api_identity(source: &SourceText) -> Option<ApiSourceIdentity> {
    source_identity(source).map(|identity| ApiSourceIdentity {
        project_id: identity.project_id.value(),
        revision_id: identity.revision_id.value(),
        source_id: identity.source_id.value(),
    })
}
