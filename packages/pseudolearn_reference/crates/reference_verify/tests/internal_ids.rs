use reference_model::{Block, PublishedSection, Run, SectionKind};
use reference_verify::check_internal_ids;

fn section(text: &str) -> PublishedSection {
    PublishedSection {
        id: "prueba".to_owned(),
        number: "1".to_owned(),
        kind: SectionKind::Concept,
        title: Vec::new(),
        phrase: Vec::new(),
        blocks: vec![Block::Paragraph {
            runs: vec![Run::Text {
                text: text.to_owned(),
            }],
        }],
    }
}

#[test]
fn rejects_corpus_identifiers() {
    assert_eq!(
        check_internal_ids(&[section("Ver LANG.CONTROL.IF para más")]).len(),
        1
    );
    assert_eq!(check_internal_ids(&[section("La regla #R1 dice")]).len(), 1);
}

#[test]
fn accepts_ordinary_text() {
    assert!(check_internal_ids(&[section("PseudoLearn.LANG es un nombre, ENG. no")]).is_empty());
    assert!(check_internal_ids(&[section("")]).is_empty());
}
