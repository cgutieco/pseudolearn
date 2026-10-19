use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, HoverCategory};

fn hover_at(
    marked: &str,
    profile: Profile,
    strict: bool,
) -> Option<pseudolearn_service::HoverOutcome> {
    let (clean, position) = split_cursor(marked);
    DocumentSession::new(clean, profile, strict)
        .queries()
        .hover(position)
}

#[test]
fn reports_declared_type_in_the_profile_language() -> Result<(), String> {
    let code =
        "Algoritmo Principal\n  Definir contador Como Entero;\n  con|tador <- 1;\nFinAlgoritmo\n";
    let outcome = hover_at(code, Profile::Spanish, true);
    let outcome = outcome.ok_or("expected hover")?;
    assert_eq!(outcome.type_name, "Entero");
    assert!(!outcome.is_inferred);
    assert_eq!(outcome.category, HoverCategory::Variable);

    let english = "Algorithm Main\n  Define counter As Integer;\n  cou|nter <- 1;\nEndAlgorithm\n";
    let outcome = hover_at(english, Profile::English, true);
    assert_eq!(
        outcome.map(|entry| entry.type_name),
        Some(String::from("Integer"))
    );
    Ok(())
}

#[test]
fn reports_inferred_types_in_flexible_mode() -> Result<(), String> {
    let code = "Algoritmo Principal\n  x| <- 3.14\nFinAlgoritmo\n";
    let outcome = hover_at(code, Profile::Spanish, false).ok_or("expected hover")?;
    assert_eq!(outcome.type_name, "Real");
    assert!(outcome.is_inferred);
    Ok(())
}

#[test]
fn describes_subroutines_with_passing_modes() -> Result<(), String> {
    let code = "SubProceso Intercambiar(a Por Referencia, b Por Valor)\nFinSubProceso\nAlgoritmo Principal\n  Intercam|biar(1, 2);\nFinAlgoritmo\n";
    let outcome = hover_at(code, Profile::Spanish, true).ok_or("expected hover")?;
    assert_eq!(outcome.category, HoverCategory::Procedure);
    assert_eq!(
        outcome.signature.as_deref(),
        Some("Intercambiar(a Por Referencia, b Por Valor)")
    );
    Ok(())
}

#[test]
fn describes_standard_functions_by_lexicon_signature() -> Result<(), String> {
    let code = "Algoritmo Principal\n  Definir n Como Entero;\n  n <- Long|itud(\"hola\");\nFinAlgoritmo\n";
    let outcome = hover_at(code, Profile::Spanish, true).ok_or("expected hover")?;
    assert!(outcome.is_intrinsic);
    assert_eq!(outcome.identifier, "Longitud");
    assert_eq!(
        outcome.signature.as_deref(),
        Some("Longitud(Cadena) Como Entero")
    );
    Ok(())
}

#[test]
fn does_not_report_shadowed_standard_functions_as_intrinsic() -> Result<(), String> {
    let code = "Algoritmo Principal\n  Definir rc Como Real;\n  r|c <- 1.0;\nFinAlgoritmo\n";
    let outcome = hover_at(code, Profile::Spanish, true).ok_or("expected hover")?;
    assert!(!outcome.is_intrinsic);
    assert_eq!(outcome.category, HoverCategory::Variable);
    Ok(())
}

#[test]
fn describes_keywords_in_the_profile_language() -> Result<(), String> {
    let code = "Algoritmo Principal\n  Mien|tras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n";
    let outcome = hover_at(code, Profile::Spanish, true).ok_or("expected hover")?;
    assert_eq!(outcome.category, HoverCategory::Keyword);
    assert!(
        outcome
            .description
            .is_some_and(|text| text.contains("Repite"))
    );
    Ok(())
}

#[test]
fn returns_nothing_over_literals_and_blank_space() {
    let code = "Algoritmo Principal\n  Escribir 4|2;\nFinAlgoritmo\n";
    assert!(hover_at(code, Profile::Spanish, true).is_none());
    let blank = "Algoritmo Principal\n |\nFinAlgoritmo\n";
    assert!(hover_at(blank, Profile::Spanish, true).is_none());
}

fn help_at(marked: &str) -> Option<pseudolearn_service::SignatureHelp> {
    let (clean, position) = split_cursor(marked);
    DocumentSession::new(clean, Profile::Spanish, true)
        .queries()
        .signature_help(position)
}

#[test]
fn tracks_the_active_parameter_of_a_call() -> Result<(), String> {
    let code = "SubProceso Intercambiar(a Por Referencia, b Por Valor)\nFinSubProceso\n\nAlgoritmo Principal\n  Definir x, z Como Entero;\n  Intercambiar(x, |);\nFinAlgoritmo\n";
    let help = help_at(code).ok_or("expected help")?;
    assert_eq!(help.active_parameter, 1);
    assert_eq!(
        help.signature,
        "Intercambiar(a Por Referencia, b Por Valor)"
    );
    assert_eq!(help.parameters.len(), 2);
    Ok(())
}

#[test]
fn ignores_commas_inside_nested_calls_for_the_active_parameter() -> Result<(), String> {
    let code = "SubProceso Sumar(a, b, c)\nFinSubProceso\n\nAlgoritmo Principal\n  Sumar(Longitud(\"x\"), 2|);\nFinAlgoritmo\n";
    let help = help_at(code).ok_or("expected help")?;
    assert_eq!(help.active_parameter, 1);
    Ok(())
}

#[test]
fn offers_help_for_standard_functions() -> Result<(), String> {
    let code = "Algoritmo Principal\n  Escribir Longitud(|);\nFinAlgoritmo\n";
    let help = help_at(code).ok_or("expected help")?;
    assert_eq!(help.active_parameter, 0);
    assert_eq!(help.signature, "Longitud(Cadena) Como Entero");
    Ok(())
}

#[test]
fn offers_no_help_outside_calls() {
    assert!(help_at("Algoritmo Principal\n  Escribir 1;|\nFinAlgoritmo\n").is_none());
    assert!(help_at("Algoritmo Principal\n  Escribir (1 + 2|);\nFinAlgoritmo\n").is_none());
}
