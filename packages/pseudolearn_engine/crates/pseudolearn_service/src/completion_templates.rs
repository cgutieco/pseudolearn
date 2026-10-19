use crate::spelling::keyword_spelling;
use pseudolearn_lexicon::{KeywordKind, Profile};

struct Markers {
    expression: &'static str,
    value: &'static str,
    condition: &'static str,
    index: &'static str,
    limit: &'static str,
    name: &'static str,
    parameter: &'static str,
    class_name: &'static str,
}

fn markers(profile: Profile) -> Markers {
    match profile {
        Profile::Spanish => Markers {
            expression: "expresion",
            value: "valor",
            condition: "condicion",
            index: "indice",
            limit: "limite",
            name: "nombre",
            parameter: "parametro",
            class_name: "Nombre",
        },
        Profile::English => Markers {
            expression: "expression",
            value: "value",
            condition: "condition",
            index: "index",
            limit: "limit",
            name: "name",
            parameter: "parameter",
            class_name: "Name",
        },
    }
}

pub fn template_constructions() -> &'static [&'static str] {
    &[
        "algorithm",
        "subroutine",
        "function",
        "class",
        "if",
        "while",
        "for",
        "repeat",
        "switch",
    ]
}

pub fn get_template(construction: &str, profile: Profile) -> Option<String> {
    let word = |kind| keyword_spelling(kind, profile);
    let marker = markers(profile);
    match construction {
        "switch" | "segun" => Some(switch_template(&word, &marker)),
        "if" | "si" => Some(if_template(&word, &marker)),
        "while" | "mientras" => Some(while_template(&word, &marker)),
        "for" | "para" => Some(for_template(&word, &marker)),
        "repeat" | "repetir" => Some(repeat_template(&word, &marker)),
        "function" | "funcion" => Some(function_template(&word, &marker)),
        "subroutine" | "subproceso" => Some(subroutine_template(&word, &marker)),
        "class" | "clase" => Some(class_template(&word, &marker)),
        "algorithm" | "algoritmo" => Some(algorithm_template(&word, &marker)),
        _ => None,
    }
}

type Word<'word> = &'word dyn Fn(KeywordKind) -> String;

fn switch_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {} {}\n  {}:\n    \n  {}:\n    \n{}",
        word(KeywordKind::SwitchKeyword),
        marker.expression,
        word(KeywordKind::DoKeyword),
        marker.value,
        word(KeywordKind::DefaultCase),
        word(KeywordKind::EndSwitch)
    )
}

fn if_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {} {}\n  \n{}\n  \n{}",
        word(KeywordKind::IfKeyword),
        marker.condition,
        word(KeywordKind::Then),
        word(KeywordKind::ElseKeyword),
        word(KeywordKind::EndIf)
    )
}

fn while_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {} {}\n  \n{}",
        word(KeywordKind::WhileKeyword),
        marker.condition,
        word(KeywordKind::DoKeyword),
        word(KeywordKind::EndWhile)
    )
}

fn for_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {} <- 1 {} {} {} 1 {}\n  \n{}",
        word(KeywordKind::ForKeyword),
        marker.index,
        word(KeywordKind::To),
        marker.limit,
        word(KeywordKind::Step),
        word(KeywordKind::DoKeyword),
        word(KeywordKind::EndFor)
    )
}

fn repeat_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{}\n  \n{} {}",
        word(KeywordKind::Repeat),
        word(KeywordKind::Until),
        marker.condition
    )
}

fn function_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {}({}) {} {}\n  \n{}",
        word(KeywordKind::Subroutine),
        marker.name,
        marker.parameter,
        word(KeywordKind::TypeConnector),
        word(KeywordKind::IntegerType),
        word(KeywordKind::EndSubroutine)
    )
}

fn subroutine_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {}({})\n  \n{}",
        word(KeywordKind::Subroutine),
        marker.name,
        marker.parameter,
        word(KeywordKind::EndSubroutine)
    )
}

fn class_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {}\n  \n{}",
        word(KeywordKind::ClassKeyword),
        marker.class_name,
        word(KeywordKind::EndClass)
    )
}

fn algorithm_template(word: Word<'_>, marker: &Markers) -> String {
    format!(
        "{} {}\n  \n{}",
        word(KeywordKind::Algorithm),
        marker.name,
        word(KeywordKind::EndAlgorithm)
    )
}

pub fn is_unit_construction(construction: &str) -> bool {
    matches!(
        construction,
        "algorithm" | "subroutine" | "function" | "class"
    )
}

pub fn construction_for(kind: KeywordKind) -> Option<&'static str> {
    match kind {
        KeywordKind::Algorithm => Some("algorithm"),
        KeywordKind::Subroutine => Some("subroutine"),
        KeywordKind::ClassKeyword => Some("class"),
        KeywordKind::IfKeyword => Some("if"),
        KeywordKind::WhileKeyword => Some("while"),
        KeywordKind::ForKeyword => Some("for"),
        KeywordKind::Repeat => Some("repeat"),
        KeywordKind::SwitchKeyword => Some("switch"),
        _ => None,
    }
}
