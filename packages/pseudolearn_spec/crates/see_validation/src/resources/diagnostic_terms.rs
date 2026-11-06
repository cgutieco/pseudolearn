use serde_json::{Map, Value};

const PREFIX: &str = "SEE-DIAGNOSTIC-TERMS";

pub fn check(terms: &Value, diagnostics: Option<&Value>) -> Result<(), String> {
    for (code, arguments) in non_empty(terms, "terms")? {
        let entry = diagnostics
            .and_then(|catalog| catalog.get(code))
            .ok_or_else(|| format!("{PREFIX}: unknown diagnostic {code}"))?;
        for (name, values) in non_empty(arguments, code)? {
            let kind = entry
                .get("tipos_argumentos")
                .and_then(|types| types.get(name))
                .and_then(Value::as_str);
            if kind != Some("termino") {
                return Err(format!("{PREFIX}: {code}.{name} is not a term argument"));
            }
            for (term, texts) in non_empty(values, name)? {
                presentation(texts)
                    .map_err(|error| format!("{PREFIX}: {code}.{name}.{term}: {error}"))?;
            }
        }
    }
    Ok(())
}

fn non_empty<'value>(
    value: &'value Value,
    owner: &str,
) -> Result<&'value Map<String, Value>, String> {
    value
        .as_object()
        .filter(|entries| !entries.is_empty())
        .ok_or_else(|| format!("{PREFIX}: {owner} expects a non-empty object"))
}

fn presentation(texts: &Value) -> Result<(), String> {
    let locales = texts.as_object().ok_or("expected an object")?;
    if locales.len() != 2 {
        return Err("expected exactly es and en".to_owned());
    }
    for locale in ["es", "en"] {
        let text = locales
            .get(locale)
            .and_then(Value::as_str)
            .ok_or_else(|| format!("missing {locale}"))?;
        if text.trim().is_empty() || text.contains(['{', '}']) {
            return Err(format!("invalid {locale} text"));
        }
        if locale == "es" {
            super::spanish_neutrality::check(text)?;
        }
    }
    Ok(())
}
