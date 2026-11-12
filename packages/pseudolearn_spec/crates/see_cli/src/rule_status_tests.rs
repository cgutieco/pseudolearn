use super::rule_status::RuleStatus;
use see_model::{Block, Corpus};
use serde_json::json;
use std::collections::BTreeMap;

fn corpus() -> Result<Corpus, String> {
    let mut specification = see_format::parsing::parse(
        "sample.md",
        include_str!("../../../fixtures/valid/specifications/sample.md"),
    )?;
    specification.blocks.push(Block {
        kind: "propiedad".to_owned(),
        fields: BTreeMap::from([
            ("id".to_owned(), json!("P1")),
            ("regla".to_owned(), json!("R1")),
        ]),
    });
    Ok(vec![specification])
}

fn status(state: &str) -> RuleStatus {
    RuleStatus::from_states(
        "aot",
        BTreeMap::from([("LANG.TEST.SAMPLE@1.0.0#R1".to_owned(), state.to_owned())]),
    )
}

fn fixture(rule: &str) -> serde_json::Value {
    json!({"specification":"LANG.TEST.SAMPLE","case":"C1","rule":rule})
}

#[test]
fn a_case_of_a_measured_or_unbound_rule_is_measured() -> Result<(), String> {
    let corpus = corpus()?;
    assert!(status("cumple").case_is_measured(&corpus, &fixture("R1")));
    assert!(status("cumple").case_is_measured(&corpus, &fixture("R2")));
    assert!(
        RuleStatus::from_states("aot", BTreeMap::new()).case_is_measured(&corpus, &fixture("R1"))
    );
    Ok(())
}

#[test]
fn cases_of_pending_or_exempt_rules_are_not_measured() -> Result<(), String> {
    let corpus = corpus()?;
    assert!(!status("pendiente").case_is_measured(&corpus, &fixture("R1")));
    assert!(!status("exento").case_is_measured(&corpus, &fixture("R1")));
    Ok(())
}

#[test]
fn cases_of_unknown_specifications_or_of_other_subjects_are_not_measured() -> Result<(), String> {
    let corpus = corpus()?;
    let foreign = RuleStatus::from_states("service", BTreeMap::new());
    assert!(!foreign.case_is_measured(&corpus, &fixture("R1")));
    assert!(
        !status("cumple")
            .case_is_measured(&corpus, &json!({"specification":"LANG.ABSENT","rule":"R1"}))
    );
    assert!(!status("cumple").case_is_measured(&corpus, &json!({})));
    Ok(())
}

#[test]
fn a_property_inherits_the_state_of_the_rule_it_declares() -> Result<(), String> {
    let corpus = corpus()?;
    assert!(status("pendiente").property_is_pending(&corpus, "LANG.TEST.SAMPLE@1.0.0#P1"));
    assert!(!status("cumple").property_is_pending(&corpus, "LANG.TEST.SAMPLE@1.0.0#P1"));
    Ok(())
}

#[test]
fn malformed_or_unknown_property_references_are_not_pending() -> Result<(), String> {
    let corpus = corpus()?;
    let pending = status("pendiente");
    assert!(!pending.property_is_pending(&corpus, "LANG.TEST.SAMPLE@1.0.0#P9"));
    assert!(!pending.property_is_pending(&corpus, "LANG.TEST.SAMPLE#P1"));
    assert!(!pending.property_is_pending(&corpus, ""));
    Ok(())
}

#[test]
fn a_property_of_an_exempt_rule_is_exempt_and_not_pending() -> Result<(), String> {
    let corpus = corpus()?;
    let exempt = status("exento");
    assert!(exempt.property_is_exempt(&corpus, "LANG.TEST.SAMPLE@1.0.0#P1"));
    assert!(!exempt.property_is_pending(&corpus, "LANG.TEST.SAMPLE@1.0.0#P1"));
    assert!(!status("cumple").property_is_exempt(&corpus, "LANG.TEST.SAMPLE@1.0.0#P1"));
    assert!(!exempt.property_is_exempt(&corpus, "LANG.TEST.SAMPLE@1.0.0#P9"));
    assert!(!exempt.property_is_exempt(&corpus, ""));
    Ok(())
}
