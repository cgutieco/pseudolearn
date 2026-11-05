use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, HelpLocale, help_content, resolve_help_at_position};

const CLASS_FIELD: &str = "Registro Punto\nDefinir x Como Entero;\nFinRegistro\nClase Caja\nDefinir p Como Punto;\nDefinir n Como Entero;\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nDefinir Mutable r Como Punto <- Punto(1);\nDimension a[2] Como Punto;\nDimension m[2, 2] Como Punto;\nDimension e[2] Como Entero;\nc.p.x <- 1;\nc.n <- 2;\nr.x <- 3;\na[1].x <- 4;\nm[1, 2].x <- 5;\ne[1] <- 6;\nEscribir a[e[1]].x;\nFinAlgoritmo\n";

fn card_after(needle: &str, shift: usize) -> Option<String> {
    let index = CLASS_FIELD.find(needle)?.checked_add(shift)?;
    let marked = format!(
        "{}|{}",
        CLASS_FIELD.get(..index)?,
        CLASS_FIELD.get(index..)?
    );
    let (source, position) = split_cursor(&marked);
    let document = DocumentSession::new(source, Profile::Spanish);
    let outcome = resolve_help_at_position(&document, position)?;
    help_content(&outcome, HelpLocale::English).map(|content| content.card_id.to_owned())
}

const CLASS_CARD: &str = "help.pgl01.record_class_field";
const ARRAY_CARD: &str = "help.pgl01.record_array_element";

#[test]
fn the_dot_of_a_class_record_field_and_of_its_subfield_select_the_class_field_card() {
    assert_eq!(card_after("c.p.x", 1).as_deref(), Some(CLASS_CARD));
    assert_eq!(card_after("c.p.x", 3).as_deref(), Some(CLASS_CARD));
}

#[test]
fn the_dot_of_a_scalar_class_field_or_of_a_local_record_has_no_record_card() {
    assert_ne!(card_after("c.n", 1).as_deref(), Some(CLASS_CARD));
    assert_ne!(card_after("r.x", 1).as_deref(), Some(CLASS_CARD));
}

#[test]
fn both_brackets_of_a_record_array_element_select_the_array_element_card() {
    assert_eq!(card_after("a[1].x", 1).as_deref(), Some(ARRAY_CARD));
    assert_eq!(card_after("a[1].x", 3).as_deref(), Some(ARRAY_CARD));
    assert_eq!(card_after("m[1, 2].x", 1).as_deref(), Some(ARRAY_CARD));
    assert_eq!(card_after("m[1, 2].x", 6).as_deref(), Some(ARRAY_CARD));
}

#[test]
fn nested_brackets_resolve_each_array_by_its_own_element_type() {
    assert_eq!(card_after("a[e[1]]", 1).as_deref(), Some(ARRAY_CARD));
    assert_ne!(card_after("a[e[1]]", 3).as_deref(), Some(ARRAY_CARD));
    assert_ne!(card_after("a[e[1]]", 5).as_deref(), Some(ARRAY_CARD));
    assert_eq!(card_after("a[e[1]]", 6).as_deref(), Some(ARRAY_CARD));
}

#[test]
fn scalar_arrays_and_declaration_brackets_have_no_record_card() {
    assert_ne!(card_after("e[1] <-", 1).as_deref(), Some(ARRAY_CARD));
    assert_ne!(card_after("a[2] Como", 1).as_deref(), Some(ARRAY_CARD));
    assert_eq!(card_after("a[1].x", 4), None);
}
