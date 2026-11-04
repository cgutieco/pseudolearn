use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{
    DocumentSession, HelpCertainty, HelpIdentityKind, HelpLocale, HelpQueryOutcome, HelpResolution,
    HoverCategory, help_content, resolve_help_at_position,
};

fn resolve(marked: &str, profile: Profile) -> Option<HelpQueryOutcome> {
    let (source, position) = split_cursor(marked);
    let document = DocumentSession::new(source, profile);
    resolve_help_at_position(&document, position)
}

fn identity(resolution: &HelpResolution) -> Option<(&HelpIdentityKind, &str, &str)> {
    resolution
        .identity
        .as_ref()
        .map(|entry| (&entry.kind, entry.id.as_str(), entry.role.as_str()))
}

fn card_id(marked: &str, profile: Profile) -> Option<String> {
    let result = resolve(marked, profile)?;
    help_content(&result, HelpLocale::English).map(|content| content.card_id.to_owned())
}

#[test]
fn compound_selection_preserves_the_full_lexeme_and_source_range() -> Result<(), String> {
    let program = "Algoritmo P\nPara i <- 1 Hasta 2 Con\tPaso 1 Hacer\nFinPara\nFinAlgoritmo\n";
    for marked in ["Con|\tPaso", "Con\t|Paso", "Con\tPas|o"] {
        let source = program.replace("Con\tPaso", marked);
        let result = resolve(&source, Profile::Spanish).ok_or("missing resolution")?;
        assert_eq!(
            identity(&result.resolution),
            Some((&HelpIdentityKind::Construction, "for", "step_clause"))
        );
        assert_eq!(result.resolution.certainty, HelpCertainty::Certain);
        assert_eq!(result.resolution.lexical_range.start.column, 21);
        assert_eq!(result.resolution.lexical_range.end.column, 29);
    }
    Ok(())
}

