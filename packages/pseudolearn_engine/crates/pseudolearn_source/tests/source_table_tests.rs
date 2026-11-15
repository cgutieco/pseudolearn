use pseudolearn_source::{
    NodeId, ProjectId, RevisionId, SourceFileInput, SourceId, SourceLookupFailure, SourceNodeInput,
    SourceTable, SourceTableFailure, Span,
};

fn input(source_id: u32, text: &str) -> SourceFileInput {
    SourceFileInput {
        source_id: SourceId::new(source_id),
        name: "same.pseudo".to_owned(),
        text: text.to_owned(),
    }
}

#[test]
fn equal_names_and_offsets_keep_distinct_source_identity() -> Result<(), String> {
    let table = SourceTable::new(
        ProjectId::new(7),
        RevisionId::new(11),
        vec![input(2, "x"), input(1, "x")],
    )
    .map_err(|failure| format!("{failure:?}"))?;
    let first = table
        .locate(
            SourceId::new(1),
            None,
            Span::in_source(SourceId::new(1), 0, 1),
        )
        .map_err(|failure| format!("{failure:?}"))?;
    let second = table
        .locate(
            SourceId::new(2),
            None,
            Span::in_source(SourceId::new(2), 0, 1),
        )
        .map_err(|failure| format!("{failure:?}"))?;
    assert_eq!(
        table
            .resolve(first)
            .map_err(|failure| format!("{failure:?}"))?
            .name(),
        "same.pseudo"
    );
    assert_eq!(
        table
            .resolve(second)
            .map_err(|failure| format!("{failure:?}"))?
            .name(),
        "same.pseudo"
    );
    assert_ne!(first.identity.source_id, second.identity.source_id);
    assert_eq!(first.span.start, second.span.start);
    Ok(())
}

#[test]
fn source_table_rejects_reserved_and_duplicate_ids() {
    let reserved = SourceTable::new(ProjectId::new(1), RevisionId::new(1), vec![input(0, "")]);
    let duplicate = SourceTable::new(
        ProjectId::new(1),
        RevisionId::new(1),
        vec![input(1, "a"), input(1, "b")],
    );
    assert_eq!(reserved, Err(SourceTableFailure::ReservedSourceId));
    assert_eq!(duplicate, Err(SourceTableFailure::DuplicateSourceId));
}

#[test]
fn lookup_rejects_unknown_sources_foreign_projects_and_old_revisions() -> Result<(), String> {
    let table = SourceTable::new(ProjectId::new(3), RevisionId::new(8), vec![input(5, "abc")])
        .map_err(|failure| format!("{failure:?}"))?;
    assert_eq!(
        table.locate(
            SourceId::new(9),
            None,
            Span::in_source(SourceId::new(9), 0, 1)
        ),
        Err(SourceLookupFailure::MissingSource)
    );
    let location = table
        .locate(
            SourceId::new(5),
            None,
            Span::in_source(SourceId::new(5), 0, 1),
        )
        .map_err(|failure| format!("{failure:?}"))?;
    let old_revision = pseudolearn_source::SourceLocation {
        identity: pseudolearn_source::SourceIdentity {
            revision_id: RevisionId::new(7),
            ..location.identity
        },
        ..location
    };
    assert_eq!(
        table.resolve(old_revision),
        Err(SourceLookupFailure::ForeignRevision)
    );
    let foreign_project = pseudolearn_source::SourceLocation {
        identity: pseudolearn_source::SourceIdentity {
            project_id: ProjectId::new(4),
            ..location.identity
        },
        ..location
    };
    assert_eq!(
        table.resolve(foreign_project),
        Err(SourceLookupFailure::ForeignProject)
    );
    Ok(())
}

#[test]
fn lookup_rejects_invalid_utf8_ranges_and_accepts_empty_sources() -> Result<(), String> {
    let table = SourceTable::new(
        ProjectId::new(1),
        RevisionId::new(2),
        vec![input(1, "😀"), input(2, "")],
    )
    .map_err(|failure| format!("{failure:?}"))?;
    assert_eq!(
        table.locate(
            SourceId::new(1),
            None,
            Span::in_source(SourceId::new(1), 1, 2)
        ),
        Err(SourceLookupFailure::InvalidRange)
    );
    assert!(
        table
            .locate(
                SourceId::new(2),
                None,
                Span::in_source(SourceId::new(2), 0, 0)
            )
            .is_ok()
    );
    Ok(())
}

#[test]
fn node_ids_are_scoped_to_a_file_and_validate_contained_ranges() -> Result<(), String> {
    let table = SourceTable::new(
        ProjectId::new(4),
        RevisionId::new(5),
        vec![input(1, "abc"), input(2, "abc")],
    )
    .map_err(|failure| format!("{failure:?}"))?
    .with_nodes(vec![
        SourceNodeInput {
            source_id: SourceId::new(1),
            node_id: NodeId::new(1),
            span: Span::in_source(SourceId::new(1), 0, 3),
        },
        SourceNodeInput {
            source_id: SourceId::new(2),
            node_id: NodeId::new(1),
            span: Span::in_source(SourceId::new(2), 0, 3),
        },
    ])
    .map_err(|failure| format!("{failure:?}"))?;
    for source_id in [1, 2] {
        assert!(
            table
                .locate(
                    SourceId::new(source_id),
                    Some(NodeId::new(1)),
                    Span::in_source(SourceId::new(source_id), 1, 2),
                )
                .is_ok()
        );
    }
    assert_eq!(
        table.locate(
            SourceId::new(1),
            Some(NodeId::new(2)),
            Span::in_source(SourceId::new(1), 1, 2),
        ),
        Err(SourceLookupFailure::MissingNode)
    );
    assert_eq!(
        table.locate(
            SourceId::new(1),
            Some(NodeId::new(1)),
            Span::in_source(SourceId::new(1), 2, 4),
        ),
        Err(SourceLookupFailure::InvalidRange)
    );
    Ok(())
}
