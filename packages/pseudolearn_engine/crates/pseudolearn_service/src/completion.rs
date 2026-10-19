pub use crate::completion_types::{CompletionEntry, CompletionKind, CompletionQuery};
use pseudolearn_lexicon::Profile;
use pseudolearn_semantic::{ServiceAnalysis, ServiceSymbolCategory};

pub fn complete_at_position(query: &CompletionQuery) -> Vec<CompletionEntry> {
    let text = query.source.as_str();
    let line_index = usize::try_from(query.position.line.saturating_sub(1)).unwrap_or(0);
    let column_index = usize::try_from(query.position.column.saturating_sub(1)).unwrap_or(0);
    let lines: Vec<&str> = text.lines().collect();
    let Some(&current_line) = lines.get(line_index) else {
        return Vec::new();
    };
    let prefix = slice_up_to(current_line, column_index);
    if is_inside_comment_or_literal(prefix) {
        return Vec::new();
    }
    let trimmed = prefix.trim();
    if is_type_position(trimmed) {
        return type_candidates(query.profile);
    }
    if let Some(receiver) = member_access_receiver(trimmed) {
        return member_candidates(query.analysis, receiver);
    }
    let prior_lines = lines.get(..=line_index).unwrap_or(&[]);
    general_candidates(prior_lines, query.analysis, prefix, query.profile)
}

fn slice_up_to(line: &str, limit: usize) -> &str {
    let bound = limit.min(line.len());
    line.get(..bound).unwrap_or(line)
}

fn is_inside_comment_or_literal(prefix: &str) -> bool {
    if prefix.contains("//") {
        return true;
    }
    let quote_count = prefix.chars().filter(|&character| character == '"').count();
    quote_count % 2 == 1
}

fn is_type_position(trimmed: &str) -> bool {
    trimmed.ends_with("Como") || trimmed.ends_with("As") || trimmed.ends_with(':')
}

fn type_candidates(profile: Profile) -> Vec<CompletionEntry> {
    let labels = match profile {
        Profile::Spanish => ["Entero", "Real", "Logico", "Caracter", "Cadena"],
        Profile::English => ["Integer", "Real", "Boolean", "Character", "String"],
    };
    labels
        .iter()
        .map(|&label| CompletionEntry {
            label: label.to_owned(),
            kind: CompletionKind::Type,
            detail: Some(String::from("Primitive Type")),
            insert_text: None,
            bilingual_origin: None,
        })
        .collect()
}

fn member_access_receiver(trimmed: &str) -> Option<&str> {
    if !trimmed.ends_with('.') {
        return None;
    }
    let stem = trimmed.trim_end_matches('.');
    stem.split_whitespace().last()
}

fn collect_class_fields(
    semantic_analysis: &ServiceAnalysis,
    target_class: &str,
    candidates: &mut Vec<CompletionEntry>,
) {
    for class in &semantic_analysis.module.classes {
        if class.name.eq_ignore_ascii_case(target_class) {
            for field in &class.fields {
                candidates.push(CompletionEntry {
                    label: field.name.clone(),
                    kind: CompletionKind::Field,
                    detail: Some(String::from("Field")),
                    insert_text: None,
                    bilingual_origin: None,
                });
            }
        }
    }
}

fn collect_class_methods(
    semantic_analysis: &ServiceAnalysis,
    target_class: &str,
    candidates: &mut Vec<CompletionEntry>,
) {
    for function in &semantic_analysis.module.functions {
        let Some(owner) = function.owner else {
            continue;
        };
        let Some(class) = semantic_analysis
            .module
            .classes
            .get(usize::try_from(owner.0).unwrap_or(usize::MAX))
        else {
            continue;
        };
        if class.name.eq_ignore_ascii_case(target_class) {
            candidates.push(CompletionEntry {
                label: function.name.clone(),
                kind: CompletionKind::Method,
                detail: Some(String::from("Method")),
                insert_text: None,
                bilingual_origin: None,
            });
        }
    }
}

fn member_candidates(analysis: Option<&ServiceAnalysis>, receiver: &str) -> Vec<CompletionEntry> {
    let Some(semantic_analysis) = analysis else {
        return Vec::new();
    };
    let mut candidates = Vec::new();
    let symbol_option = semantic_analysis
        .symbols
        .iter()
        .find(|symbol| symbol.name == receiver);
    let class_name = symbol_option
        .and_then(|symbol| {
            semantic_analysis
                .module
                .classes
                .iter()
                .find(|class| class.name == symbol.name)
        })
        .map(|class| class.name.as_str());

    let target_class = class_name.unwrap_or(receiver);
    collect_class_fields(semantic_analysis, target_class, &mut candidates);
    collect_class_methods(semantic_analysis, target_class, &mut candidates);
    candidates
}

