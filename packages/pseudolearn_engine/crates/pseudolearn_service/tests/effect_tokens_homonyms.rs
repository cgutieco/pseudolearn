use pseudolearn_lexicon::Profile;
use pseudolearn_service::translate_source;

fn translate(source: &str) -> Result<String, String> {
    translate_source(source, Profile::English).map_err(|error| format!("{error:?}"))
}

#[test]
fn variables_named_like_library_words_keep_their_names() -> Result<(), String> {
    let source = "Algoritmo P\n  Definir Segmento Como Entero <- 1;\n  Definir Reloj Como Entero <- 2;\n  Definir Estado Como Entero <- 3;\n  Escribir Segmento + Reloj + Estado;\nFinAlgoritmo\n";
    let english = translate(source)?;
    assert!(english.contains("Define Segmento As Integer"));
    assert!(english.contains("Define Reloj As Integer"));
    assert!(english.contains("Define Estado As Integer"));
    Ok(())
}

#[test]
fn user_methods_named_like_library_operations_keep_their_names() -> Result<(), String> {
    let source = "Clase Cliente\n    Publico Metodo Segmento() Como Entero\n        Retornar 1;\n    FinMetodo\n    Publico Metodo Estado() Como Entero\n        Retornar 2;\n    FinMetodo\n    Publico Metodo Enviar() Como Entero\n        Retornar 3;\n    FinMetodo\n    Publico Metodo Cerrar() Como Entero\n        Retornar 4;\n    FinMetodo\nFinClase\n\nProceso Principal\n    Definir cliente Como Cliente <- Nuevo Cliente();\n    Escribir cliente.Segmento(), cliente.Estado(), cliente.Enviar(), cliente.Cerrar();\nFinProceso\n";
    let english = translate(source)?;
    for word in [".Segmento()", ".Estado()", ".Enviar()", ".Cerrar()"] {
        assert!(english.contains(word), "missing {word}:\n{english}");
    }
    Ok(())
}

#[test]
fn user_class_named_like_a_library_type_keeps_its_declaration() -> Result<(), String> {
    let source = "Clase PeticionHttp\n    Publico Definir cuerpo Como Entero;\nFinClase\n\nProceso Principal\n    Definir cuerpo Como Entero <- 1;\n    Escribir cuerpo;\nFinProceso\n";
    let english = translate(source)?;
    assert!(english.contains("Class PeticionHttp"), "{english}");
    Ok(())
}

#[test]
fn variable_named_like_the_http_method_type_keeps_its_name() -> Result<(), String> {
    let source = "Registro Datos\n    Definir valor Como Entero;\nFinRegistro\n\nAlgoritmo P\n  Definir MetodoHttp Como Datos <- Datos(1);\n  Escribir MetodoHttp.valor;\nFinAlgoritmo\n";
    let english = translate(source)?;
    assert!(english.contains("Define MetodoHttp"), "{english}");
    assert!(english.contains("Write MetodoHttp.valor"), "{english}");
    Ok(())
}
