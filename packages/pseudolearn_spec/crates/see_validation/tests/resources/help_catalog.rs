use see_validation::resources::check_references;
use see_validation::resources::help_catalog::{check, references};
use serde_json::{Value, json};

#[path = "help_catalog/coverage.rs"]
mod coverage;
#[path = "help_catalog/fixtures.rs"]
mod fixtures;
#[path = "../support/mod.rs"]
mod support;

#[test]
fn accepts_complete_and_minimal_catalog_cards() {
    let complete = sample_catalog();
    assert!(check(&complete).is_ok());
    let mut minimal = sample_catalog();
    for locale in ["es", "en"] {
        let path = format!("/cards/0/content/{locale}");
        for field in ["parts", "constraints", "common_errors", "examples"] {
            let field_path = format!("{path}/{field}");
            assert!(set(&mut minimal, &field_path, json!([])).is_ok());
        }
    }
    assert!(check(&minimal).is_ok());
}

#[test]
fn rejects_empty_catalogs_and_duplicate_cards() -> Result<(), String> {
    let mut empty = sample_catalog();
    assert!(set(&mut empty, "/cards", json!([])).is_ok());
    assert!(check(&empty).is_err());

    let mut duplicate = sample_catalog();
    let copy = duplicate
        .pointer("/cards/0")
        .cloned()
        .ok_or_else(|| "Missing sample card".to_owned())?;
    duplicate
        .get_mut("cards")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing cards".to_owned())?
        .push(copy);
    assert!(check(&duplicate).is_err_and(|error| error.contains("duplicate card")));
    Ok(())
}

#[test]
fn rejects_duplicate_source_roles_and_incompatible_availability() {
    let mut duplicate = sample_catalog();
    assert!(append_copy(&mut duplicate).is_ok());
    assert!(
        set(
            &mut duplicate,
            "/cards/1/id",
            json!("construct.sample.second")
        )
        .is_ok()
    );
    assert!(check(&duplicate).is_err());

    for (path, invalid) in [
        ("/cards/0/availability/editions/0", json!("2027")),
        ("/cards/0/availability/strictness/0", json!("unrestricted")),
    ] {
        let mut incompatible = sample_catalog();
        assert!(set(&mut incompatible, path, invalid).is_ok());
        assert!(check(&incompatible).is_err());
    }
}

#[test]
fn rejects_incomplete_translation_and_example_outside_availability() {
    let mut missing_translation = sample_catalog();
    if let Some(content) = missing_translation
        .pointer_mut("/cards/0/content")
        .and_then(Value::as_object_mut)
    {
        content.remove("en");
    }
    assert!(check(&missing_translation).is_err());

    let mut outside_scope = sample_catalog();
    assert!(
        set(
            &mut outside_scope,
            "/cards/0/availability/profiles",
            json!(["es"])
        )
        .is_ok()
    );
    assert!(check(&outside_scope).is_err());
}

#[test]
fn rejects_exclusion_that_overlaps_an_available_card() -> Result<(), String> {
    let mut catalog = sample_catalog();
    let identity = catalog
        .pointer("/cards/0/identity")
        .cloned()
        .ok_or_else(|| "Missing identity".to_owned())?;
    let availability = catalog
        .pointer("/cards/0/availability")
        .cloned()
        .ok_or_else(|| "Missing availability".to_owned())?;
    set(
        &mut catalog,
        "/exclusions",
        json!([{
            "id":"excluded.sample",
            "identity":identity,
            "availability":availability,
            "reason":"not_pedagogical",
            "anchor":{"specification":"LANG.SAMPLE","version":"1.0.0","element":"R1"}
        }]),
    )?;
    assert!(check(&catalog).is_err_and(|error| error.contains("overlaps")));
    Ok(())
}

#[test]
fn rejects_examples_outside_the_referenced_case_rigor() -> Result<(), String> {
    let corpus = vec![support::specification()?, vocabulary_specification()?];
    let mut catalog = sample_catalog();
    assert!(
        references(&catalog, &corpus)
            .iter()
            .any(|error| error.contains("stale example"))
    );
    for locale in ["es", "en"] {
        set(
            &mut catalog,
            &format!("/cards/0/content/{locale}/examples/0/strictness"),
            json!("flexible"),
        )?;
    }
    assert!(
        references(&catalog, &corpus)
            .iter()
            .all(|error| !error.contains("stale example"))
    );
    Ok(())
}