fn general_candidates(
    lines: &[&str],
    analysis: Option<&ServiceAnalysis>,
    prefix: &str,
    profile: Profile,
) -> Vec<CompletionEntry> {
    let mut candidates = Vec::new();
    if let Some(closing_token) = detect_innermost_unclosed_block(lines, profile) {
        candidates.push(CompletionEntry {
            label: closing_token,
            kind: CompletionKind::Keyword,
            detail: Some(String::from("Close Block")),
            insert_text: None,
            bilingual_origin: None,
        });
    }
    let word = extract_last_word(prefix);
    if let Some(bilingual) = detect_bilingual_hint(word, profile) {
        candidates.push(bilingual);
    }
    if let Some(semantic_analysis) = analysis {
        for symbol in &semantic_analysis.symbols {
            if symbol.category == ServiceSymbolCategory::Variable
                || symbol.category == ServiceSymbolCategory::Parameter
            {
                candidates.push(CompletionEntry {
                    label: symbol.name.clone(),
                    kind: CompletionKind::Variable,
                    detail: Some(String::from("Variable")),
                    insert_text: None,
                    bilingual_origin: None,
                });
            }
        }
    }
    add_keyword_candidates(&mut candidates, profile);
    candidates
}

fn extract_last_word(prefix: &str) -> &str {
    prefix
        .split(|character: char| !character.is_alphanumeric() && character != '_')
        .next_back()
        .unwrap_or("")
}

fn block_closing_keyword(trimmed: &str, profile: Profile) -> Option<&'static str> {
    let lower = trimmed.to_lowercase();
    if lower.starts_with("mientras") || lower.starts_with("while") {
        return Some(match profile {
            Profile::Spanish => "FinMientras",
            Profile::English => "EndWhile",
        });
    }
    if lower.starts_with("si") || lower.starts_with("if") {
        return Some(match profile {
            Profile::Spanish => "FinSi",
            Profile::English => "EndIf",
        });
    }
    if lower.starts_with("segun") || lower.starts_with("switch") {
        return Some(match profile {
            Profile::Spanish => "FinSegun",
            Profile::English => "EndSwitch",
        });
    }
    if lower.starts_with("para") || lower.starts_with("for") {
        return Some(match profile {
            Profile::Spanish => "FinPara",
            Profile::English => "EndFor",
        });
    }
    None
}

fn detect_innermost_unclosed_block(lines: &[&str], profile: Profile) -> Option<String> {
    let mut stack: Vec<&'static str> = Vec::new();
    for line in lines {
        let trimmed = line.trim();
        if let Some(closing) = block_closing_keyword(trimmed, profile) {
            stack.push(closing);
            continue;
        }
        pop_if_matching_closing(trimmed, &mut stack);
    }
    stack.pop().map(str::to_owned)
}

fn pop_if_matching_closing(trimmed: &str, stack: &mut Vec<&'static str>) {
    let Some(&expected) = stack.last() else {
        return;
    };
    if trimmed.starts_with(expected) {
        stack.pop();
    }
}

fn detect_bilingual_hint(word: &str, profile: Profile) -> Option<CompletionEntry> {
    if word.is_empty() {
        return None;
    }
    let (label, origin) = crate::completion_templates::bilingual_keyword_hint(word, profile)?;
    Some(CompletionEntry {
        label: label.to_owned(),
        kind: CompletionKind::Keyword,
        detail: Some(format!("Bilingual match for {origin}")),
        insert_text: None,
        bilingual_origin: Some(origin.to_owned()),
    })
}

fn add_keyword_candidates(candidates: &mut Vec<CompletionEntry>, profile: Profile) {
    let keywords = match profile {
        Profile::Spanish => [
            "Escribir", "Leer", "Definir", "Si", "Mientras", "Para", "Segun",
        ],
        Profile::English => ["Print", "Read", "Define", "If", "While", "For", "Switch"],
    };
    for keyword in keywords {
        if !candidates
            .iter()
            .any(|candidate| candidate.label == keyword)
        {
            candidates.push(CompletionEntry {
                label: keyword.to_owned(),
                kind: CompletionKind::Keyword,
                detail: Some(String::from("Keyword")),
                insert_text: None,
                bilingual_origin: None,
            });
        }
    }
}
