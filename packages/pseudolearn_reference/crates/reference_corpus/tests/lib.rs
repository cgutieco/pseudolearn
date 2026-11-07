use reference_corpus::{Corpus, LexemeFamily};
use reference_model::Profile;

const EXPORT: &str = r#"{
  "resources": {
    "vocabulary": {
      "ifKeyword": {"alias": {"en": [], "es": []}, "lexemas": {"en": "if", "es": "Si"}},
      "algorithm": {"alias": {"en": [], "es": ["Algoritmo"]}, "lexemas": {"en": "algorithm", "es": "Proceso"}}
    },
    "contextualVocabulary": {"eachKeyword": {"lexemas": {"en": "each", "es": "Cada"}}},
    "functions": {"absoluteValue": {"alias": {"en": [], "es": []}, "family": "numbers", "lexemas": {"en": "abs", "es": "abs"}, "parametros": ["numeric"], "retorno": "real"}},
    "capabilityLibrary": {"operations": [{"effect": true, "en": "requestConsole", "es": "SolicitarConsola", "family": "io", "identity": "request_console", "parameters": [], "result": "console"}]},
    "diagnostics": {"integerOverflow": {"clase": "runtime", "severidad": "error", "mensajes": {"en": "Overflow", "es": "Desbordamiento"}}},
    "helpCatalog": {"cards": [{"id": "help.if", "category": "block", "anchors": [{"specification": "LANG.CONTROL.IF", "element": "R1"}], "content": {"es": {"title": "Si", "summary": "Decide"}, "en": {"title": "If", "summary": "Decides"}}}]},
    "grammar": {"producciones": {"conditional": "@ifKeyword, expression"}}
  },
  "specifications": [
    {"hash": "abc", "metadata": {"id": "LANG.CONTROL.IF", "titulo": "Condicional"}, "blocks": [{"kind": "regla", "fields": {"id": "R1", "texto": "x"}}, {"kind": "caso", "fields": {"id": "C1"}}]}
  ]
}"#;

fn corpus() -> Corpus {
    let loaded = Corpus::from_export(EXPORT);
    assert!(loaded.is_ok());
    loaded.unwrap_or_default()
}

#[test]
fn loads_every_lexeme_family() {
    let corpus = corpus();
    assert_eq!(
        corpus.lexicon.lexeme("ifKeyword", Profile::English),
        Some("if")
    );
    let each = corpus.lexicon.identity_of(Profile::Spanish, "Cada");
    assert_eq!(
        each.map(|entry| entry.family),
        Some(LexemeFamily::Contextual)
    );
    let console = corpus
        .lexicon
        .identity_of(Profile::Spanish, "SolicitarConsola");
    assert_eq!(
        console.map(|entry| entry.english.as_str()),
        Some("requestConsole")
    );
    assert_eq!(corpus.functions.len(), 2);
}

#[test]
fn resolves_aliases_to_their_identity() {
    let corpus = corpus();
    let entry = corpus.lexicon.identity_of(Profile::Spanish, "Algoritmo");
    assert_eq!(entry.map(|entry| entry.spanish.as_str()), Some("Proceso"));
    let folded = corpus.lexicon.identity_of(Profile::English, "If");
    assert_eq!(
        folded.map(|entry| entry.identity.as_str()),
        Some("ifKeyword")
    );
}

#[test]
fn validates_anchors_by_rule() {
    let corpus = corpus();
    assert!(corpus.rule_exists("LANG.CONTROL.IF"));
    assert!(corpus.rule_exists("LANG.CONTROL.IF#R1"));
    assert!(!corpus.rule_exists("LANG.CONTROL.IF#R9"));
    assert!(!corpus.rule_exists("LANG.CONTROL.NOPE"));
    assert_eq!(
        corpus.anchor_digest("LANG.CONTROL.IF"),
        Some("abc".to_owned())
    );
    assert_eq!(
        corpus
            .anchor_digest("LANG.CONTROL.IF#R1")
            .map(|digest| digest.len()),
        Some(64)
    );
}

#[test]
fn reads_catalogs() {
    let corpus = corpus();
    assert_eq!(
        corpus.cards.get("help.if").map(|card| card.anchors.clone()),
        Some(vec!["LANG.CONTROL.IF".to_owned()])
    );
    assert_eq!(
        corpus
            .diagnostics
            .get("integerOverflow")
            .map(|entry| entry.english.as_str()),
        Some("Overflow")
    );
    assert_eq!(
        corpus.productions.get("conditional").map(String::as_str),
        Some("@ifKeyword, expression")
    );
}

#[test]
fn rejects_invalid_json() {
    assert!(Corpus::from_export("{").is_err());
}

#[test]
fn rejects_an_export_without_resources() {
    assert!(Corpus::from_export("{}").is_err());
}