#[test]
fn resolves_exact_versions_and_rejects_stale_anchors() -> Result<(), String> {
    let mut corpus = reference_corpus()?;
    assert!(check_references(&corpus).is_empty());

    set(
        catalog_resource_mut(&mut corpus)?,
        "/cards/0/anchors/0/element",
        json!("R99"),
    )?;
    assert!(
        check_references(&corpus)
            .iter()
            .any(|error| error.contains("stale anchor"))
    );
    Ok(())
}

#[test]
fn rejects_missing_token_identities_and_nonlexical_sources() -> Result<(), String> {
    let mut missing_identity = reference_corpus()?;
    set(
        catalog_resource_mut(&mut missing_identity)?,
        "/cards/0/tokens/0/identity",
        json!("missingToken"),
    )?;
    assert!(has_stale_token_error(&missing_identity));

    let mut invalid_source = reference_corpus()?;
    let resource = catalog_resource_mut(&mut invalid_source)?;
    set(
        resource,
        "/cards/0/tokens/0/source/specification",
        json!("LANG.PROGRAM.STRUCTURE"),
    )?;
    set(resource, "/cards/0/tokens/0/source/element", json!("R1"))?;
    assert!(has_stale_token_error(&invalid_source));
    Ok(())
}

#[test]
fn rejects_references_to_retired_specifications() -> Result<(), String> {
    let mut retired = reference_corpus()?;
    let language = retired
        .iter_mut()
        .find(|specification| specification.metadata.id == "LANG.PROGRAM.STRUCTURE")
        .ok_or_else(|| "Missing language specification".to_owned())?;
    language.metadata.estado = "retirado".to_owned();
    let errors = check_references(&retired);
    assert!(errors.iter().any(|error| error.contains("stale anchor")));
    assert!(errors.iter().any(|error| error.contains("stale example")));
    Ok(())
}

fn vocabulary_specification() -> Result<see_model::Specification, String> {
    see_format::parsing::parse(
        "lang.profile.vocabulary.md",
        include_str!("../../../../specifications/lang/lang.profile.vocabulary.md"),
    )
}

fn reference_corpus() -> Result<see_model::Corpus, String> {
    let root = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../../specifications");
    let mut paths = Vec::new();
    collect_markdown_files(&root, &mut paths)?;
    let mut corpus = Vec::new();
    for path in paths {
        let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        let relative = path
            .strip_prefix(&root)
            .map_err(|error| error.to_string())?
            .display()
            .to_string();
        corpus.push(see_format::parsing::parse(&relative, &text)?);
    }
    Ok(corpus)
}

fn collect_markdown_files(
    directory: &std::path::Path,
    paths: &mut Vec<std::path::PathBuf>,
) -> Result<(), String> {
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_dir() {
            collect_markdown_files(&path, paths)?;
        } else if path.extension().is_some_and(|extension| extension == "md") {
            paths.push(path);
        }
    }
    Ok(())
}

fn catalog_resource_mut(corpus: &mut see_model::Corpus) -> Result<&mut Value, String> {
    corpus
        .iter_mut()
        .find(|specification| specification.metadata.id == "TOOL.SERVICE.CATALOG")
        .and_then(|specification| specification.blocks.last_mut())
        .and_then(|definition| definition.fields.get_mut("valor"))
        .ok_or_else(|| "Missing catalog resource".to_owned())
}

fn has_stale_token_error(corpus: &see_model::Corpus) -> bool {
    check_references(corpus)
        .iter()
        .any(|error| error.contains("stale token identity"))
}

fn append_copy(catalog: &mut Value) -> Result<(), String> {
    let copy = catalog
        .pointer("/cards/0")
        .cloned()
        .ok_or_else(|| "Missing sample card".to_owned())?;
    catalog
        .get_mut("cards")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing cards".to_owned())?
        .push(copy);
    Ok(())
}

