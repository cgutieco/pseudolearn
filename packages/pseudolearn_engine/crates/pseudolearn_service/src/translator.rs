use crate::formatter::{FormatOptions, format_source};
use pseudolearn_lexicon::Profile;
use std::collections::HashSet;

#[derive(Clone, Debug, PartialEq, Eq)]
pub enum TranslationError {
    Collision {
        identifier: String,
        diagnostic: String,
    },
    ParseFailure(String),
}

pub fn translate_source(
    text: &str,
    target_profile: Profile,
    strict: bool,
) -> Result<String, TranslationError> {
    let source_profile = match target_profile {
        Profile::Spanish => Profile::English,
        Profile::English => Profile::Spanish,
    };
    let user_identifiers = collect_user_declarations(text);
    validate_no_collision(&user_identifiers, target_profile)?;
    let mut translated_lines = Vec::new();
    for line in text.lines() {
        let translated =
            translate_single_line(line, source_profile, target_profile, &user_identifiers);
        translated_lines.push(translated);
    }
    let joined = translated_lines.join("\n");
    let options = FormatOptions {
        profile: target_profile,
        strict,
        indent_size: 2,
    };
    Ok(format_source(&joined, options))
}

fn collect_user_declarations(text: &str) -> HashSet<String> {
    let mut declarations = HashSet::new();
    for line in text.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("Definir") || trimmed.starts_with("Define") {
            let parts: Vec<&str> = trimmed.split_whitespace().collect();
            if let Some(&name) = parts.get(1) {
                let clean_name = name.trim_end_matches(',').trim_end_matches(';');
                declarations.insert(clean_name.to_owned());
            }
        }
    }
    declarations
}

fn validate_no_collision(
    user_identifiers: &HashSet<String>,
    target_profile: Profile,
) -> Result<(), TranslationError> {
    let reserved_words = reserved_words_for_profile(target_profile);
    for identifier in user_identifiers {
        let lower = identifier.to_lowercase();
        if reserved_words.contains(&lower.as_str()) {
            return Err(TranslationError::Collision {
                identifier: identifier.clone(),
                diagnostic: String::from("reservedLexemeUsedAsName"),
            });
        }
    }
    Ok(())
}

fn reserved_words_for_profile(profile: Profile) -> &'static [&'static str] {
    match profile {
        Profile::Spanish => spanish_reserved_words(),
        Profile::English => english_reserved_words(),
    }
}

fn spanish_reserved_words() -> &'static [&'static str] {
    &[
        "algoritmo",
        "finalgoritmo",
        "definir",
        "como",
        "entero",
        "real",
        "logico",
        "caracter",
        "cadena",
        "escribir",
        "leer",
        "si",
        "entonces",
        "sino",
        "finsi",
        "mientras",
        "hacer",
        "finmientras",
        "para",
        "hasta",
        "con",
        "paso",
        "finpara",
        "fin",
        "subproceso",
        "finsubproceso",
    ]
}

fn english_reserved_words() -> &'static [&'static str] {
    &[
        "algorithm",
        "endalgorithm",
        "define",
        "as",
        "integer",
        "real",
        "boolean",
        "character",
        "string",
        "write",
        "print",
        "read",
        "if",
        "then",
        "else",
        "endif",
        "while",
        "do",
        "endwhile",
        "for",
        "to",
        "step",
        "endfor",
        "end",
    ]
}

fn translate_single_line(
    line: &str,
    source_profile: Profile,
    target_profile: Profile,
    user_declarations: &HashSet<String>,
) -> String {
    let trimmed = line.trim();
    if trimmed.starts_with("//") {
        return line.to_owned();
    }
    let words: Vec<&str> = line.split(' ').collect();
    let mut translated_words = Vec::new();
    for word in words {
        let clean = word.trim_end_matches(';').trim_end_matches(',');
        if user_declarations.contains(clean) {
            translated_words.push(word.to_owned());
        } else {
            let translated = map_token(word, source_profile, target_profile);
            translated_words.push(translated);
        }
    }
    translated_words.join(" ")
}

fn map_token(token: &str, source_profile: Profile, target_profile: Profile) -> String {
    let suffix = if token.ends_with(';') {
        ";"
    } else if token.ends_with(',') {
        ","
    } else {
        ""
    };
    let clean = token.trim_end_matches(';').trim_end_matches(',');
    let (clean_ident, call_suffix) = if let Some(index) = clean.find('(') {
        let ident = clean.get(..index).unwrap_or(clean);
        let remainder = clean.get(index..).unwrap_or("");
        (ident, remainder)
    } else {
        (clean, "")
    };
    let mapped = match (source_profile, target_profile) {
        (Profile::Spanish, Profile::English) => translate_spanish_to_english(clean_ident),
        (Profile::English, Profile::Spanish) => translate_english_to_spanish(clean_ident),
        _ => clean_ident.to_owned(),
    };
    format!("{mapped}{call_suffix}{suffix}")
}

fn translate_spanish_to_english(word: &str) -> String {
    let pairs = [
        ("algoritmo", "Algorithm"),
        ("proceso", "Algorithm"),
        ("finalgoritmo", "EndAlgorithm"),
        ("finproceso", "EndAlgorithm"),
        ("definir", "Define"),
        ("como", "As"),
        ("entero", "Integer"),
        ("real", "Real"),
        ("logico", "Boolean"),
        ("caracter", "Character"),
        ("cadena", "String"),
        ("escribir", "Write"),
        ("leer", "Read"),
        ("si", "If"),
        ("entonces", "Then"),
        ("sino", "Else"),
        ("finsi", "EndIf"),
        ("mientras", "While"),
        ("hacer", "Do"),
        ("finmientras", "EndWhile"),
        ("para", "For"),
        ("hasta", "To"),
        ("rc", "sqrt"),
        ("raiz", "sqrt"),
        ("mayusculas", "uppercase"),
        ("minusculas", "lowercase"),
        ("longitud", "length"),
        ("subcadena", "substring"),
    ];
    for &(es_key, en_value) in &pairs {
        if word.eq_ignore_ascii_case(es_key) {
            return en_value.to_owned();
        }
    }
    word.to_owned()
}

fn translate_english_to_spanish(word: &str) -> String {
    let pairs = [
        ("algorithm", "Algoritmo"),
        ("endalgorithm", "FinAlgoritmo"),
        ("define", "Definir"),
        ("as", "Como"),
        ("integer", "Entero"),
        ("real", "Real"),
        ("boolean", "Logico"),
        ("character", "Caracter"),
        ("string", "Cadena"),
        ("write", "Escribir"),
        ("print", "Escribir"),
        ("read", "Leer"),
        ("if", "Si"),
        ("then", "Entonces"),
        ("else", "Sino"),
        ("endif", "FinSi"),
        ("while", "Mientras"),
        ("do", "Hacer"),
        ("endwhile", "FinMientras"),
        ("for", "Para"),
        ("to", "Hasta"),
        ("sqrt", "rc"),
        ("uppercase", "mayusculas"),
        ("lowercase", "minusculas"),
        ("length", "longitud"),
        ("substring", "subcadena"),
    ];
    for &(en_key, es_value) in &pairs {
        if word.eq_ignore_ascii_case(en_key) {
            return es_value.to_owned();
        }
    }
    word.to_owned()
}
