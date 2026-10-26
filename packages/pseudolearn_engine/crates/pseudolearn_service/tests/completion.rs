use pseudolearn_lexicon::Profile;
use pseudolearn_service::marked_text::split_cursor;
use pseudolearn_service::{CompletionEntry, DocumentSession};
use pseudolearn_service::{
    CompletionKind, get_template, template_constructions, template_parses_cleanly, template_program,
};

fn complete_marked(marked: &str, profile: Profile) -> Vec<CompletionEntry> {
    let (clean, position) = split_cursor(marked);
    DocumentSession::new(clean, profile, true)
        .queries()
        .complete_with_edit(position)
        .entries
}

fn labels(entries: &[CompletionEntry]) -> Vec<&str> {
    entries.iter().map(|entry| entry.label.as_str()).collect()
}

#[test]
fn offers_primitive_types_and_declared_classes_after_como() {
    let code = "Clase Punto\n  Definir x Como Entero;\nFinClase\nAlgoritmo Principal\n  Definir total Como |\nFinAlgoritmo\n";
    let candidates = complete_marked(code, Profile::Spanish);
    let names = labels(&candidates);
    for expected in ["Entero", "Real", "Logico", "Caracter", "Cadena", "Punto"] {
        assert!(names.contains(&expected), "missing {expected}: {names:?}");
    }
    assert!(!names.contains(&"Escribir"));
    assert!(!names.contains(&"Mientras"));
    assert!(!names.contains(&"total"));
}

#[test]
fn proposes_the_closer_of_the_innermost_open_block_first() {
    let code = "Algoritmo Principal\n  Mientras x < 10 Hacer\n    |\nFinAlgoritmo\n";
    let candidates = complete_marked(code, Profile::Spanish);
    assert_eq!(labels(&candidates).first(), Some(&"FinMientras"));
}

#[test]
fn closes_every_block_kind_in_both_profiles() {
    let cases = [
        ("Algoritmo A\n  Si 1 = 1 Entonces\n    |", "FinSi"),
        ("Algoritmo A\n  Para i <- 1 Hasta 3 Hacer\n    |", "FinPara"),
        ("Algoritmo A\n  Segun 1 Hacer\n    |", "FinSegun"),
        ("Algoritmo A\n  Repetir\n    |", "Hasta Que"),
        ("Algoritmo A\n  |", "FinAlgoritmo"),
        ("SubProceso F()\n  |", "FinSubProceso"),
        ("Clase C\n  |", "FinClase"),
    ];
    for (code, closer) in cases {
        let candidates = complete_marked(code, Profile::Spanish);
        assert_eq!(labels(&candidates).first(), Some(&closer), "{code}");
    }
    let english = complete_marked("Algorithm A\n  If 1 = 1 Then\n    |", Profile::English);
    assert_eq!(labels(&english).first(), Some(&"EndIf"));
}

#[test]
fn filters_by_prefix_and_ranks_locals_before_keywords() {
    let code = "Algoritmo Principal\n  Definir Mutable total Como Entero <- 0;\n  Esc|\nFinAlgoritmo\n";
    let candidates = complete_marked(code, Profile::Spanish);
    assert_eq!(labels(&candidates).first(), Some(&"Escribir"));
    let code = "Algoritmo Principal\n  Definir Mutable total Como Entero <- 0;\n  to|\nFinAlgoritmo\n";
    let candidates = complete_marked(code, Profile::Spanish);
    assert_eq!(labels(&candidates).first(), Some(&"total"));
}

#[test]
fn offers_members_of_the_receiver_class_and_its_superclasses() {
    let code = "Clase Base\n  Definir peso Como Entero;\nFinClase\nClase Punto Hereda De Base\n  Definir x Como Entero;\n  Metodo Mover()\n  FinMetodo\nFinClase\nAlgoritmo Principal\n  Definir Mutable p Como Punto <- Nuevo Punto();\n  Definir Mutable otro Como Entero <- 0;\n  p.|\nFinAlgoritmo\n";
    let candidates = complete_marked(code, Profile::Spanish);
    let names = labels(&candidates);
    assert!(names.contains(&"x"), "{names:?}");
    assert!(names.contains(&"Mover"), "{names:?}");
    assert!(names.contains(&"peso"), "{names:?}");
    assert!(!names.contains(&"otro"));
    assert!(!names.contains(&"Escribir"));
    let kinds: Vec<CompletionKind> = candidates.iter().map(|entry| entry.kind).collect();
    assert!(kinds.contains(&CompletionKind::Field));
    assert!(kinds.contains(&CompletionKind::Method));
}

