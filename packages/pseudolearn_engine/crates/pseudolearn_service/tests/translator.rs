use pseudolearn_lexicon::Profile;
use pseudolearn_service::{TranslationError, translate_source};
use pseudolearn_source::Span;

#[test]
fn translates_bilingual_round_trip() {
    let source_spanish =
        "Algoritmo Principal\n  Definir x Como Real <- rc(4.0);\n  Escribir x;\nFinAlgoritmo\n";
    let english = translate_source(source_spanish, Profile::English);
    assert!(english.is_ok());
    let Ok(english_text) = english else {
        return;
    };
    assert_eq!(
        english_text,
        "Algorithm Principal\n  Define x As Real <- sqrt(4.0);\n  Write x;\nEndAlgorithm\n"
    );
    let round_trip = translate_source(&english_text, Profile::Spanish);
    assert!(round_trip.is_ok());
    let Ok(back_spanish) = round_trip else {
        return;
    };
    assert_eq!(back_spanish, source_spanish);
}

#[test]
fn preserves_user_declarations_and_shadowed_names() {
    let source = "Algoritmo Sombras\n  Definir rc Como Real <- 5.0;\n  Definir total Como Entero <- redon(rc);\nFinAlgoritmo\n";
    assert_eq!(
        translate_source(source, Profile::English),
        Ok(String::from(
            "Algorithm Sombras\n  Define rc As Real <- 5.0;\n  Define total As Integer <- round(rc);\nEndAlgorithm\n"
        ))
    );
}

#[test]
fn detects_reserved_keyword_collisions() {
    let source = "Algorithm Colision\n  Define fin As Integer <- 0;\nEndAlgorithm\n";
    let result = translate_source(source, Profile::Spanish);
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
    let english = translate_source(source, Profile::English);
    assert!(english.is_ok());
    let Ok(english_text) = english else {
        return;
    };
    assert_eq!(english_text, "Algorithm Alias\nEndAlgorithm\n");
    let back_to_spanish = translate_source(&english_text, Profile::Spanish);
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
        translate_source(source, Profile::English),
        Ok(String::from(
            "Algorithm A\n  // Escribir si fin\n  Write \"Si Mientras\";\nEndAlgorithm\n"
        ))
    );
}

#[test]
fn translates_every_block_construct() {
    let source = "SubProceso Sumar(a Por Valor, b Por Referencia)\nFinSubProceso\nAlgoritmo A\n  Repetir\n    Escribir 1;\n  Hasta Que Verdadero\n  Para i <- 1 Hasta 3 Con Paso 1 Hacer\n    Escribir i Sin Saltar;\n  FinPara\n  Segun 1 Hacer\n    1: Escribir 1;\n    De Otro Modo:\n      Escribir 2;\n  FinSegun\nFinAlgoritmo\n";
    let english = translate_source(source, Profile::English);
    assert_eq!(
        english,
        Ok(String::from(
            "Subroutine Sumar(a By Value, b By Reference)\nEndSubroutine\nAlgorithm A\n  Repeat\n    Write 1;\n  Until True\n  For i <- 1 To 3 Step 1 Do\n    Write i Without Newline;\n  EndFor\n  Switch 1 Do\n    1: Write 1;\n    Otherwise:\n      Write 2;\n  EndSwitch\nEndAlgorithm\n"
        ))
    );
    let back = english.and_then(|text| translate_source(&text, Profile::Spanish));
    assert_eq!(back, Ok(source.to_owned()));
}

#[test]
fn reports_collision_with_the_exact_position_of_the_name() {
    let source = "Algoritmo A\n  Definir to Como Entero <- 0;\nFinAlgoritmo\n";
    let result = translate_source(source, Profile::English);
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
    let source = "Algoritmo A\n  Definir sqrt Como Real <- rc(4.0);\nFinAlgoritmo\n";
    assert!(matches!(
        translate_source(source, Profile::English),
        Err(TranslationError::Collision { .. })
    ));
}

#[test]
fn rejects_programs_with_syntax_errors() {
    let result = translate_source("Algoritmo A\n  Si x >\nFinAlgoritmo\n", Profile::English);
    assert!(matches!(result, Err(TranslationError::ParseFailure(_))));
}

