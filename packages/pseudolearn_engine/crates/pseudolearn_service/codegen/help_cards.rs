use serde_json::Value;

type Failure = Box<dyn std::error::Error>;

pub fn cards(catalog: &Value) -> Result<String, Failure> {
    let cards = catalog
        .get("cards")
        .and_then(Value::as_array)
        .ok_or("Missing help cards")?;
    let mut generated = String::from("pub(crate) static CARDS: &[HelpCard] = &[\n");
    for card in cards {
        generated.push_str(&card_literal(card)?);
    }
    generated.push_str("];\n");
    Ok(generated)
}

fn card_literal(card: &Value) -> Result<String, Failure> {
    let identity = field(card, "identity")?;
    let content = field(card, "content")?;
    Ok(format!(
        "HelpCard {{ id: {:?}, kind: {:?}, identity: {:?}, role: {:?}, tokens: &[{}], spanish: {}, english: {} }},\n",
        text(card, "id")?,
        text(identity, "kind")?,
        text(identity, "id")?,
        text(identity, "role")?,
        token_literals(card)?,
        locale_literal(field(content, "es")?)?,
        locale_literal(field(content, "en")?)?,
    ))
}

fn token_literals(card: &Value) -> Result<String, Failure> {
    let tokens = array(card, "tokens")?;
    let mut identities = Vec::new();
    for token in tokens {
        identities.push(format!("{:?}", text(token, "identity")?));
    }
    Ok(identities.join(", "))
}

fn locale_literal(content: &Value) -> Result<String, Failure> {
    Ok(format!(
        "LocaleContent {{ title: {:?}, summary: {:?}, purpose: {:?}, constraints: &[{}], common_errors: &[{}], parts: &[{}], examples: &[{}] }}",
        text(content, "title")?,
        text(content, "summary")?,
        text(content, "purpose")?,
        string_literals(content, "constraints")?,
        string_literals(content, "common_errors")?,
        part_literals(content)?,
        example_literals(content)?,
    ))
}

fn string_literals(content: &Value, key: &str) -> Result<String, Failure> {
    let mut literals = Vec::new();
    for item in array(content, key)? {
        let value = item.as_str().ok_or("Expected a string item")?;
        literals.push(format!("{value:?}"));
    }
    Ok(literals.join(", "))
}

fn part_literals(content: &Value) -> Result<String, Failure> {
    let mut literals = Vec::new();
    for part in array(content, "parts")? {
        literals.push(format!(
            "HelpPart {{ identity: {:?}, text: {:?} }}",
            text(part, "identity")?,
            text(part, "text")?
        ));
    }
    Ok(literals.join(", "))
}

fn example_literals(content: &Value) -> Result<String, Failure> {
    let mut literals = Vec::new();
    for example in array(content, "examples")? {
        literals.push(format!(
            "HelpExample {{ specification: {:?}, version: {:?}, case: {:?}, profile: {:?}, strictness: {:?}, label: {:?} }}",
            text(example, "specification")?,
            text(example, "version")?,
            text(example, "case")?,
            text(example, "profile")?,
            text(example, "strictness")?,
            text(example, "label")?,
        ));
    }
    Ok(literals.join(", "))
}

fn field<'value>(value: &'value Value, key: &str) -> Result<&'value Value, Failure> {
    value
        .get(key)
        .ok_or_else(|| format!("Missing help field {key}").into())
}

fn text<'value>(value: &'value Value, key: &str) -> Result<&'value str, Failure> {
    field(value, key)?
        .as_str()
        .ok_or_else(|| format!("Help field {key} is not text").into())
}

fn array<'value>(value: &'value Value, key: &str) -> Result<&'value Vec<Value>, Failure> {
    field(value, key)?
        .as_array()
        .ok_or_else(|| format!("Help field {key} is not a list").into())
}
