use std::collections::{BTreeMap, BTreeSet};

pub fn validate(
    productions: &BTreeMap<String, String>,
    terminals: &BTreeSet<String>,
) -> Result<(), String> {
    if !productions.contains_key("program") {
        return Err("Missing program production".to_owned());
    }
    for (name, production) in productions {
        validate_production(production, productions, terminals)
            .map_err(|error| format!("{name}: {error}"))?;
    }
    Ok(())
}

fn validate_production(
    production: &str,
    productions: &BTreeMap<String, String>,
    terminals: &BTreeSet<String>,
) -> Result<(), String> {
    let mut groups = Vec::new();
    let mut characters = production.chars().peekable();
    let mut operand_due = true;
    while let Some(character) = characters.next() {
        match character {
            current if current.is_whitespace() => (),
            ',' | '|' if !operand_due => operand_due = true,
            '(' | '[' | '{' if operand_due => {
                groups.push(character);
            }
            ')' | ']' | '}' if !operand_due => close(&mut groups, character)?,
            '@' if operand_due => {
                let identifier = name(&mut characters);
                if !terminals.contains(&identifier) {
                    return Err(format!("Unknown terminal {identifier}"));
                }
                operand_due = false;
            }
            current if current.is_ascii_alphabetic() && operand_due => {
                let identifier = format!("{current}{}", name(&mut characters));
                reference(&identifier, productions, terminals)?;
                operand_due = false;
            }
            other => return Err(format!("Invalid EBNF symbol or sequence {other}")),
        }
    }
    if operand_due || !groups.is_empty() {
        return Err("Incomplete EBNF production".to_owned());
    }
    Ok(())
}

fn reference(
    identifier: &str,
    productions: &BTreeMap<String, String>,
    terminals: &BTreeSet<String>,
) -> Result<(), String> {
    if !productions.contains_key(identifier) && !terminals.contains(identifier) {
        return Err(format!("Unresolved production {identifier}"));
    }
    Ok(())
}

fn name(characters: &mut std::iter::Peekable<std::str::Chars<'_>>) -> String {
    let mut identifier = String::new();
    while let Some(character) = characters.peek().copied() {
        if !character.is_ascii_alphanumeric() && character != '_' {
            break;
        }
        identifier.push(character);
        characters.next();
    }
    identifier
}

fn close(delimiters: &mut Vec<char>, closing: char) -> Result<(), String> {
    let expected = match closing {
        ')' => '(',
        ']' => '[',
        _ => '{',
    };
    if delimiters.pop() != Some(expected) {
        return Err("Mismatched EBNF group".to_owned());
    }
    Ok(())
}
