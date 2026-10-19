use pseudolearn_lexicon::Profile;
use pseudolearn_service::{TranslationError, translate_source};
use pseudolearn_source::Span;

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
    let source = "Algoritmo Sombras\n  Definir rc Como Real;\n  rc <- 5.0;\n  Definir total Como Entero;\n  total <- redon(rc);\nFinAlgoritmo\n";
    assert_eq!(
        translate_source(source, Profile::English, true),
        Ok(String::from(
            "Algorithm Sombras\n  Define rc As Real;\n  rc <- 5.0;\n  Define total As Integer;\n  total <- round(rc);\nEndAlgorithm\n"
        ))
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
            span: Span::new(28, 31),
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

#[test]
fn leaves_strings_and_comments_untouched() {
    let source = "Algoritmo A\n  // Escribir si fin\n  Escribir \"Si Mientras\";\nFinAlgoritmo\n";
    assert_eq!(
        translate_source(source, Profile::English, true),
        Ok(String::from(
            "Algorithm A\n  // Escribir si fin\n  Write \"Si Mientras\";\nEndAlgorithm\n"
        ))
    );
}

#[test]
fn translates_every_block_construct() {
    let source = "SubProceso Sumar(a Por Valor, b Por Referencia)\nFinSubProceso\nAlgoritmo A\n  Repetir\n    Escribir 1;\n  Hasta Que Verdadero\n  Para i <- 1 Hasta 3 Con Paso 1 Hacer\n    Escribir i Sin Saltar;\n  FinPara\n  Segun 1 Hacer\n    1: Escribir 1;\n    De Otro Modo:\n      Escribir 2;\n  FinSegun\nFinAlgoritmo\n";
    let english = translate_source(source, Profile::English, true);
    assert_eq!(
        english,
        Ok(String::from(
            "Subroutine Sumar(a By Value, b By Reference)\nEndSubroutine\nAlgorithm A\n  Repeat\n    Write 1;\n  Until True\n  For i <- 1 To 3 Step 1 Do\n    Write i Without Newline;\n  EndFor\n  Switch 1 Do\n    1: Write 1;\n    Otherwise:\n      Write 2;\n  EndSwitch\nEndAlgorithm\n"
        ))
    );
    let back = english.and_then(|text| translate_source(&text, Profile::Spanish, true));
    assert_eq!(back, Ok(source.to_owned()));
}

#[test]
fn reports_collision_with_the_exact_position_of_the_name() {
    let source = "Algoritmo A\n  Definir to Como Entero;\nFinAlgoritmo\n";
    let result = translate_source(source, Profile::English, true);
    assert_eq!(
        result,
        Err(TranslationError::Collision {
            identifier: String::from("to"),
            diagnostic: String::from("reservedLexemeUsedAsName"),
            span: Span::new(22, 24),
        })
    );
}

#[test]
fn reports_collision_between_user_name_and_translated_builtin() {
    let source = "Algoritmo A\n  Definir sqrt Como Real;\n  sqrt <- rc(4.0);\nFinAlgoritmo\n";
    assert!(matches!(
        translate_source(source, Profile::English, true),
        Err(TranslationError::Collision { .. })
    ));
}

#[test]
fn rejects_programs_with_syntax_errors() {
    let result = translate_source(
        "Algoritmo A\n  Si x >\nFinAlgoritmo\n",
        Profile::English,
        true,
    );
    assert!(matches!(result, Err(TranslationError::ParseFailure(_))));
}

#[test]
fn does_not_translate_member_names_after_a_dot() {
    let source = "Clase Caja\n  Definir contenido Como Entero;\nFinClase\nAlgoritmo A\n  Definir c Como Caja;\n  c <- Nuevo Caja();\n  c.contenido <- 1;\nFinAlgoritmo\n";
    let english = translate_source(source, Profile::English, true);
    assert!(
        english
            .as_ref()
            .is_ok_and(|text| text.contains("c.contenido <- 1;"))
    );
}
