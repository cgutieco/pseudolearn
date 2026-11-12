use pseudolearn_lexicon::Profile;
use pseudolearn_service::translate_source;

const JSON_ERROR: &str = "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(\"{\");\nDefinir codigo Como Cadena <- \"\";\nSegun parsed Hacer\nExito(document): Escribir document.Tipo;\nError(problem): Escribir problem.Codigo;\nFinSegun\nEscribir codigo;\nFinAlgoritmo\n";

#[test]
fn translates_the_code_field_of_a_library_error() -> Result<(), String> {
    let english =
        translate_source(JSON_ERROR, Profile::English).map_err(|error| format!("{error:?}"))?;
    assert!(english.contains("Write problem.code;"), "{english}");
    assert!(english.contains("Define codigo As String"), "{english}");
    let spanish =
        translate_source(&english, Profile::Spanish).map_err(|error| format!("{error:?}"))?;
    assert_eq!(spanish, JSON_ERROR);
    Ok(())
}

#[test]
fn keeps_a_user_field_named_like_the_library_field() -> Result<(), String> {
    let source = "Registro Ficha\nDefinir Codigo Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir ficha Como Ficha;\nficha.Codigo <- 1;\nEscribir ficha.Codigo;\nFinAlgoritmo\n";
    let english =
        translate_source(source, Profile::English).map_err(|error| format!("{error:?}"))?;
    assert!(english.contains("ficha.Codigo <- 1;"), "{english}");
    assert!(!english.contains(".code"), "{english}");
    Ok(())
}

#[test]
fn keeps_a_member_without_a_receiver_type() -> Result<(), String> {
    let source = "Algoritmo P\nEscribir desconocido.Codigo;\nFinAlgoritmo\n";
    let english = translate_source(source, Profile::English).map_err(|error| format!("{error:?}"));
    assert!(english.is_err() || english.is_ok_and(|text| text.contains("desconocido.Codigo")));
    Ok(())
}
