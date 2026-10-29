use super::{check, reference_corpus};
use see_validation::resources::help_catalog::coverage_matrix;
use see_validation::resources::help_catalog::references;
use serde_json::{Value, json};
use std::collections::BTreeSet;

#[test]
fn produces_complete_2026_identity_role_matrix() -> Result<(), String> {
    let corpus = reference_corpus()?;
    let catalog = catalog_value(&corpus)?;
    let matrix = coverage_matrix(&catalog, &corpus)?;
    assert!(matrix.iter().all(|row| row.destination.is_some()));
    assert_eq!(matrix.len(), 374);
    assert_eq!(identities(&matrix, "keyword").len(), 129);
    assert_eq!(identities(&matrix, "operator").len(), 17);
    assert_eq!(identities(&matrix, "builtin").len(), 72);
    assert_eq!(
        matrix
            .iter()
            .filter(|row| row.category == "keyword")
            .count(),
        139
    );
    assert_eq!(
        matrix
            .iter()
            .filter(|row| row.category == "operator")
            .count(),
        20
    );
    assert_eq!(
        matrix
            .iter()
            .filter(|row| row.category == "builtin")
            .count(),
        72
    );
    assert_eq!(
        matrix.iter().filter(|row| row.category == "token").count(),
        15
    );
    assert_eq!(
        matrix.iter().filter(|row| row.category == "role").count(),
        128
    );
    Ok(())
}

#[test]
fn resolves_aliases_through_their_source_identity() -> Result<(), String> {
    let corpus = reference_corpus()?;
    let catalog = catalog_value(&corpus)?;
    let matrix = coverage_matrix(&catalog, &corpus)?;
    let write_rows = matrix
        .iter()
        .filter(|row| row.category == "keyword" && row.identity == "write")
        .collect::<Vec<_>>();
    assert_eq!(write_rows.len(), 1);
    assert!(!matrix.iter().any(|row| row.identity == "print"));
    Ok(())
}

#[test]
fn rejects_missing_roles_and_accepts_a_typed_role_exclusion() -> Result<(), String> {
    let corpus = reference_corpus()?;
    let mut missing_catalog = catalog_value(&corpus)?;
    remove_card(&mut missing_catalog, "conditional_branch")?;
    let missing = references(&missing_catalog, &corpus);
    assert!(
        missing
            .iter()
            .any(|error| error.contains("uncovered role identity"))
    );

    let mut catalog = catalog_value(&corpus)?;
    append_role_alias(&mut catalog, "program_entry_alias", "program_entry")?;
    assert!(check(&catalog).is_ok());
    assert!(references(&catalog, &corpus).is_empty());
    Ok(())
}

#[test]
fn rejects_exclusions_that_do_not_name_an_inventory_role() -> Result<(), String> {
    let corpus = reference_corpus()?;
    let mut catalog = catalog_value(&corpus)?;
    append_role_alias(&mut catalog, "program_entry_alias", "program_entry")?;
    let exclusions = catalog
        .get_mut("exclusions")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing exclusions".to_owned())?;
    let exclusion = exclusions
        .first_mut()
        .ok_or_else(|| "Missing alias exclusion".to_owned())?;
    set(
        exclusion
            .get_mut("identity")
            .ok_or_else(|| "Missing exclusion identity".to_owned())?,
        "role",
        json!("unrelated_role"),
    )?;
    assert!(check(&catalog).is_err());
    let errors = references(&catalog, &corpus);
    assert!(
        errors
            .iter()
            .any(|error| error.contains("no declared inventory role"))
    );
    Ok(())
}

#[test]
fn rejects_an_alias_exclusion_that_changes_the_covered_tokens() -> Result<(), String> {
    let corpus = reference_corpus()?;
    let mut catalog = catalog_value(&corpus)?;
    append_role_alias(&mut catalog, "conditional_alias", "program_entry")?;
    let roles = catalog
        .pointer_mut("/inventory/roles")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing roles".to_owned())?;
    let alias = roles
        .last_mut()
        .ok_or_else(|| "Missing alias role".to_owned())?;
    set(
        alias,
        "tokens",
        json!(["ifKeyword", "then", "elseKeyword", "endIf"]),
    )?;
    assert!(check(&catalog).is_err());
    Ok(())
}

