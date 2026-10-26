use pseudolearn_lexicon::Profile;
use pseudolearn_service::{FormatOptions, format_source, translate_source};

#[test]
fn translating_contextual_forms_preserves_homonymous_variables() -> Result<(), String> {
    let source = "algorithm Main\ndefine interface as integer <- 1;\ndefine values as vector<integer> <- vector();\nvalues.append(interface);\nfor each element in values do\ndefer\nwrite element;\nendDefer\nbreak;\nendFor\nendAlgorithm\n";
    let translated =
        translate_source(source, Profile::Spanish, true).map_err(|error| format!("{error:?}"))?;
    assert!(translated.contains("Definir interface"));
    assert!(translated.contains("Vector<Entero>"));
    assert!(translated.contains(".Agregar(interface)"));
    assert!(translated.contains("Para Cada element En values"));
    assert!(translated.contains("Diferir"));
    Ok(())
}

#[test]
fn formatter_keeps_contextual_blocks_balanced_and_idempotent() {
    let source = "Interfaz Empty\nFinInterfaz\nAlgoritmo Main\nDiferir\nEscribir 1;\nFinDiferir\nFinAlgoritmo\n";
    let formatted = format_source(source, FormatOptions::default());
    assert!(formatted.contains("  Diferir\n    Escribir 1;\n  FinDiferir"));
    assert_eq!(
        format_source(&formatted, FormatOptions::default()),
        formatted
    );
}