#[test]
fn does_not_translate_member_names_after_a_dot() {
    let source = "Clase Caja\n  Definir contenido Como Entero;\nFinClase\nAlgoritmo A\n  Definir c Como Caja <- Nuevo Caja();\n  c.contenido <- 1;\nFinAlgoritmo\n";
    let english = translate_source(source, Profile::English);
    assert!(
        english
            .as_ref()
            .is_ok_and(|text| text.contains("c.contenido <- 1;"))
    );
}

#[test]
fn translates_nested_variant_types_and_explicit_consumption() -> Result<(), String> {
    let source = "Algoritmo Main\nDefinir outcome Como Resultado<Opcional<Entero>, Cadena> <- Exito(Algo(1));\nDescartar outcome;\nFinAlgoritmo\n";
    let english =
        translate_source(source, Profile::English).map_err(|error| format!("{error:?}"))?;
    assert!(
        english.contains("Result<Optional<Integer>, String>"),
        "{english}"
    );
    assert!(english.contains("Success(Some(1))"), "{english}");
    assert!(english.contains("Discard outcome"), "{english}");
    assert_eq!(
        translate_source(&english, Profile::Spanish),
        Ok(source.to_owned())
    );
    Ok(())
}

#[test]
fn translates_channel_type_constructor_and_methods() -> Result<(), String> {
    let source = "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nAguardar stream.Enviar(1);\nstream.Cerrar();\nFinAlgoritmo\n";
    let english =
        translate_source(source, Profile::English).map_err(|error| format!("{error:?}"))?;
    assert!(
        english.contains("Channel<Integer> <- channel(1)"),
        "{english}"
    );
    assert!(
        english.contains("stream.send(1)") && english.contains("stream.close()"),
        "{english}"
    );
    assert_eq!(
        translate_source(&english, Profile::Spanish),
        Ok(source.to_owned())
    );
    Ok(())
}

#[test]
fn keeps_user_methods_named_like_channel_operations() -> Result<(), String> {
    let source = "Clase Buzon\n  Metodo Enviar()\n  FinMetodo\nFinClase\nAlgoritmo P\n  Definir box Como Buzon <- Buzon();\n  box.Enviar();\nFinAlgoritmo\n";
    let english =
        translate_source(source, Profile::English).map_err(|error| format!("{error:?}"))?;
    assert!(english.contains("box.Enviar()"), "{english}");
    Ok(())
}

#[test]
fn translates_declared_variants_and_keeps_homonymous_names() -> Result<(), String> {
    let spanish = "Variante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Vacia\nFinVariante\nAlgoritmo Principal\nDefinir Variante Como Entero <- 1;\nEscribir Variante;\nFinAlgoritmo\n";
    let english = translate_source(spanish, Profile::English);
    let english_text = english.map_err(|error| format!("{error:?}"))?;
    assert_eq!(
        english_text,
        "Variant Forma\nCase Circulo(radio As Integer)\nCase Vacia\nEndVariant\nAlgorithm Principal\nDefine Variante As Integer <- 1;\nWrite Variante;\nEndAlgorithm\n"
    );
    assert_eq!(
        translate_source(&english_text, Profile::Spanish)
            .ok()
            .as_deref(),
        Some(spanish)
    );
    Ok(())
}

#[test]
fn translates_task_failure_fields_and_keeps_homonymous_user_fields() -> Result<(), String> {
    let source = "SubProceso Suspendible Work() Como Resultado<Entero, Cadena>\nRetornar Exito(1);\nFinSubProceso\nRegistro Marca\nDefinir Primero Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir marca Como Marca <- Marca(1);\nTareas failureReport\nLanzar Work();\nFinTareas\nSegun failureReport Hacer\nNada: Escribir marca.Primero;\nAlgo(problem): Escribir problem.Primero, problem.Canceladas;\nFinSegun\nFinAlgoritmo\n";
    let english =
        translate_source(source, Profile::English).map_err(|error| format!("{error:?}"))?;
    assert!(
        english.contains("problem.first, problem.cancelled"),
        "{english}"
    );
    assert!(english.contains("marca.Primero"), "{english}");
    assert_eq!(
        translate_source(&english, Profile::Spanish),
        Ok(source.to_owned())
    );
    Ok(())
}
