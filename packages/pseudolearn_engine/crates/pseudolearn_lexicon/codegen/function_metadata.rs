use super::to_pascal_case;

pub fn signatures(
    functions: &serde_json::Map<String, serde_json::Value>,
) -> Result<String, Box<dyn std::error::Error>> {
    let mut generated = String::from(
        "pub fn signature_for_builtin(kind: BuiltinKind) -> crate::signatures::BuiltinSignature { match kind {\n",
    );
    for (name, definition) in functions {
        let parameters = definition
            .get("parametros")
            .and_then(serde_json::Value::as_array)
            .ok_or("Missing builtin parameters")?;
        let parameters = parameters
            .iter()
            .map(|parameter| {
                parameter
                    .as_str()
                    .map(|text| format!("{text:?}"))
                    .ok_or("Invalid builtin parameter")
            })
            .collect::<Result<Vec<_>, _>>()?
            .join(",");
        let result = definition
            .get("retorno")
            .and_then(serde_json::Value::as_str)
            .ok_or("Missing builtin result")?;
        generated.push_str(&format!("BuiltinKind::{} => crate::signatures::BuiltinSignature::new(&[{parameters}], {result:?}),\n", to_pascal_case(name)));
    }
    generated.push_str("} }\n");
    Ok(generated)
}

pub fn compound_prefixes(vocabulary: &serde_json::Map<String, serde_json::Value>) -> String {
    let mut prefixes = std::collections::BTreeSet::new();
    for definition in vocabulary.values() {
        for profile in ["es", "en"] {
            for form in super::collect_forms(definition, profile) {
                if let Some((first, _)) = form.split_once(' ') {
                    prefixes.insert(first.to_owned());
                }
            }
        }
    }
    let mut generated = String::from("pub fn is_compound_prefix(word: &str) -> bool { ");
    generated.push_str(
        &prefixes
            .iter()
            .map(|prefix| format!("word.eq_ignore_ascii_case({prefix:?})"))
            .collect::<Vec<_>>()
            .join("||"),
    );
    generated.push_str(" }\n");
    generated
}