#[test]
fn offers_nothing_for_members_of_unknown_receivers() {
    let code = "Algoritmo Principal\n  Definir Mutable n Como Entero <- 0;\n  n.|\nFinAlgoritmo\n";
    assert!(complete_marked(code, Profile::Spanish).is_empty());
}

#[test]
fn offers_follow_up_keywords_after_a_complete_expression() {
    let code = "Algoritmo Principal\n  Definir Mutable n Como Entero <- 0;\n  Si n > 0 En|\nFinAlgoritmo\n";
    let candidates = complete_marked(code, Profile::Spanish);
    assert_eq!(labels(&candidates).first(), Some(&"Entonces"));
}

#[test]
fn suggests_the_active_profile_keyword_for_the_other_language() {
    let candidates = complete_marked(
        "Algoritmo Principal\n  whi|\nFinAlgoritmo\n",
        Profile::Spanish,
    );
    let hint = candidates
        .iter()
        .find(|candidate| candidate.bilingual_origin.as_deref() == Some("while"));
    assert_eq!(
        hint.map(|candidate| candidate.label.as_str()),
        Some("Mientras")
    );
    let reverse = complete_marked("Algorithm Main\n  mie|\nEndAlgorithm\n", Profile::English);
    let origin = reverse
        .iter()
        .find(|candidate| candidate.bilingual_origin.is_some());
    assert_eq!(
        origin.map(|candidate| candidate.label.as_str()),
        Some("While")
    );
}

#[test]
fn offers_nothing_inside_comments_and_string_literals() {
    assert!(
        complete_marked(
            "Algoritmo Principal\n  // Escr|\nFinAlgoritmo\n",
            Profile::Spanish
        )
        .is_empty()
    );
    assert!(
        complete_marked(
            "Algoritmo Principal\n  Escribir \"Escr|\";\nFinAlgoritmo\n",
            Profile::Spanish
        )
        .is_empty()
    );
    assert!(
        complete_marked(
            "Algoritmo Principal\n  Escribir \"sin cierre|\n",
            Profile::Spanish
        )
        .is_empty()
    );
}

#[test]
fn offers_unit_templates_outside_any_unit() {
    let candidates = complete_marked("|\n", Profile::Spanish);
    let names = labels(&candidates);
    assert_eq!(names, vec!["Algoritmo", "Clase", "SubProceso"]);
}

#[test]
fn hides_the_identifier_being_typed() {
    let code = "Algoritmo Principal\n  tot|\nFinAlgoritmo\n";
    let candidates = complete_marked(code, Profile::Spanish);
    assert!(!labels(&candidates).contains(&"tot"));
}

#[test]
fn is_deterministic_for_the_same_document_and_cursor() {
    let code = "Algoritmo Principal\n  Definir Mutable a Como Entero <- 0;\n  Definir Mutable b Como Entero <- 0;\n  |\nFinAlgoritmo\n";
    let first = complete_marked(code, Profile::Spanish);
    let second = complete_marked(code, Profile::Spanish);
    assert_eq!(first, second);
}

#[test]
fn templates_are_localized_and_use_the_profile_vocabulary() {
    assert_eq!(
        get_template("switch", Profile::Spanish),
        Some(String::from(
            "Segun expresion Hacer\n  valor:\n    \n  De Otro Modo:\n    \nFinSegun"
        ))
    );
    assert_eq!(
        get_template("switch", Profile::English),
        Some(String::from(
            "Switch expression Do\n  value:\n    \n  Otherwise:\n    \nEndSwitch"
        ))
    );
    assert_eq!(get_template("unknown", Profile::Spanish), None);
}

#[test]
fn every_template_parses_without_errors_in_its_valid_position() {
    for profile in [Profile::Spanish, Profile::English] {
        for construction in template_constructions() {
            assert!(
                template_parses_cleanly(construction, profile),
                "{construction} {profile:?}: {:?}",
                template_program(construction, profile)
            );
        }
    }
}