#[test]
fn until_and_for_boundaries_resolve_to_different_roles() -> Result<(), String> {
    let for_loop = "Algoritmo P\nPara i <- 1 Has|ta 2 Hacer\nFinPara\nFinAlgoritmo\n";
    let upper_bound = resolve(for_loop, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(
        identity(&upper_bound.resolution),
        Some((&HelpIdentityKind::Construction, "for", "range_limit"))
    );
    let repeat = "Algoritmo P\nRepetir\nHas|ta Que Verdadero\nFinAlgoritmo\n";
    let condition = resolve(repeat, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(
        identity(&condition.resolution),
        Some((&HelpIdentityKind::Construction, "repeat", "condition_start"))
    );
    assert_eq!(condition.resolution.lexical_range.start.column, 1);
    assert_eq!(condition.resolution.lexical_range.end.column, 10);
    Ok(())
}

#[test]
fn body_markers_resolve_in_for_while_and_switch() -> Result<(), String> {
    let examples = [
        (
            "Algoritmo P\nPara i <- 1 Hasta 2 Hac|er\nFinPara\nFinAlgoritmo\n",
            "for",
        ),
        (
            "Algoritmo P\nMientras Verdadero Hac|er\nFinMientras\nFinAlgoritmo\n",
            "while",
        ),
        (
            "Algoritmo P\nSegun 1 Hac|er\n1: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
            "switch",
        ),
    ];
    for (program, construction) in examples {
        let result = resolve(program, Profile::Spanish).ok_or("missing resolution")?;
        assert_eq!(
            identity(&result.resolution),
            Some((&HelpIdentityKind::Construction, construction, "body_start"))
        );
    }
    Ok(())
}

#[test]
fn parameter_passing_and_keyword_aliases_keep_stable_identity() -> Result<(), String> {
    let parameter = "SubProceso cambiar(valor Como Entero Por\tRef|erencia)\nFinSubProceso\nAlgoritmo P\nFinAlgoritmo\n";
    let reference = resolve(parameter, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(
        identity(&reference.resolution),
        Some((&HelpIdentityKind::Role, "parameter", "pass_by_reference"))
    );
    let alias = "Algoritmo P\nSi Verdadero Entonces\nEscribir 1;\nSi|No\nEscribir 2;\nFinSi\nFinAlgoritmo\n";
    let else_keyword = resolve(alias, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(
        identity(&else_keyword.resolution),
        Some((&HelpIdentityKind::Keyword, "elseKeyword", "keyword"))
    );
    Ok(())
}

#[test]
fn symbols_take_precedence_over_builtins_and_operators_are_resolved() -> Result<(), String> {
    let shadow = "Algoritmo P\nDefinir Longitud Como Entero;\nLongitud <- 2;\nEscribir Longi|tud;\nFinAlgoritmo\n";
    let user_symbol = resolve(shadow, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(user_symbol.resolution.identity, None);
    assert_eq!(
        user_symbol
            .resolution
            .symbol
            .as_ref()
            .map(|symbol| symbol.category.as_str()),
        Some("variable")
    );
    assert_eq!(
        user_symbol.hover.map(|hover| hover.category),
        Some(HoverCategory::Variable)
    );
    let builtin = "Algoritmo P\nEscribir Longi|tud(\"hola\");\nFinAlgoritmo\n";
    let intrinsic = resolve(builtin, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(
        identity(&intrinsic.resolution),
        Some((&HelpIdentityKind::Builtin, "length", "call"))
    );
    let operator = "Algoritmo P\nEscribir 1 +| 2;\nFinAlgoritmo\n";
    let addition = resolve(operator, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(
        identity(&addition.resolution),
        Some((&HelpIdentityKind::Operator, "plus", "binary"))
    );
    assert_eq!(addition.hover, None);
    Ok(())
}

#[test]
fn contextual_constructions_select_cards_by_their_resolved_identity() -> Result<(), String> {
    let imports = "Importar geo.Punto Como P;\nAlgoritmo Main\nFinAlgoritmo\n";
    let export = "Exportar geo.Punto;\nAlgoritmo Main\nFinAlgoritmo\n";
    let iteration = "Algoritmo Main\nPara Cada value En values Hacer\nFinPara\nFinAlgoritmo\n";
    let variants = "Algoritmo Main\nDefinir value Como Opcional<Entero>;\nFinAlgoritmo\n";
    let import = resolve(&imports.replace("Importar", "Im|portar"), Profile::Spanish)
        .ok_or("missing standalone import resolution")?;
    assert_eq!(import.token_identity.as_deref(), Some("importKeyword"));
    assert_eq!(
        identity(&import.resolution),
        Some((
            &HelpIdentityKind::Construction,
            "importDeclaration",
            "module_import"
        ))
    );
    assert_eq!(
        card_id(&imports.replace("Importar", "Im|portar"), Profile::Spanish).as_deref(),
        Some("help.module-import")
    );
    assert_eq!(
        card_id(&imports.replace("Como", "Co|mo"), Profile::Spanish).as_deref(),
        Some("help.module-import")
    );
    assert_eq!(
        card_id(&export.replace("Exportar", "Ex|portar"), Profile::Spanish).as_deref(),
        Some("help.module-export")
    );
    assert_eq!(
        card_id(&iteration.replace("Cada", "Ca|da"), Profile::Spanish).as_deref(),
        Some("construction.for_each")
    );
    assert_eq!(
        card_id(&iteration.replace("En", "E|n"), Profile::Spanish).as_deref(),
        Some("construction.for_each")
    );
    assert_eq!(
        card_id(&variants.replace("Opcional", "Opc|ional"), Profile::Spanish).as_deref(),
        Some("help.variants")
    );
    Ok(())
}

#[test]
fn function_literal_help_uses_the_closure_context() {
    let source = "SubProceso make(value Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nFinAlgoritmo\n";
    let marked = source.replace("Retornar SubProceso", "Retornar Sub|Proceso");
    assert_eq!(
        card_id(&marked, Profile::Spanish).as_deref(),
        Some("help.function-literal")
    );
}

#[test]
fn no_help_is_inferred_from_trivia_literals_comments_or_nearby_text() {
    for marked in [
        "Algoritmo P\nEscribir 4|2;\nFinAlgoritmo\n",
        "Algoritmo P\nEscribir 1;  |\nFinAlgoritmo\n",
        "Algoritmo P\nEscribir 1; // nota|\nFinAlgoritmo\n",
        "Algoritmo P\n| \nFinAlgoritmo\n",
        "",
    ] {
        assert!(resolve(marked, Profile::Spanish).is_none());
    }
}

#[test]
fn truncated_context_keeps_only_partial_lexical_certainty() -> Result<(), String> {
    let result =
        resolve("Algoritmo P\nMient|ras", Profile::Spanish).ok_or("missing lexical resolution")?;
    assert_eq!(
        identity(&result.resolution),
        Some((&HelpIdentityKind::Keyword, "whileKeyword", "keyword"))
    );
    assert_eq!(result.resolution.certainty, HelpCertainty::Partial);
    assert_eq!(result.resolution.enclosing_range, None);
    Ok(())
}

#[test]
fn profiles_keep_construction_identity() -> Result<(), String> {
    let programs = [
        (
            Profile::Spanish,
            "Algoritmo P\nPara i <- 1 Hasta 2 Con Paso 1 Hacer\nFinPara\nFinAlgoritmo\n",
            "Con Paso",
            "Con| Paso",
        ),
        (
            Profile::English,
            "Algorithm P\nFor i <- 1 To 2 Step 1 Do\nEndFor\nEndAlgorithm\n",
            "Step 1",
            "Step| 1",
        ),
    ];
    for (profile, program, phrase, marker) in programs {
        let marked = program.replacen(phrase, marker, 1);
        let result = resolve(&marked, profile).ok_or("missing resolution")?;
        assert_eq!(
            identity(&result.resolution),
            Some((&HelpIdentityKind::Construction, "for", "step_clause"))
        );
        assert_eq!(result.resolution.certainty, HelpCertainty::Certain);
    }
    Ok(())
}

#[test]
fn boolean_words_resolve_to_their_lexical_identity_and_other_literals_do_not() -> Result<(), String>
{
    let program = "Algoritmo P\nEscribir Verd|adero;\nEscribir Falso;\nEscribir 4;\nFinAlgoritmo\n";
    let result = resolve(program, Profile::Spanish).ok_or("missing resolution")?;
    assert_eq!(
        identity(&result.resolution),
        Some((&HelpIdentityKind::Keyword, "booleanTrue", "literal"))
    );
    assert_eq!(result.resolution.certainty, HelpCertainty::Certain);
    assert_eq!(result.token_identity.as_deref(), Some("booleanTrue"));
    let falsy = resolve(
        "Algoritmo P\nEscribir Fal|so;\nFinAlgoritmo\n",
        Profile::Spanish,
    )
    .ok_or("missing resolution")?;
    assert_eq!(
        identity(&falsy.resolution),
        Some((&HelpIdentityKind::Keyword, "booleanFalse", "literal"))
    );
    assert!(
        resolve(
            "Algoritmo P\nEscribir |4;\nFinAlgoritmo\n",
            Profile::Spanish
        )
        .is_none()
    );
    Ok(())
}

#[test]
fn collection_member_help_uses_the_exact_new_card() {
    let source = "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.so|rt();\nendAlgorithm\n";
    assert_eq!(
        card_id(source, Profile::English),
        Some("help.pgs02.vector_sort".to_owned())
    );
}
