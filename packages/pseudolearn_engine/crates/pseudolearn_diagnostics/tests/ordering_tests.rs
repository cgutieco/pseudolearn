use pseudolearn_diagnostics::{
    Diagnostic, DiagnosticClass, DiagnosticCode, DiagnosticSeverity, sort_diagnostics_with,
};
use pseudolearn_source::{SourceId, Span};
use std::collections::BTreeMap;

fn source_keys() -> BTreeMap<SourceId, Vec<String>> {
    BTreeMap::from([
        (
            SourceId::new(1),
            vec!["alpha".to_owned(), "main".to_owned()],
        ),
        (SourceId::new(2), vec!["zeta".to_owned(), "main".to_owned()]),
        (
            SourceId::new(3),
            vec!["alpha".to_owned(), "related".to_owned()],
        ),
    ])
}

#[test]
fn sorts_project_diagnostics_by_portable_source_key_before_offsets() {
    let mut diagnostics = vec![
        Diagnostic::new(
            DiagnosticCode::UnrecognizedCharacter,
            Span::in_source(SourceId::new(2), 0, 1),
        ),
        Diagnostic::new(
            DiagnosticCode::UnrecognizedCharacter,
            Span::in_source(SourceId::new(1), 10, 11),
        ),
    ];
    sort_diagnostics_with(&mut diagnostics, &source_keys());
    let source_ids: Vec<SourceId> = diagnostics
        .iter()
        .map(|diagnostic| diagnostic.span.source_id)
        .collect();
    assert_eq!(source_ids, [SourceId::new(1), SourceId::new(2)]);
}

#[test]
fn sorts_module_segments_in_nfc_while_preserving_case() {
    let source_keys = BTreeMap::from([
        (
            SourceId::new(1),
            vec!["alpha".to_owned(), "Zeta".to_owned()],
        ),
        (
            SourceId::new(2),
            vec!["alpha".to_owned(), "aneta".to_owned()],
        ),
    ]);
    let mut diagnostics = vec![
        Diagnostic::new(
            DiagnosticCode::UnrecognizedCharacter,
            Span::in_source(SourceId::new(2), 0, 1),
        ),
        Diagnostic::new(
            DiagnosticCode::UnrecognizedCharacter,
            Span::in_source(SourceId::new(1), 0, 1),
        ),
    ];
    sort_diagnostics_with(&mut diagnostics, &source_keys);
    let source_ids: Vec<SourceId> = diagnostics
        .iter()
        .map(|diagnostic| diagnostic.span.source_id)
        .collect();
    assert_eq!(source_ids, [SourceId::new(1), SourceId::new(2)]);
}

#[test]
fn sorts_local_phases_before_positions_and_places_missing_sources_last() {
    let mut semantic = Diagnostic::new(DiagnosticCode::UndeclaredVariable, Span::new(0, 1));
    semantic.class = DiagnosticClass::Semantic;
    let mut lexical = Diagnostic::new(DiagnosticCode::UnrecognizedCharacter, Span::new(10, 11));
    lexical.class = DiagnosticClass::Lexical;
    let mut unsourced = Diagnostic::new(DiagnosticCode::InternalFault, Span::empty());
    unsourced.class = DiagnosticClass::Internal;
    let mut diagnostics = vec![semantic, unsourced.clone(), lexical];
    sort_diagnostics_with(&mut diagnostics, &source_keys());
    let classes: Vec<DiagnosticClass> = diagnostics
        .iter()
        .map(|diagnostic| diagnostic.class)
        .collect();
    assert_eq!(
        classes,
        [
            DiagnosticClass::Lexical,
            DiagnosticClass::Semantic,
            DiagnosticClass::Internal,
        ]
    );
    assert_eq!(diagnostics.last(), Some(&unsourced));
}

#[test]
fn resolves_all_ties_with_typed_arguments_and_related_locations() {
    let mut first = Diagnostic::new(
        DiagnosticCode::UnrecognizedCharacter,
        Span::in_source(SourceId::new(1), 0, 1),
    )
    .with_argument("lexeme", "b");
    first.related.push(Span::in_source(SourceId::new(2), 4, 5));
    let mut second = Diagnostic::new(
        DiagnosticCode::UnrecognizedCharacter,
        Span::in_source(SourceId::new(1), 0, 1),
    )
    .with_argument("lexeme", "a");
    second.related.push(Span::in_source(SourceId::new(3), 4, 5));
    let mut diagnostics = vec![first, second];
    sort_diagnostics_with(&mut diagnostics, &source_keys());
    let first_argument = diagnostics
        .first()
        .and_then(|diagnostic| diagnostic.arguments.get("lexeme"))
        .map(|value| value.text().into_owned());
    assert_eq!(first_argument, Some("a".to_owned()));
    let first_related_source = diagnostics
        .first()
        .and_then(|diagnostic| diagnostic.related.first())
        .map(|span| span.source_id);
    assert_eq!(first_related_source, Some(SourceId::new(3)));

    let mut later_related = Diagnostic::new(
        DiagnosticCode::UnrecognizedCharacter,
        Span::in_source(SourceId::new(1), 0, 1),
    )
    .with_argument("lexeme", "same");
    later_related
        .related
        .push(Span::in_source(SourceId::new(2), 4, 5));
    let mut earlier_related = Diagnostic::new(
        DiagnosticCode::UnrecognizedCharacter,
        Span::in_source(SourceId::new(1), 0, 1),
    )
    .with_argument("lexeme", "same");
    earlier_related
        .related
        .push(Span::in_source(SourceId::new(3), 4, 5));
    let mut related = vec![later_related, earlier_related];
    sort_diagnostics_with(&mut related, &source_keys());
    let first_related_source = related
        .first()
        .and_then(|diagnostic| diagnostic.related.first())
        .map(|span| span.source_id);
    assert_eq!(first_related_source, Some(SourceId::new(3)));
}

#[test]
fn sorts_remaining_ties_by_severity_and_preserves_related_multiplicity() {
    let mut information = Diagnostic::new(
        DiagnosticCode::UnrecognizedCharacter,
        Span::in_source(SourceId::new(1), 0, 1),
    )
    .with_argument("lexeme", "x")
    .with_severity(DiagnosticSeverity::Information);
    information.related.extend([
        Span::in_source(SourceId::new(2), 1, 2),
        Span::in_source(SourceId::new(3), 2, 3),
        Span::in_source(SourceId::new(2), 1, 2),
    ]);
    let error = Diagnostic::new(
        DiagnosticCode::UnrecognizedCharacter,
        Span::in_source(SourceId::new(1), 0, 1),
    )
    .with_argument("lexeme", "x");
    let mut diagnostics = vec![information, error];
    sort_diagnostics_with(&mut diagnostics, &source_keys());
    let severities: Vec<DiagnosticSeverity> = diagnostics
        .iter()
        .map(|diagnostic| diagnostic.severity)
        .collect();
    assert_eq!(
        severities,
        [DiagnosticSeverity::Error, DiagnosticSeverity::Information]
    );
    let information_related = diagnostics
        .iter()
        .find(|diagnostic| diagnostic.severity == DiagnosticSeverity::Information)
        .map(|diagnostic| diagnostic.related.as_slice())
        .unwrap_or_default();
    assert_eq!(
        information_related,
        [
            Span::in_source(SourceId::new(2), 1, 2),
            Span::in_source(SourceId::new(3), 2, 3),
            Span::in_source(SourceId::new(2), 1, 2),
        ]
    );
}
