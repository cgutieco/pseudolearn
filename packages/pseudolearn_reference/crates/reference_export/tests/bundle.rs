use reference_export::{BundleInput, SectionMeta, build_bundle, parse_parts};
use reference_model::{Block, PublishedSection, Run, SectionKind};
use std::collections::BTreeMap;

fn section(identity: &str, number: &str) -> PublishedSection {
    PublishedSection {
        id: identity.to_owned(),
        number: number.to_owned(),
        kind: SectionKind::Construction,
        title: vec![Run::Text {
            text: format!("Título {number}"),
        }],
        phrase: Vec::new(),
        blocks: vec![Block::Heading {
            id: "uno".to_owned(),
            number: format!("{number}.1"),
            runs: vec![Run::Text {
                text: "Cómo".to_owned(),
            }],
        }],
    }
}

fn input<'input>(
    parts: &'input [reference_export::PartDefinition],
    sections: &'input [PublishedSection],
    metas: &'input [SectionMeta],
    links: &'input BTreeMap<String, BTreeMap<String, String>>,
) -> BundleInput<'input> {
    BundleInput {
        language: "es",
        profile: "en",
        corpus: "abc",
        engine: "0.1.0",
        parts,
        sections,
        metas,
        links,
    }
}

#[test]
fn builds_every_file_with_a_manifest() {
    let parts = parse_parts(r#"[{"id": "parte-6", "numero": "VI", "prefijo": "6", "titulo": "Control", "resumen": "Decidir"}]"#).unwrap_or_default();
    let sections = vec![
        section("control.si", "6.1"),
        section("tipos.primitivos", "3.1"),
    ];
    let metas = vec![SectionMeta {
        id: "control.si".to_owned(),
        terms: vec!["rama".to_owned()],
        card_titles: vec!["Decisión Si".to_owned()],
        diagnostics: vec!["nonBooleanCondition".to_owned()],
    }];
    let links = BTreeMap::new();
    let built = build_bundle(&input(&parts, &sections, &metas, &links));
    assert!(built.is_ok());
    let bundle = built.unwrap_or_default();
    let names: Vec<&String> = bundle.files.keys().collect();
    assert_eq!(names.len(), 6);
    let toc = bundle.files.get("toc.json").cloned().unwrap_or_default();
    assert!(toc.contains("control.si") && !toc.contains("tipos.primitivos"));
    let search = bundle.files.get("search.json").cloned().unwrap_or_default();
    assert!(
        search.contains("nonBooleanCondition")
            && search.contains("Decisión Si")
            && search.contains("\"anchor\":\"uno\"")
    );
    let manifest = bundle
        .files
        .get("manifest.json")
        .cloned()
        .unwrap_or_default();
    assert!(
        manifest.contains("\"format\":\"pseudolearn-reference/1\"")
            && manifest.contains("sections/control.si.json")
    );
}

#[test]
fn is_reproducible() {
    let sections = vec![section("control.si", "6.1")];
    let links = BTreeMap::new();
    let first = build_bundle(&input(&[], &sections, &[], &links));
    let second = build_bundle(&input(&[], &sections, &[], &links));
    assert_eq!(first, second);
}

#[test]
fn builds_an_empty_bundle() {
    let links = BTreeMap::new();
    let bundle = build_bundle(&input(&[], &[], &[], &links)).unwrap_or_default();
    assert_eq!(
        bundle.files.get("toc.json").map(String::as_str),
        Some("[]\n")
    );
}

#[test]
fn rejects_invalid_parts() {
    assert!(parse_parts("{").is_err());
    assert!(parse_parts(r#"[{"id": "x"}]"#).is_err());
}
