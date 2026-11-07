const RUST_RESERVED: &[&str] = &[
    "as", "async", "await", "break", "const", "continue", "crate", "dyn", "else", "enum", "extern",
    "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub",
    "ref", "return", "static", "struct", "super", "trait", "true", "type", "unsafe", "use",
    "where", "while", "abstract", "become", "box", "do", "final", "macro", "override", "priv",
    "typeof", "unsized", "virtual", "yield", "try", "gen", "main", "std", "core", "alloc",
];

const PYTHON_RESERVED: &[&str] = &[
    "False", "None", "True", "and", "as", "assert", "async", "await", "break", "class", "continue",
    "def", "del", "elif", "else", "except", "finally", "for", "from", "global", "if", "import",
    "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise", "return", "try", "while",
    "with", "yield", "match", "case", "type", "main", "print", "input", "len", "str", "int",
    "float", "bool", "list", "dict", "self", "object", "math", "sys", "asyncio",
];

fn words(name: &str) -> Vec<String> {
    let mut words: Vec<String> = Vec::new();
    let mut current = String::new();
    let mut previous_lower = false;
    for character in name.chars() {
        if !character.is_alphanumeric() {
            push_word(&mut words, &mut current);
            previous_lower = false;
            continue;
        }
        if character.is_uppercase() && previous_lower {
            push_word(&mut words, &mut current);
        }
        previous_lower = character.is_lowercase() || character.is_numeric();
        current.push(character);
    }
    push_word(&mut words, &mut current);
    words
}

fn push_word(words: &mut Vec<String>, current: &mut String) {
    if !current.is_empty() {
        words.push(std::mem::take(current));
    }
}

fn snake(name: &str) -> String {
    let joined = words(name)
        .iter()
        .map(|word| word.to_lowercase())
        .collect::<Vec<_>>()
        .join("_");
    if joined.is_empty() {
        "value".to_owned()
    } else if joined.starts_with(|character: char| character.is_numeric()) {
        format!("value_{joined}")
    } else {
        joined
    }
}

fn pascal(name: &str) -> String {
    let joined: String = words(name)
        .iter()
        .map(|word| {
            let mut characters = word.chars();
            characters.next().map_or_else(String::new, |first| {
                first.to_uppercase().chain(characters).collect::<String>()
            })
        })
        .collect();
    if joined.is_empty() || joined.starts_with(|character: char| character.is_numeric()) {
        format!("Type{joined}")
    } else {
        joined
    }
}

pub(crate) fn rust_value_name(name: &str) -> String {
    let spelled = snake(name);
    if RUST_RESERVED.contains(&spelled.as_str()) {
        format!("{spelled}_value")
    } else {
        spelled
    }
}

pub(crate) fn python_value_name(name: &str) -> String {
    let spelled = snake(name);
    if PYTHON_RESERVED.contains(&spelled.as_str()) {
        format!("{spelled}_value")
    } else {
        spelled
    }
}

pub(crate) fn type_name(name: &str) -> String {
    let spelled = pascal(name);
    match spelled.as_str() {
        "Self" | "Option" | "Result" | "Some" | "None" | "Ok" | "Err" | "Vec" | "String"
        | "Box" | "Rc" | "RefCell" | "Channel" | "Task" | "Dictionary" | "Nothing" | "Fault" => {
            format!("{spelled}Type")
        }
        _ => spelled,
    }
}
