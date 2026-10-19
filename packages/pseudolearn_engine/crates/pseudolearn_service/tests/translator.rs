use pseudolearn_lexicon::Profile;
use pseudolearn_service::{TranslationError, translate_source};

#[test]
fn translates_bilingual_round_trip() {
    let source_spanish = "Algoritmo Principal\n  Definir x Como Real;\n  x <- rc(4.0);\n  Escribir x;\nFinAlgoritmo\n";
    let english = translate_source(source_spanish, Profile::English, true);
    assert!(english.is_ok());
    let Ok(english_text) = english else {
        return;
    };
    assert_eq!(
        english_text,
        "Algorithm Principal\n  Define x As Real;\n  x <- sqrt(4.0);\n  Write x;\nEndAlgorithm\n"
    );
    let round_trip = translate_source(&english_text, Profile::Spanish, true);
    assert!(round_trip.is_ok());
    let Ok(back_spanish) = round_trip else {
        return;
    };
    assert_eq!(back_spanish, source_spanish);
}

#[test]
fn preserves_user_declarations_and_shadowed_names() {
    let source = "Algoritmo Sombras\n  Definir longitud Como Entero;\n  longitud <- 5;\n  s <- mayusculas(\"texto\");\nFinAlgoritmo\n";
    let english = translate_source(source, Profile::English, true);
    assert!(english.is_ok());
    let Ok(english_text) = english else {
        return;
    };
    assert_eq!(
        english_text,
        "Algorithm Sombras\n  Define longitud As Integer;\n  longitud <- 5;\n  s <- uppercase(\"texto\");\nEndAlgorithm\n"
    );
}

#[test]
fn detects_reserved_keyword_collisions() {
    let source = "Algorithm Colision\n  Define fin As Integer;\nEndAlgorithm\n";
    let result = translate_source(source, Profile::Spanish, true);
    assert_eq!(
        result,
        Err(TranslationError::Collision {
            identifier: String::from("fin"),
            diagnostic: String::from("reservedLexemeUsedAsName"),
        })
    );
}

#[test]
fn translates_aliases_round_trip() {
    let source = "Proceso Alias\nFinProceso\n";
    let english = translate_source(source, Profile::English, true);
    assert!(english.is_ok());
    let Ok(english_text) = english else {
        return;
    };
    assert_eq!(english_text, "Algorithm Alias\nEndAlgorithm\n");
    let back_to_spanish = translate_source(&english_text, Profile::Spanish, true);
    assert!(back_to_spanish.is_ok());
    let Ok(back_text) = back_to_spanish else {
        return;
    };
    assert_eq!(back_text, "Algoritmo Alias\nFinAlgoritmo\n");
}
