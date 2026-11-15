use serde_json::{Map, Value};

pub fn generate(terms: &Map<String, Value>) -> Result<String, String> {
    let mut generated = String::from(
        "impl DiagnosticCode { pub fn term_text(self, argument: &str, term: &str, locale: &str) -> Option<&'static str> { match (self, argument, term) {\n",
    );
    for (code, arguments) in terms {
        let arguments = arguments
            .as_object()
            .ok_or("Invalid diagnostic term arguments")?;
        for (argument, values) in arguments {
            let values = values.as_object().ok_or("Invalid diagnostic term values")?;
            for (term, texts) in values {
                let spanish = text(texts, "es")?;
                let english = text(texts, "en")?;
                generated.push_str(&format!(
                    "(Self::{}, {argument:?}, {term:?}) => Some(if locale == \"en\" {{ {english:?} }} else {{ {spanish:?} }}),\n",
                    super::to_pascal_case(code)
                ));
            }
        }
    }
    generated.push_str("_ => None, } } }\n");
    Ok(generated)
}

fn text<'value>(texts: &'value Value, locale: &str) -> Result<&'value str, String> {
    texts
        .get(locale)
        .and_then(Value::as_str)
        .ok_or_else(|| format!("Missing {locale} diagnostic term text"))
}
