mod support;

use reference_model::{CodeEngine, ExecutionRequest, Profile};
use reference_resolve::CachedEngine;

#[test]
fn runs_each_distinct_request_once() {
    let engine = CachedEngine::new(support::FakeEngine::default());
    let request = ExecutionRequest {
        code: "Escribir 1".to_owned(),
        profile: Profile::Spanish,
        inputs: Vec::new(),
        host: None,
        trace: false,
        statement_limit: None,
    };
    let first = engine.execute(&request);
    let second = engine.execute(&request);
    assert_eq!(first, second);
    let mut traced = request.clone();
    traced.trace = true;
    engine.execute(&traced);
    assert_eq!(
        engine.tokenize("Si", Profile::Spanish),
        engine.tokenize("Si", Profile::Spanish)
    );
    assert_eq!(
        engine.translate("Escribir", Profile::English),
        Ok("Write".to_owned())
    );
    assert_eq!(engine.fingerprint(), "fake");
    assert!(engine.intermediate("roto", Profile::Spanish).is_err());
}

#[test]
fn the_fixtures_are_consistent() {
    assert!(support::corpus().lexicon.entry("ifKeyword").is_some());
    assert!(support::categories().category("ifKeyword").is_some());
    assert_eq!(support::pack().phrase("rails.title"), "Raíles:");
    assert!(support::figures().contains_key("caja"));
    assert_eq!(support::document("").header.id, "prueba");
    assert!(support::index().get("prueba").is_some());
}
