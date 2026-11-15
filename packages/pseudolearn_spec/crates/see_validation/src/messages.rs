use serde_json::Value;

pub const CATALOG_TERM: &str = "cliMessages";

pub fn check(catalog: &Value) -> Vec<String> {
    let Some(entries) = catalog.as_object().filter(|entries| !entries.is_empty()) else {
        return vec!["SEE-MESSAGE-PARITY: empty message catalog".to_owned()];
    };
    entries
        .iter()
        .filter_map(|(key, entry)| message(key, entry).err())
        .collect()
}

fn message(key: &str, entry: &Value) -> Result<(), String> {
    let mut markers = Vec::new();
    for locale in ["es", "en"] {
        let pattern = entry
            .get("mensajes")
            .and_then(|messages| messages.get(locale))
            .and_then(Value::as_str)
            .filter(|pattern| !pattern.trim().is_empty())
            .ok_or(format!("SEE-MESSAGE-PARITY: {key} lacks {locale}"))?;
        if locale == "es" {
            crate::resources::spanish_neutrality::check(pattern)?;
        }
        markers.push(
            crate::resources::placeholders(pattern)
                .map_err(|error| format!("SEE-MESSAGE-ARGUMENTS: {key}: {error}"))?,
        );
    }
    let declared: std::collections::BTreeSet<_> = see_model::strings(entry.get("argumentos"))
        .into_iter()
        .collect();
    if markers.iter().any(|actual| actual != &declared) {
        return Err(format!("SEE-MESSAGE-ARGUMENTS: {key} argument mismatch"));
    }
    crate::resources::argument_types(entry, &declared)
        .map_err(|error| format!("SEE-MESSAGE-ARGUMENTS: {key}: {error}"))
}
