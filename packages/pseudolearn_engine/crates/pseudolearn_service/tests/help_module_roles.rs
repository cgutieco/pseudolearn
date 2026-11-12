use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, HelpLocale, help_content, resolve_help_at_position};

const MODULE: &str = "Registro Punto\nDefinir x Como Entero;\nFinRegistro\nEnumerado Color\nRojo\nFinEnumerado\nPublico SubProceso Mover(p Como Punto) Como Entero\nRetornar p.x;\nFinSubProceso\nPublico SubProceso Tono() Como Color\nRetornar Color.Rojo;\nFinSubProceso\nPublico SubProceso Doble(v Como Entero) Como Entero\nDefinir q Como Punto <- Punto(v);\nRetornar q.x * 2;\nFinSubProceso\nPublico Clase Caja\nDefinir p Como Punto;\nFinClase\nPublico Clase Vacia\nPrivado Definir p Como Punto;\nMetodo Contar() Como Entero\nDefinir q Como Punto <- Punto(1);\nRetornar q.x;\nFinMetodo\nFinClase\nPublico Registro Par\nDefinir a Como Punto;\nFinRegistro\n";

fn card_after(needle: &str, shift: usize) -> Option<String> {
    let index = MODULE.find(needle)?.checked_add(shift)?;
    let marked = format!("{}|{}", MODULE.get(..index)?, MODULE.get(index..)?);
    let (source, position) = split_cursor(&marked);
    let document = DocumentSession::new(source, Profile::Spanish);
    let outcome = resolve_help_at_position(&document, position)?;
    help_content(&outcome, HelpLocale::English, Profile::Spanish)
        .map(|content| content.card_id.to_owned())
}

const SIGNATURE_CARD: &str = "help.pgl02.public_signature";

#[test]
fn a_public_subprogram_naming_a_module_type_selects_the_signature_card() {
    assert_eq!(
        card_after("Publico SubProceso Mover", 2).as_deref(),
        Some(SIGNATURE_CARD)
    );
    assert_eq!(
        card_after("Publico SubProceso Tono", 2).as_deref(),
        Some(SIGNATURE_CARD)
    );
}

#[test]
fn a_public_class_with_a_public_member_of_a_module_type_selects_the_signature_card() {
    assert_eq!(
        card_after("Publico Clase Caja", 2).as_deref(),
        Some(SIGNATURE_CARD)
    );
}

#[test]
fn types_only_in_bodies_or_private_members_keep_the_module_unit_card() {
    assert_eq!(
        card_after("Publico SubProceso Doble", 2).as_deref(),
        Some("help.module-unit")
    );
    assert_eq!(
        card_after("Publico Clase Vacia", 2).as_deref(),
        Some("help.module-unit")
    );
}

#[test]
fn public_type_declarations_keep_the_type_visibility_card() {
    assert_eq!(
        card_after("Publico Registro Par", 2).as_deref(),
        Some("help.pgl02.type_visibility")
    );
}
