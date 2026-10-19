use pseudolearn_lexicon::Profile;
use pseudolearn_service::{CompletionQuery, Position, complete_at_position, get_template};
use pseudolearn_source::SourceText;
use pseudolearn_syntax::parse_source;

#[test]
fn completes_types_after_como() {
    let code = "Algoritmo Principal\n  Definir total Como \nFinAlgoritmo\n";
    let source = SourceText::new(code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let query = CompletionQuery {
        source: &source,
        tree: &tree,
        analysis: None,
        position: Position {
            line: 2,
            column: 22,
        },
        profile: Profile::Spanish,
    };
    let candidates = complete_at_position(&query);
    let labels: Vec<&str> = candidates
        .iter()
        .map(|candidate| candidate.label.as_str())
        .collect();
    assert!(labels.contains(&"Entero"));
    assert!(labels.contains(&"Real"));
    assert!(labels.contains(&"Logico"));
    assert!(labels.contains(&"Caracter"));
    assert!(labels.contains(&"Cadena"));
    assert!(!labels.contains(&"Escribir"));
    assert!(!labels.contains(&"Mientras"));
}

#[test]
fn proposes_closing_token_for_unclosed_block() {
    let code = "Algoritmo Principal\n  Mientras x < 10 Hacer\n    \nFinAlgoritmo\n";
    let source = SourceText::new(code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let query = CompletionQuery {
        source: &source,
        tree: &tree,
        analysis: None,
        position: Position { line: 3, column: 5 },
        profile: Profile::Spanish,
    };
    let candidates = complete_at_position(&query);
    assert_eq!(
        candidates.first().map(|candidate| candidate.label.as_str()),
        Some("FinMientras")
    );
}

#[test]
fn returns_templates() {
    let spanish = get_template("switch", Profile::Spanish);
    assert_eq!(
        spanish,
        Some(String::from(
            "Segun expresion Hacer\n  Caso valor:\n    \n  De Otro Modo:\n    \nFinSegun"
        ))
    );
    let english = get_template("switch", Profile::English);
    assert_eq!(
        english,
        Some(String::from(
            "Switch expression Do\n  Case value:\n    \n  Otherwise:\n    \nEndSwitch"
        ))
    );
}

#[test]
fn suggests_bilingual_hint() {
    let code = "Algoritmo Principal\n  whi\nFinAlgoritmo\n";
    let source = SourceText::new(code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let query = CompletionQuery {
        source: &source,
        tree: &tree,
        analysis: None,
        position: Position { line: 2, column: 6 },
        profile: Profile::Spanish,
    };
    let candidates = complete_at_position(&query);
    let hint = candidates
        .iter()
        .find(|candidate| candidate.bilingual_origin.as_deref() == Some("while"));
    assert!(hint.is_some());
    let Some(candidate) = hint else {
        return;
    };
    assert_eq!(candidate.label, "Mientras");
}

#[test]
fn returns_empty_inside_comment() {
    let code = "Algoritmo Principal\n  // Escr\n  s <- \"Escr\";\nFinAlgoritmo\n";
    let source = SourceText::new(code.to_owned());
    let (tree, _) = parse_source(&source, Profile::Spanish);
    let query = CompletionQuery {
        source: &source,
        tree: &tree,
        analysis: None,
        position: Position {
            line: 2,
            column: 10,
        },
        profile: Profile::Spanish,
    };
    let candidates = complete_at_position(&query);
    assert!(candidates.is_empty());
}