fn set(value: &mut Value, path: &str, replacement: Value) -> Result<(), String> {
    let destination = value
        .pointer_mut(path)
        .ok_or_else(|| format!("Missing value at {path}"))?;
    *destination = replacement;
    Ok(())
}

fn sample_catalog() -> Value {
    json!({
        "format":"help-catalog/1",
        "inventory":{
            "operators":[],
            "roles":[{
                "identity":{"kind":"construction","id":"sample","role":"body"},
                "productions":["program"],
                "tokens":["algorithm"]
            }]
        },
        "cards":[{
            "id":"construct.sample",
            "identity":{"kind":"construction","id":"sample","role":"body"},
            "tokens":[{"identity":"algorithm","source":{"specification":"LANG.PROFILE.VOCABULARY","version":"1.0.0","element":"D1"}}],
            "availability":{"editions":["2026"],"profiles":["es","en"],"strictness":["estricto","flexible"]},
            "anchors":[{"specification":"LANG.TEST.SAMPLE","version":"1.0.0","element":"R1"}],
            "content":{
                "es":{"title":"Tema","summary":"Resumen","purpose":"Uso","parts":[{"identity":"algorithm","text":"Identifica el punto de entrada."}],"constraints":[],"common_errors":[],"examples":[{"specification":"LANG.TEST.SAMPLE","version":"1.0.0","case":"C1","profile":"es","strictness":"estricto","kind":"executable","label":"Ejemplo"}]},
                "en":{"title":"Topic","summary":"Summary","purpose":"Use","parts":[{"identity":"algorithm","text":"Names the entry point."}],"constraints":[],"common_errors":[],"examples":[{"specification":"LANG.TEST.SAMPLE","version":"1.0.0","case":"C1","profile":"en","strictness":"estricto","kind":"executable","label":"Example"}]}
            }
        }],
        "exclusions":[]
    })
}

#[test]
fn rejects_example_with_profile_different_from_its_locale() -> Result<(), String> {
    let mut catalog = sample_catalog();
    set(
        &mut catalog,
        "/cards/0/content/es/examples/0/profile",
        json!("en"),
    )?;
    assert!(check(&catalog).is_err_and(|error| error.contains("differs from its locale")));
    Ok(())
}

#[test]
fn rejects_repeated_example_reference_within_one_locale() -> Result<(), String> {
    let mut catalog = sample_catalog();
    let copy = catalog
        .pointer("/cards/0/content/en/examples/0")
        .cloned()
        .ok_or_else(|| "Missing example".to_owned())?;
    catalog
        .pointer_mut("/cards/0/content/en/examples")
        .and_then(Value::as_array_mut)
        .ok_or_else(|| "Missing examples".to_owned())?
        .push(copy);
    assert!(check(&catalog).is_err_and(|error| error.contains("duplicate example")));
    Ok(())
}

#[test]
fn rejects_example_kind_that_the_case_does_not_have() -> Result<(), String> {
    let mut corpus = reference_corpus()?;
    assert!(check_references(&corpus).is_empty());
    let resource = catalog_resource_mut(&mut corpus)?;
    set(
        resource,
        "/cards/0/content/es/examples/0/kind",
        json!("diagnostic"),
    )?;
    assert!(
        check_references(&corpus)
            .iter()
            .any(|error| error.contains("mismatched kind"))
    );
    Ok(())
}

#[test]
fn rejects_unknown_example_kind_and_cards_without_examples() -> Result<(), String> {
    let mut unknown = sample_catalog();
    set(
        &mut unknown,
        "/cards/0/content/es/examples/0/kind",
        json!("illustrative"),
    )?;
    assert!(check(&unknown).is_err());

    let mut corpus = reference_corpus()?;
    let resource = catalog_resource_mut(&mut corpus)?;
    set(resource, "/cards/0/content/en/examples", json!([]))?;
    assert!(
        check_references(&corpus)
            .iter()
            .any(|error| error.contains("has no en example"))
    );
    Ok(())
}

#[test]
fn every_2026_card_has_an_example_in_both_locales() -> Result<(), String> {
    let corpus = reference_corpus()?;
    assert!(
        check_references(&corpus)
            .iter()
            .all(|error| !error.contains("example"))
    );
    Ok(())
}
