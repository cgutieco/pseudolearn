#[path = "../codegen/grammar_reader.rs"]
mod grammar_reader;
#[path = "../codegen/views.rs"]
mod views;
use std::collections::{BTreeMap, BTreeSet};

#[test]
fn validates_references_and_nested_ebnf() {
    let terminals = BTreeSet::from(["identifier".to_owned()]);
    let productions = BTreeMap::from([(
        "program".to_owned(),
        "{ [ @identifier ], ( identifier | identifier ) }".to_owned(),
    )]);
    assert!(grammar_reader::validate(&productions, &terminals).is_ok());
    for body in [
        "",
        "identifier identifier",
        "| identifier",
        "identifier,",
        "()",
        "[ identifier )",
        "[ identifier",
        "unknown",
        "@unknown",
        "{ identifier | }",
        "identifier ]",
    ] {
        let malformed = BTreeMap::from([("program".to_owned(), body.to_owned())]);
        assert!(
            grammar_reader::validate(&malformed, &terminals).is_err(),
            "{body}"
        );
    }
    assert!(grammar_reader::validate(&BTreeMap::new(), &terminals).is_err());
}

#[test]
fn generates_deterministic_views_from_declared_identities() {
    let names = BTreeSet::from(["program".to_owned(), "integerLiteral".to_owned()]);
    let generated = views::generate(&names, 256);
    assert_eq!(generated, views::generate(&names, 256));
    assert!(generated.contains("pub struct IntegerLiteralView"));
    assert!(generated.contains("NodeKind::IntegerLiteral"));
    assert!(!generated.contains("AlgorithmUnit"));
    assert_ne!(generated, views::generate(&names, 257));
}
