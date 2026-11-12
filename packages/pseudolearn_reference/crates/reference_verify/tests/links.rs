use reference_model::{Block, PublishedSection, Run, SectionKind};
use reference_verify::check_links;

fn section(identity: &str, target: &str) -> PublishedSection {
    PublishedSection {
        id: identity.to_owned(),
        number: "1".to_owned(),
        kind: SectionKind::Concept,
        title: Vec::new(),
        phrase: Vec::new(),
        blocks: vec![Block::Callout {
            kind: reference_model::CalloutKind::Note,
            collapsible: false,
            blocks: vec![Block::Paragraph {
                runs: vec![Run::Link {
                    section: target.to_owned(),
                    text: "x".to_owned(),
                }],
            }],
        }],
    }
}

#[test]
fn accepts_links_to_known_sections() {
    assert!(check_links(&[section("a", "b"), section("b", "a")]).is_empty());
}

#[test]
fn rejects_links_to_unknown_sections() {
    assert_eq!(check_links(&[section("a", "nada")]).len(), 1);
}
