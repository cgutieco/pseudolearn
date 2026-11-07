use pseudolearn_lexicon::Profile;
use pseudolearn_service::{FormatOptions, format_source, translate_source};

fn translated(source: &str) -> Result<String, String> {
    translate_source(source, Profile::English).map_err(|error| format!("{error:?}"))
}

#[test]
fn a_constructor_call_nested_in_another_call_is_translated() -> Result<(), String> {
    let source = "Algoritmo P\nDefinir v Como Inmutable<Vector<Entero>> <- Instantanea(Vector());\nDefinir c Como Canal<Entero> <- Canal();\nFinAlgoritmo\n";
    let english = translated(source)?;
    assert!(english.contains("snapshot(vector())"));
    assert!(english.contains("<- channel()"));
    Ok(())
}

#[test]
fn a_constructor_call_is_translated_when_analysis_rejects_the_key() -> Result<(), String> {
    let source =
        "Algoritmo P\nDefinir d Como Diccionario<Real, Entero> <- Diccionario();\nFinAlgoritmo\n";
    assert!(translated(source)?.contains("<- dictionary()"));
    Ok(())
}

#[test]
fn a_member_named_like_a_collection_keeps_its_spelling() -> Result<(), String> {
    let source = "Clase Caja\nMetodo Vector() Como Entero\nRetornar 1;\nFinMetodo\nFinClase\nAlgoritmo P\nDefinir c Como Caja <- Nuevo Caja();\nEscribir c.Vector();\nFinAlgoritmo\n";
    assert!(translated(source)?.contains("c.Vector()"));
    Ok(())
}

#[test]
fn the_formatter_writes_the_lexeme_of_a_nested_constructor() {
    let source = "Algoritmo P\ndefinir v como inmutable<vector<entero>> <- instantanea(vector());\nFinAlgoritmo\n";
    let formatted = format_source(source, FormatOptions::default());
    assert!(formatted.contains("Instantanea(Vector())"));
}
