use pseudolearn_lexicon::{BuiltinKind, KeywordKind, Profile};
use pseudolearn_service::help_catalog::{HelpLocale, token_description};
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{CompletionAction, CompletionEntry, DocumentSession};

fn complete_marked(marked: &str, profile: Profile) -> Vec<CompletionEntry> {
    let (clean, position) = split_cursor(marked);
    DocumentSession::new(clean, profile)
        .queries()
        .complete_with_edit(position)
        .entries
}

fn labels(entries: &[CompletionEntry]) -> Vec<&str> {
    entries.iter().map(|entry| entry.label.as_str()).collect()
}

fn offers(marked: &str, profile: Profile, label: &str) -> bool {
    labels(&complete_marked(marked, profile)).contains(&label)
}

#[test]
fn module_level_offers_declarations_and_imports() {
    for label in [
        "Importar",
        "Constante",
        "Registro",
        "Enumerado",
        "Interfaz",
        "Variante",
    ] {
        assert!(offers("|\n", Profile::Spanish, label), "{label}");
    }
    assert!(offers("|\n", Profile::English, "Record"));
    assert!(offers("|\n", Profile::English, "Import"));
}

#[test]
fn record_body_closes_with_its_own_closer_and_offers_no_control_flow() {
    let entries = complete_marked("Registro Punto\n  |\nFinRegistro\n", Profile::Spanish);
    assert!(!labels(&entries).contains(&"Mientras"));
    let open = complete_marked("Registro Punto\n  |\n", Profile::Spanish);
    assert_eq!(labels(&open).first(), Some(&"FinRegistro"));
    assert!(!labels(&open).contains(&"Hasta Que"));
}

#[test]
fn enum_select_and_tasks_blocks_close_with_their_own_closers() {
    let enumerated = complete_marked("Enumerado Color\n  |\n", Profile::Spanish);
    assert_eq!(labels(&enumerated).first(), Some(&"FinEnumerado"));
    let tasks = complete_marked("Algoritmo P\n  Tareas\n    |\n", Profile::Spanish);
    assert_eq!(labels(&tasks).first(), Some(&"FinTareas"));
}

#[test]
fn a_closed_record_no_longer_offers_its_closer() {
    let entries = complete_marked("Registro Punto\nFinRegistro\n|\n", Profile::Spanish);
    assert!(!labels(&entries).contains(&"FinRegistro"));
}

#[test]
fn type_slots_offer_library_and_declared_types() {
    let code = "Registro Punto\n  Definir x Como Entero;\nFinRegistro\nAlgoritmo P\n  Definir a Como |\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    for label in [
        "Vector",
        "Diccionario",
        "Opcional",
        "Resultado",
        "Punto",
        "Bytes",
        "Entero",
    ] {
        assert!(labels(&entries).contains(&label), "{label} missing");
    }
}

#[test]
fn standard_functions_insert_a_call_with_named_parameters() -> Result<(), String> {
    let entries = complete_marked(
        "Algoritmo P\n  Escribir tech|\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    let entry = entries
        .iter()
        .find(|entry| entry.label == "techo")
        .ok_or_else(|| format!("techo missing from {:?}", labels(&entries)))?;
    assert_eq!(entry.identity.as_deref(), Some("ceiling"));
    assert_eq!(
        entry.action,
        CompletionAction::Call {
            parameters: vec!["numero".to_owned()]
        }
    );
    Ok(())
}

#[test]
fn repeated_parameter_kinds_get_numbered_names() -> Result<(), String> {
    let entries = complete_marked(
        "Algoritmo P\n  Escribir reemplazar|\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    let entry = entries
        .iter()
        .find(|entry| entry.identity.as_deref() == Some("replaceAll"))
        .ok_or("replace function missing")?;
    let CompletionAction::Call { parameters } = &entry.action else {
        return Err("replace function is not a call".to_owned());
    };
    assert_eq!(parameters, &vec!["texto1", "texto2", "texto3"]);
    Ok(())
}

#[test]
fn expressions_offer_variants_await_and_capability_requests() {
    let code = "Algoritmo P\n  Definir a Como Entero <- |\nFinAlgoritmo\n";
    let entries = complete_marked(code, Profile::Spanish);
    for label in [
        "Algo",
        "Nada",
        "Exito",
        "Error",
        "Aguardar",
        "Lanzar",
        "SolicitarConsola",
    ] {
        assert!(labels(&entries).contains(&label), "{label} missing");
    }
}

#[test]
fn break_is_offered_only_inside_loops() {
    let inside = "Algoritmo P\n  Mientras Verdadero Hacer\n    |\n  FinMientras\nFinAlgoritmo\n";
    assert!(offers(inside, Profile::Spanish, "Salir"));
    assert!(!offers(
        "Algoritmo P\n  |\nFinAlgoritmo\n",
        Profile::Spanish,
        "Salir"
    ));
}

#[test]
fn headers_offer_their_follow_up_words() {
    assert!(offers(
        "Algoritmo P\n  Para |\nFinAlgoritmo\n",
        Profile::Spanish,
        "Cada"
    ));
    assert!(offers(
        "Clase Perro |\nFinClase\n",
        Profile::Spanish,
        "Hereda De"
    ));
    assert!(offers(
        "SubProceso Sumar(a Como Entero |)\nFinSubProceso\n",
        Profile::Spanish,
        "Por Valor"
    ));
    assert!(!offers(
        "SubProceso Sumar(|)\nFinSubProceso\n",
        Profile::Spanish,
        "Por Valor"
    ));
}

#[test]
fn super_is_offered_only_inside_methods() {
    let inside = "Clase A\n  Metodo m()\n    Escribir |\n  FinMetodo\nFinClase\n";
    assert!(offers(inside, Profile::Spanish, "Super"));
    assert!(!offers(
        "Algoritmo P\n  Escribir |\nFinAlgoritmo\n",
        Profile::Spanish,
        "Super"
    ));
}

#[test]
fn every_standard_function_has_a_catalog_description_in_both_locales() {
    for kind in BuiltinKind::all() {
        for locale in [HelpLocale::Spanish, HelpLocale::English] {
            let description = token_description(kind.as_str(), locale);
            assert!(
                description.is_some_and(|text| !text.trim().is_empty()),
                "{} has no description",
                kind.as_str()
            );
        }
    }
}

#[test]
fn every_named_keyword_has_a_catalog_description_in_both_locales() {
    for kind in KeywordKind::all() {
        let wordlike = kind.lexeme(Profile::Spanish).is_some_and(|word| {
            word.chars()
                .all(|glyph| glyph.is_alphabetic() || glyph == ' ')
        });
        if !wordlike {
            continue;
        }
        for locale in [HelpLocale::Spanish, HelpLocale::English] {
            assert!(
                token_description(kind.as_str(), locale).is_some(),
                "{} has no description",
                kind.as_str()
            );
        }
    }
}