#[test]
fn rejects_missing_token_translation_and_duplicate_role_identity() -> Result<(), String> {
    let corpus = reference_corpus()?;
    let mut catalog = catalog_value(&corpus)?;
    let card = catalog
        .get_mut("cards")
        .and_then(Value::as_array_mut)
        .and_then(|cards| {
            cards.iter_mut().find(|card| {
                card.pointer("/identity/role").and_then(Value::as_str)
                    == Some("mathematical_builtin")
            })
        })
        .ok_or_else(|| "Missing mathematical card".to_owned())?;
    let english_parts = card
        .pointer_mut("/content/en/parts")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing English parts".to_owned())?;
    english_parts.retain(|part| part.get("identity").and_then(Value::as_str) != Some("squareRoot"));
    assert!(
        references(&catalog, &corpus)
            .iter()
            .any(|error| error.contains("uncovered role identity"))
    );

    let mut duplicate = catalog_value(&corpus)?;
    let first_role = duplicate
        .pointer("/inventory/roles/0")
        .cloned()
        .ok_or_else(|| "Missing inventory role".to_owned())?;
    duplicate
        .pointer_mut("/inventory/roles")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing roles".to_owned())?
        .push(first_role);
    assert!(check(&duplicate).is_err());
    Ok(())
}

fn catalog_value(corpus: &see_model::Corpus) -> Result<Value, String> {
    corpus
        .iter()
        .find(|specification| specification.metadata.id == "TOOL.SERVICE.CATALOG")
        .and_then(|specification| specification.blocks.last())
        .and_then(|definition| definition.fields.get("valor"))
        .cloned()
        .ok_or_else(|| "Missing catalog resource".to_owned())
}

fn identities<'rows>(
    rows: &'rows [see_validation::resources::help_catalog::CoverageRow],
    category: &str,
) -> BTreeSet<&'rows str> {
    rows.iter()
        .filter(|row| row.category == category)
        .map(|row| row.identity.as_str())
        .collect()
}

fn remove_card(catalog: &mut Value, role: &str) -> Result<Value, String> {
    let cards = catalog
        .get_mut("cards")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing cards".to_owned())?;
    let index = cards
        .iter()
        .position(|card| card.pointer("/identity/role").and_then(Value::as_str) == Some(role))
        .ok_or_else(|| "Missing role card".to_owned())?;
    Ok(cards.remove(index))
}

fn append_role_alias(catalog: &mut Value, role: &str, canonical_role: &str) -> Result<(), String> {
    let canonical = catalog
        .get("cards")
        .and_then(Value::as_array)
        .and_then(|cards| {
            cards.iter().find(|card| {
                card.pointer("/identity/role").and_then(Value::as_str) == Some(canonical_role)
            })
        })
        .ok_or_else(|| "Missing canonical card".to_owned())?;
    let availability = canonical
        .get("availability")
        .cloned()
        .ok_or_else(|| "Missing card availability".to_owned())?;
    let canonical_identity = canonical
        .get("identity")
        .cloned()
        .ok_or_else(|| "Missing canonical identity".to_owned())?;
    let identity = json!({
        "kind":"construction",
        "id":"algorithm",
        "role":role
    });
    append_inventory_role(catalog, &identity)?;
    append_alias_exclusion(catalog, identity, availability, canonical_identity)
}

fn append_inventory_role(catalog: &mut Value, identity: &Value) -> Result<(), String> {
    let roles = catalog
        .pointer_mut("/inventory/roles")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing roles".to_owned())?;
    roles.push(json!({
        "identity":identity,
        "productions":["algorithmUnit"],
        "tokens":["algorithm","endAlgorithm"]
    }));
    Ok(())
}

fn append_alias_exclusion(
    catalog: &mut Value,
    identity: Value,
    availability: Value,
    canonical_identity: Value,
) -> Result<(), String> {
    let exclusions = catalog
        .get_mut("exclusions")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing exclusions".to_owned())?;
    exclusions.push(json!({
        "id":"excluded.program-entry-alias",
        "identity":identity,
        "availability":availability,
        "reason":"alias_of",
        "alias_of":canonical_identity,
        "anchor":{"specification":"LANG.SYNTAX.GRAMMAR","version":"1.0.0","element":"D1"}
    }));
    Ok(())
}

fn set(value: &mut Value, name: &str, replacement: Value) -> Result<(), String> {
    let target = value
        .get_mut(name)
        .ok_or_else(|| format!("Missing field {name}"))?;
    *target = replacement;
    Ok(())
}
