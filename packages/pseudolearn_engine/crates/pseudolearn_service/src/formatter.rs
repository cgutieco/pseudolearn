use crate::format_rules::{canonicalize_keywords, normalize_operators, should_append_semicolon};
use pseudolearn_lexicon::Profile;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FormatOptions {
    pub profile: Profile,
    pub strict: bool,
    pub indent_size: usize,
}

impl Default for FormatOptions {
    fn default() -> Self {
        Self {
            profile: Profile::Spanish,
            strict: true,
            indent_size: 2,
        }
    }
}

pub fn format_source(text: &str, options: FormatOptions) -> String {
    let mut formatted_lines: Vec<String> = Vec::new();
    let mut indent_level = 0usize;
    let mut consecutive_empty_lines = 0usize;

    for raw_line in text.lines() {
        let trimmed = raw_line.trim();
        if trimmed.is_empty() {
            handle_empty_line(&mut formatted_lines, &mut consecutive_empty_lines);
            continue;
        }
        consecutive_empty_lines = 0;
        let (code_part, comment_part) = split_comment(trimmed);
        if code_part.is_empty() {
            append_comment_line(
                &mut formatted_lines,
                comment_part,
                indent_level,
                options.indent_size,
            );
            continue;
        }
        let (pre_decr, post_incr) = check_indentation_delta(code_part);
        if pre_decr {
            indent_level = indent_level.saturating_sub(1);
        }
        let formatted_code = format_line_code(code_part, options);
        let indent = " ".repeat(indent_level.saturating_mul(options.indent_size));
        append_code_line(&mut formatted_lines, &indent, &formatted_code, comment_part);
        if post_incr {
            indent_level = indent_level.saturating_add(1);
        }
    }
    let mut result = formatted_lines.join("\n");
    if !result.is_empty() {
        result.push('\n');
    }
    result
}

fn handle_empty_line(formatted_lines: &mut Vec<String>, consecutive_empty_lines: &mut usize) {
    let previous_was_comment = formatted_lines
        .last()
        .map(|line| line.trim().starts_with("//"))
        .unwrap_or(false);
    if *consecutive_empty_lines == 0 && !formatted_lines.is_empty() && !previous_was_comment {
        formatted_lines.push(String::new());
        *consecutive_empty_lines = consecutive_empty_lines.saturating_add(1);
    }
}

fn append_comment_line(
    formatted_lines: &mut Vec<String>,
    comment_part: &str,
    indent_level: usize,
    indent_size: usize,
) {
    if formatted_lines
        .last()
        .map(|line| line.is_empty())
        .unwrap_or(false)
    {
        formatted_lines.pop();
    }
    let indent = " ".repeat(indent_level.saturating_mul(indent_size));
    formatted_lines.push(format!("{indent}{comment_part}"));
}

fn append_code_line(
    formatted_lines: &mut Vec<String>,
    indent: &str,
    formatted_code: &str,
    comment_part: &str,
) {
    if comment_part.is_empty() {
        formatted_lines.push(format!("{indent}{formatted_code}"));
    } else {
        formatted_lines.push(format!("{indent}{formatted_code}  {comment_part}"));
    }
}

fn split_comment(line: &str) -> (&str, &str) {
    let mut in_string = false;
    let mut characters = line.char_indices().peekable();
    while let Some((index, character)) = characters.next() {
        if character == '"' {
            in_string = !in_string;
            continue;
        }
        if !in_string
            && character == '/'
            && characters.peek().map(|&(_, next_char)| next_char) == Some('/')
        {
            let code = line.get(..index).unwrap_or("").trim_end();
            let comment = line.get(index..).unwrap_or("");
            return (code, comment);
        }
    }
    (line, "")
}

fn is_indent_closer(lower: &str) -> bool {
    lower.starts_with("finalgoritmo")
        || lower.starts_with("endalgorithm")
        || lower.starts_with("finsubproceso")
        || lower.starts_with("endsubprocedure")
        || lower.starts_with("finfuncion")
        || lower.starts_with("endfunction")
        || lower.starts_with("finclase")
        || lower.starts_with("endclass")
        || lower.starts_with("finsi")
        || lower.starts_with("endif")
        || lower.starts_with("finmientras")
        || lower.starts_with("endwhile")
        || lower.starts_with("finpara")
        || lower.starts_with("endfor")
        || lower.starts_with("finsegun")
        || lower.starts_with("endswitch")
        || lower.starts_with("hasta que")
        || lower.starts_with("until")
}

fn is_indent_opener(lower: &str) -> bool {
    lower.starts_with("algoritmo")
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
        || lower.starts_with("repeat")
}

fn check_indentation_delta(code: &str) -> (bool, bool) {
    let lower = code.to_lowercase();
    let is_middle = lower.starts_with("sino")
        || lower.starts_with("else")
        || lower.starts_with("caso")
        || lower.starts_with("case")
        || lower.starts_with("de otro modo")
        || lower.starts_with("otherwise");

    if is_middle {
        (true, true)
    } else {
        (is_indent_closer(&lower), is_indent_opener(&lower))
    }
}

fn format_line_code(code: &str, options: FormatOptions) -> String {
    let mut normalized = code.trim().to_owned();
    if normalized.ends_with(';') {
        normalized.pop();
        normalized = normalized.trim_end().to_owned();
    }
    normalized = normalized.replace(":=", "<-");
    normalized = normalize_operators(&normalized);
    normalized = canonicalize_keywords(&normalized, options.profile);
    if should_append_semicolon(&normalized, options.strict) {
        normalized.push(';');
    }
    normalized
}
