use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{SemanticOptions, analyze_for_service};
use pseudolearn_service::translate_source;
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

fn diagnostic_codes(text: &str, profile: Profile) -> Vec<String> {
    let source = SourceText::new(text.to_owned());
    let (tree, mut codes) = parse_source(&source, profile);
    let analysis = analyze_for_service(&tree, &source, SemanticOptions { profile });
    codes.extend(analysis.diagnostics);
    codes.iter().map(|code| format!("{:?}", code.code)).collect()
}

fn opposite(profile: Profile) -> Profile {
    match profile {
        Profile::Spanish => Profile::English,
        Profile::English => Profile::Spanish,
    }
}

fn translate_and_return(source: &str, profile: Profile) -> Result<String, String> {
    let target = opposite(profile);
    let translated =
        translate_source(source, target).map_err(|error| format!("translate: {error:?}"))?;
    assert_eq!(
        diagnostic_codes(&translated, target),
        diagnostic_codes(source, profile),
        "diagnostics changed:\n{translated}"
    );
    let returned =
        translate_source(&translated, profile).map_err(|error| format!("return: {error:?}"))?;
    assert_eq!(returned, source);
    Ok(translated)
}

const BYTES: &str = "Algoritmo P\n  Definir origen Como Bytes <- BytesDesdeTexto(\"ab\");\n  Definir parte Como Bytes <- origen.Segmento(0, 1);\n  Escribir parte.Longitud(), parte.En(0), parte.TextoUtf8(), parte.Unir(origen).Longitud();\nFinAlgoritmo\n";

const ENVIRONMENT: &str = "Algoritmo P\n  Definir reloj Como Reloj <- SolicitarReloj();\n  Definir espera Como Temporizador <- SolicitarTemporizador();\n  Definir raiz Como DirectorioCap <- SolicitarDirectorio(\"x\");\n  Definir hijo Como DirectorioCap <- raiz.Subdirectorio(\"y\");\n  Definir argumentos Como Argumentos <- SolicitarArgumentos();\n  Definir archivo Como ArchivoCap <- raiz.Abrir(\"a\", \"r\");\n  Escribir reloj.Ahora();\n  espera.Esperar(1);\n  argumentos.Valores();\n  archivo.Cerrar();\nFinAlgoritmo\n";

const NETWORK: &str = "Algoritmo P\n  Definir red Como RedCap <- SolicitarRed();\n  Definir pedido Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"u\");\n  Definir completo Como PeticionHttp <- pedido.ConCabecera(\"a\", \"b\").ConCuerpoTexto(\"x\");\n  Definir respuesta Como RespuestaHttp <- red.Enviar(completo);\n  Escribir respuesta.Estado(), respuesta.CuerpoTexto(), respuesta.EsExito();\n  red.Cerrar();\nFinAlgoritmo\n";

const JSON: &str = "Algoritmo P\n  Definir valor Como ValorJson <- JsonEntero(1);\n  Definir tipo Como TipoJson <- valor.Tipo();\n  Escribir valor.ComoEntero();\nFinAlgoritmo\n";

const IMMUTABLE: &str = "Algoritmo P\n  Definir valores Como Vector<Entero> <- Vector();\n  Definir copia Como Inmutable<Vector<Entero>> <- Instantanea(valores);\nFinAlgoritmo\n";

#[test]
fn bytes_operations_translate_in_both_directions() -> Result<(), String> {
    let english = translate_and_return(BYTES, Profile::Spanish)?;
    assert!(english.contains("bytesFromText(\"ab\")"));
    assert!(english.contains("source.segment(0, 1)") || english.contains(".segment(0, 1)"));
    assert!(english.contains(".utf8Text()"));
    assert!(english.contains(".join("));
    translate_and_return(&english, Profile::English).map(|_| ())
}

#[test]
fn environment_capability_operations_translate() -> Result<(), String> {
    let english = translate_and_return(ENVIRONMENT, Profile::Spanish)?;
    for word in [
        ".subdirectory(",
        ".open(",
        ".now()",
        ".wait(1)",
        ".values()",
        ".close()",
    ] {
        assert!(english.contains(word), "missing {word}:\n{english}");
    }
    Ok(())
}

#[test]
fn network_types_and_operations_translate() -> Result<(), String> {
    let english = translate_and_return(NETWORK, Profile::Spanish)?;
    for word in [
        "NetworkCap",
        "requestNetwork()",
        "HttpRequest(HttpMethod.GET",
        ".withHeader(",
        ".withTextBody(",
        "HttpResponse",
        ".send(",
        ".isSuccess()",
        ".close()",
    ] {
        assert!(english.contains(word), "missing {word}:\n{english}");
    }
    Ok(())
}

#[test]
fn english_source_translates_to_spanish() -> Result<(), String> {
    let english = translate_source(NETWORK, Profile::English)
        .map_err(|error| format!("{error:?}"))?;
    let spanish = translate_and_return(&english, Profile::English)?;
    assert_eq!(spanish, NETWORK);
    Ok(())
}

#[test]
fn json_operations_translate() -> Result<(), String> {
    let english = translate_and_return(JSON, Profile::Spanish)?;
    assert!(english.contains("jsonInteger(1)"));
    assert!(english.contains(".kind()"));
    assert!(english.contains(".asInteger()"));
    Ok(())
}

#[test]
fn immutable_types_translate_inside_generics() -> Result<(), String> {
    let english = translate_and_return(IMMUTABLE, Profile::Spanish)?;
    assert!(english.contains("immutable<"));
    assert!(!english.contains("Inmutable"));
    Ok(())
}

#[test]
fn empty_algorithm_has_nothing_to_translate() -> Result<(), String> {
    let source = "Algoritmo P\nFinAlgoritmo\n";
    translate_and_return(source, Profile::Spanish).map(|_| ())
}
