use pseudolearn_lexicon::Profile;

pub fn should_append_semicolon(line: &str, strict: bool) -> bool {
    if !strict {
        return false;
    }
    let lower = line.to_lowercase();
    let is_block_header = lower.starts_with("algoritmo")
        || lower.starts_with("algorithm")
        || lower.starts_with("subproceso")
        || lower.starts_with("subprocedure")
        || lower.starts_with("funcion")
        || lower.starts_with("function")
        || lower.starts_with("clase")
        || lower.starts_with("class")
        || lower.starts_with("si ")
        || lower.starts_with("if ")
        || lower.starts_with("mientras ")
        || lower.starts_with("while ")
        || lower.starts_with("para ")
        || lower.starts_with("for ")
        || lower.starts_with("segun ")
        || lower.starts_with("switch ")
        || lower.starts_with("repetir")
        || lower.starts_with("repeat");
    let is_block_closer = lower.starts_with("fin")
        || lower.starts_with("end")
        || lower.starts_with("sino")
        || lower.starts_with("else");
    !is_block_header && !is_block_closer
}

pub fn normalize_operators(line: &str) -> String {
    let mut result = String::new();
    let mut characters = line.chars().peekable();
    while let Some(character) = characters.next() {
        match character {
            '<' if characters.peek() == Some(&'-') => {
                characters.next();
                trim_trailing_spaces(&mut result);
                result.push_str(" <- ");
            }
            '+' | '-' | '*' | '/' | '=' => {
                trim_trailing_spaces(&mut result);
                result.push(' ');
                result.push(character);
                result.push(' ');
            }
            ',' => {
                trim_trailing_spaces(&mut result);
                result.push_str(", ");
            }
            _ => {
                result.push(character);
            }
        }
    }
    clean_duplicate_spaces(&result)
}

fn trim_trailing_spaces(buffer: &mut String) {
    while buffer.ends_with(' ') {
        buffer.pop();
    }
}

fn clean_duplicate_spaces(line: &str) -> String {
    let mut cleaned = String::new();
    let mut previous_space = false;
    for character in line.chars() {
        if character == ' ' {
            if !previous_space {
                cleaned.push(character);
                previous_space = true;
            }
        } else {
            cleaned.push(character);
            previous_space = false;
        }
    }
    cleaned
}

fn spanish_keyword_replacements() -> &'static [(&'static str, &'static str)] {
    &[
        ("algoritmo", "Algoritmo"),
        ("finalgoritmo", "FinAlgoritmo"),
        ("subproceso", "SubProceso"),
        ("finsubproceso", "FinSubProceso"),
        ("definir", "Definir"),
        ("como", "Como"),
        ("entero", "Entero"),
        ("real", "Real"),
        ("logico", "Logico"),
        ("caracter", "Caracter"),
        ("cadena", "Cadena"),
        ("escribir", "Escribir"),
        ("leer", "Leer"),
        ("si", "Si"),
        ("entonces", "Entonces"),
        ("sino", "Sino"),
        ("finsi", "FinSi"),
        ("mientras", "Mientras"),
        ("hacer", "Hacer"),
        ("finmientras", "FinMientras"),
        ("para", "Para"),
        ("hasta", "Hasta"),
        ("con paso", "Con Paso"),
        ("finpara", "FinPara"),
    ]
}

fn english_keyword_replacements() -> &'static [(&'static str, &'static str)] {
    &[
        ("algorithm", "Algorithm"),
        ("endalgorithm", "EndAlgorithm"),
        ("define", "Define"),
        ("as", "As"),
        ("integer", "Integer"),
        ("real", "Real"),
        ("boolean", "Boolean"),
        ("character", "Character"),
        ("string", "String"),
        ("write", "Write"),
        ("read", "Read"),
        ("if", "If"),
        ("then", "Then"),
        ("else", "Else"),
        ("endif", "EndIf"),
        ("while", "While"),
        ("do", "Do"),
        ("endwhile", "EndWhile"),
        ("for", "For"),
        ("to", "To"),
        ("step", "Step"),
        ("endfor", "EndFor"),
        ("switch", "Switch"),
        ("endswitch", "EndSwitch"),
    ]
}

pub fn canonicalize_keywords(line: &str, profile: Profile) -> String {
    let replacements = match profile {
        Profile::Spanish => spanish_keyword_replacements(),
        Profile::English => english_keyword_replacements(),
    };
    let mut words: Vec<String> = line.split(' ').map(str::to_owned).collect();
    for word in &mut words {
        for &(lower, canonical) in replacements {
            if word.eq_ignore_ascii_case(lower) {
                *word = canonical.to_owned();
                break;
            }
        }
    }
    words.join(" ")
}
