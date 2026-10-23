use pseudolearn_lexicon::Profile;
use pseudolearn_service::help_catalog::{HelpLocale, cards, token_description};
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{DocumentSession, resolve_help_with_locale};

const MIGRATED_KEYWORDS: [&str; 28] = [
    "algorithm",
    "endAlgorithm",
    "subroutine",
    "endSubroutine",
    "classKeyword",
    "method",
    "endMethod",
    "declare",
    "dimension",
    "write",
    "read",
    "ifKeyword",
    "elseKeyword",
    "endIf",
    "whileKeyword",
    "endWhile",
    "forKeyword",
    "endFor",
    "repeat",
    "until",
    "switchKeyword",
    "endSwitch",
    "defaultCase",
    "returnKeyword",
    "newInstance",
    "thisObject",
    "byValue",
    "byReference",
];

const RETIRED_GENERIC_TEXTS: [&str; 2] = ["Palabra clave del lenguaje", "Language keyword"];

#[test]
fn every_migrated_keyword_has_a_description_in_both_locales() -> Result<(), String> {
    for identity in MIGRATED_KEYWORDS {
        for locale in [HelpLocale::Spanish, HelpLocale::English] {
            let text = token_description(identity, locale)
                .ok_or_else(|| format!("missing description for {identity}"))?;
            assert!(
                !text.trim().is_empty(),
                "{identity} has an empty description"
            );
        }
    }
    Ok(())
}

#[test]
fn spanish_and_english_descriptions_differ() -> Result<(), String> {
    for identity in MIGRATED_KEYWORDS {
        let spanish = token_description(identity, HelpLocale::Spanish).ok_or("missing es")?;
        let english = token_description(identity, HelpLocale::English).ok_or("missing en")?;
        assert_ne!(
            spanish, english,
            "{identity} reuses one text for both locales"
        );
    }
    Ok(())
}

#[test]
fn unknown_identity_has_no_description_instead_of_a_generic_one() {
    assert!(token_description("notAnIdentity", HelpLocale::Spanish).is_none());
    assert!(token_description("", HelpLocale::English).is_none());
}

#[test]
fn first_card_in_catalog_order_wins_for_shared_tokens() -> Result<(), String> {
    let first = cards()
        .iter()
        .find(|card| card.tokens.contains(&"method"))
        .ok_or("no card declares method")?;
    let expected = first
        .content(HelpLocale::Spanish)
        .parts
        .iter()
        .find(|part| part.identity == "method")
        .map(|part| part.text);
    assert_eq!(token_description("method", HelpLocale::Spanish), expected);
    Ok(())
}

#[test]
fn locale_is_independent_from_the_document_profile() -> Result<(), String> {
    let (source, position) =
        split_cursor("Algoritmo Principal\n  Mien|tras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n");
    let document = DocumentSession::new(source, Profile::Spanish, true);
    let description = |locale| {
        resolve_help_with_locale(&document, position, locale)
            .and_then(|outcome| outcome.hover)
            .and_then(|hover| hover.description)
    };
    assert_eq!(
        description(HelpLocale::English).as_deref(),
        token_description("whileKeyword", HelpLocale::English)
    );
    assert_eq!(
        description(HelpLocale::Spanish).as_deref(),
        token_description("whileKeyword", HelpLocale::Spanish)
    );
    Ok(())
}

#[test]
fn default_locale_follows_the_profile() -> Result<(), String> {
    let (source, position) =
        split_cursor("Algorithm Main\n  Wh|ile 1 = 1 Do\n  EndWhile\nEndAlgorithm\n");
    let document = DocumentSession::new(source, Profile::English, true);
    let hover = document.queries().hover(position).ok_or("missing hover")?;
    assert_eq!(
        hover.description.as_deref(),
        token_description("whileKeyword", HelpLocale::English)
    );
    Ok(())
}

#[test]
fn locale_codes_are_closed() {
    assert_eq!(HelpLocale::from_code("es"), Some(HelpLocale::Spanish));
    assert_eq!(HelpLocale::from_code("en"), Some(HelpLocale::English));
    assert_eq!(HelpLocale::from_code("fr"), None);
    assert_eq!(HelpLocale::from_code(""), None);
}

#[test]
fn service_sources_keep_no_parallel_editorial_table() -> Result<(), String> {
    let sources = std::fs::read_dir(concat!(env!("CARGO_MANIFEST_DIR"), "/src"))
        .map_err(|error| error.to_string())?;
    for entry in sources {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.extension().is_none_or(|extension| extension != "rs") {
            continue;
        }
        let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        for retired in RETIRED_GENERIC_TEXTS {
            assert!(
                !text.contains(retired),
                "{} keeps {retired}",
                path.display()
            );
        }
    }
    assert!(
        !std::path::Path::new(concat!(env!("CARGO_MANIFEST_DIR"), "/src/keyword_help.rs")).exists()
    );
    Ok(())
}
