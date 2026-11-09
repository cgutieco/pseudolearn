use reference_model::{
    CalloutKind, Profile, RuleId, Run, SectionKind, Token, TokenCategory, Violation,
};

#[test]
fn tokens_serialize_as_compact_pairs() {
    let token = Token {
        text: "Si".to_owned(),
        category: Some(TokenCategory::KeywordStructured),
    };
    let plain = Token {
        text: " ".to_owned(),
        category: None,
    };
    assert_eq!(
        serde_json::to_string(&token).ok().as_deref(),
        Some("[\"Si\",\"keywordStructured\"]")
    );
    assert_eq!(
        serde_json::to_string(&plain).ok().as_deref(),
        Some("[\" \"]")
    );
}

#[test]
fn callouts_round_trip_through_their_directive() {
    for name in [
        "frase",
        "limite",
        "por-dentro",
        "analogia",
        "nota",
        "partes",
        "errores",
        "resumen",
        "vease",
    ] {
        assert_eq!(
            CalloutKind::from_directive(name).map(CalloutKind::directive),
            Some(name)
        );
    }
    assert_eq!(CalloutKind::from_directive("otro"), None);
    assert_eq!(CalloutKind::from_directive("docentes"), None);
    assert!(CalloutKind::Inside.collapsible() && !CalloutKind::Phrase.collapsible());
}

#[test]
fn section_kinds_declare_their_anatomy() {
    assert_eq!(SectionKind::Construction.minimum_programs(), 2);
    assert!(SectionKind::Type.requires_limit() && !SectionKind::Concept.requires_limit());
    assert!(!SectionKind::Appendix.requires_how_it_works());
}

#[test]
fn profiles_and_violations_render() {
    assert_eq!(Profile::from_code("en").map(Profile::code), Some("en"));
    assert_eq!(Profile::from_code("fr"), None);
    let violation = Violation::new(RuleId::Parity, "a.md", "differs");
    assert_eq!(violation.to_string(), "a.md: REF-PARITY differs");
    assert_eq!(
        Run::Slot {
            text: "x".to_owned()
        }
        .plain_text(),
        "x"
    );
}
