use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{
    DocumentSession, HelpCertainty, HelpIdentityKind, HelpQueryOutcome, HelpResolution,
    HoverCategory, resolve_help_at_position,
};

fn resolve(marked: &str, profile: Profile, strict: bool) -> Option<HelpQueryOutcome> {
    let (source, position) = split_cursor(marked);
    let document = DocumentSession::new(source, profile, strict);
    resolve_help_at_position(&document, position)
}

fn identity(resolution: &HelpResolution) -> Option<(&HelpIdentityKind, &str, &str)> {
    resolution
        .identity
        .as_ref()
        .map(|entry| (&entry.kind, entry.id.as_str(), entry.role.as_str()))
}

#[test]
fn compound_selection_preserves_the_full_lexeme_and_source_range() -> Result<(), String> {
    let program = "Algoritmo P\nPara i <- 1 Hasta 2 Con\tPaso 1 Hacer\nFinPara\nFinAlgoritmo\n";
    for marked in ["Con|\tPaso", "Con\t|Paso", "Con\tPas|o"] {
        let source = program.replace("Con\tPaso", marked);
        let result = resolve(&source, Profile::Spanish, true).ok_or("missing resolution")?;
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
    let upper_bound = resolve(for_loop, Profile::Spanish, true).ok_or("missing resolution")?;
    assert_eq!(
        identity(&upper_bound.resolution),
        Some((&HelpIdentityKind::Construction, "for", "range_limit"))
    );
    let repeat = "Algoritmo P\nRepetir\nHas|ta Que Verdadero\nFinAlgoritmo\n";
    let condition = resolve(repeat, Profile::Spanish, true).ok_or("missing resolution")?;
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
        let result = resolve(program, Profile::Spanish, true).ok_or("missing resolution")?;
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
    let reference = resolve(parameter, Profile::Spanish, true).ok_or("missing resolution")?;
    assert_eq!(
        identity(&reference.resolution),
        Some((&HelpIdentityKind::Role, "parameter", "pass_by_reference"))
    );
    let alias = "Algoritmo P\nSi Verdadero Entonces\nEscribir 1;\nSi|No\nEscribir 2;\nFinSi\nFinAlgoritmo\n";
    let else_keyword = resolve(alias, Profile::Spanish, true).ok_or("missing resolution")?;
    assert_eq!(
        identity(&else_keyword.resolution),
        Some((&HelpIdentityKind::Keyword, "elseKeyword", "keyword"))
    );
    Ok(())
}

#[test]
fn symbols_take_precedence_over_builtins_and_operators_are_resolved() -> Result<(), String> {
    let shadow = "Algoritmo P\nDefinir Longitud Como Entero;\nLongitud <- 2;\nEscribir Longi|tud;\nFinAlgoritmo\n";
    let user_symbol = resolve(shadow, Profile::Spanish, true).ok_or("missing resolution")?;
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
    let intrinsic = resolve(builtin, Profile::Spanish, true).ok_or("missing resolution")?;
    assert_eq!(
        identity(&intrinsic.resolution),
        Some((&HelpIdentityKind::Builtin, "length", "call"))
    );
    let operator = "Algoritmo P\nEscribir 1 +| 2;\nFinAlgoritmo\n";
    let addition = resolve(operator, Profile::Spanish, true).ok_or("missing resolution")?;
    assert_eq!(
        identity(&addition.resolution),
        Some((&HelpIdentityKind::Operator, "plus", "binary"))
    );
    assert_eq!(addition.hover, None);
    Ok(())
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
        assert!(resolve(marked, Profile::Spanish, true).is_none());
    }
}

#[test]
fn truncated_context_keeps_only_partial_lexical_certainty() -> Result<(), String> {
    let result = resolve("Algoritmo P\nMient|ras", Profile::Spanish, true)
        .ok_or("missing lexical resolution")?;
    assert_eq!(
        identity(&result.resolution),
        Some((&HelpIdentityKind::Keyword, "whileKeyword", "keyword"))
    );
    assert_eq!(result.resolution.certainty, HelpCertainty::Partial);
    assert_eq!(result.resolution.enclosing_range, None);
    Ok(())
}

#[test]
fn profile_and_strictness_matrix_keeps_construction_identity() -> Result<(), String> {
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
        for strict in [true, false] {
            let result = resolve(&marked, profile, strict).ok_or("missing resolution")?;
            assert_eq!(
                identity(&result.resolution),
                Some((&HelpIdentityKind::Construction, "for", "step_clause"))
            );
            assert_eq!(result.resolution.certainty, HelpCertainty::Certain);
        }
    }
    Ok(())
}

#[test]
fn boolean_words_resolve_to_their_lexical_identity_and_other_literals_do_not() -> Result<(), String>
{
    let program = "Algoritmo P\nEscribir Verd|adero;\nEscribir Falso;\nEscribir 4;\nFinAlgoritmo\n";
    let result = resolve(program, Profile::Spanish, true).ok_or("missing resolution")?;
    assert_eq!(
        identity(&result.resolution),
        Some((&HelpIdentityKind::Keyword, "booleanTrue", "literal"))
    );
    assert_eq!(result.resolution.certainty, HelpCertainty::Certain);
    assert_eq!(result.token_identity.as_deref(), Some("booleanTrue"));
    let falsy = resolve(
        "Algoritmo P\nEscribir Fal|so;\nFinAlgoritmo\n",
        Profile::Spanish,
        true,
    )
    .ok_or("missing resolution")?;
    assert_eq!(
        identity(&falsy.resolution),
        Some((&HelpIdentityKind::Keyword, "booleanFalse", "literal"))
    );
    assert!(
        resolve(
            "Algoritmo P\nEscribir |4;\nFinAlgoritmo\n",
            Profile::Spanish,
            true
        )
        .is_none()
    );
    Ok(())
}
