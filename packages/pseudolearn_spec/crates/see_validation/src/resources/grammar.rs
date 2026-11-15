use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};

pub fn check(value: &Value) -> Result<(), String> {
    let productions = value
        .get("producciones")
        .and_then(Value::as_object)
        .ok_or("Missing productions")?;
    let terminals: BTreeSet<_> = see_model::strings(value.get("terminales"))
        .into_iter()
        .collect();
    let start = value
        .get("inicial")
        .and_then(Value::as_str)
        .ok_or("Missing start production")?;
    if !productions.contains_key(start) || terminals.is_empty() {
        return Err("Undefined grammar start or terminals".to_owned());
    }
    let mut graph = BTreeMap::new();
    for (name, expression) in productions {
        let expression = expression.as_str().ok_or("Invalid production")?;
        balanced(expression)?;
        let words = symbols(expression);
        if words.is_empty()
            || words
                .iter()
                .any(|word| !terminals.contains(word) && !productions.contains_key(*word))
        {
            return Err(format!("Undefined symbol in {name}"));
        }
        let references = words
            .into_iter()
            .filter(|word| productions.contains_key(*word))
            .collect();
        graph.insert(name.as_str(), references);
    }
    if reachable(start, &graph).len() != productions.len() {
        return Err("Unreachable production".to_owned());
    }
    Ok(())
}

fn balanced(expression: &str) -> Result<(), String> {
    let mut delimiters = Vec::new();
    for character in expression.chars() {
        match character {
            '[' => delimiters.push(']'),
            '{' => delimiters.push('}'),
            '(' => delimiters.push(')'),
            ']' | '}' | ')' if delimiters.pop() != Some(character) => {
                return Err("Unbalanced grammar delimiters".to_owned());
            }
            _ => (),
        }
    }
    if !delimiters.is_empty() {
        return Err("Unclosed grammar delimiter".to_owned());
    }
    Ok(())
}

fn symbols(expression: &str) -> Vec<&str> {
    expression
        .split(|character: char| !character.is_ascii_alphanumeric() && character != '_')
        .filter(|word| !word.is_empty())
        .collect()
}

fn reachable<'grammar>(
    start: &'grammar str,
    graph: &BTreeMap<&'grammar str, Vec<&'grammar str>>,
) -> BTreeSet<&'grammar str> {
    let mut reached = BTreeSet::new();
    let mut pending = vec![start];
    while let Some(name) = pending.pop() {
        if reached.insert(name)
            && let Some(children) = graph.get(name)
        {
            pending.extend(children.iter().copied());
        }
    }
    reached
}
