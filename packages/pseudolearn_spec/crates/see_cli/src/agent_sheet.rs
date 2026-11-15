use see_export::agent_sheet::{SheetLanguage, render};
use see_model::Corpus;
use serde_json::Value;
use std::path::Path;

pub const SETTINGS_PATH: &str = "agents/agent-sheet.json";

pub fn generate(root: &Path, corpus: &Corpus, check: bool) -> Result<String, String> {
    let settings: Value = crate::storage::read_json(&root.join(SETTINGS_PATH))?;
    let resources = see_export::resources::generate(corpus)?;
    let outputs = settings
        .get("outputs")
        .and_then(Value::as_object)
        .ok_or("SEE-AGENT-SHEET: missing outputs")?;
    let mut report = Vec::new();
    for (code, paths) in outputs {
        let labels = settings
            .pointer(&format!("/labels/{code}"))
            .ok_or_else(|| format!("SEE-AGENT-SHEET: missing labels for {code}"))?;
        let sheet = render(
            corpus,
            &resources,
            &settings,
            &SheetLanguage { code, labels },
        )?;
        for path in paths.as_array().ok_or("SEE-AGENT-SHEET: invalid outputs")? {
            let relative = path
                .as_str()
                .ok_or("SEE-AGENT-SHEET: invalid output path")?;
            report.push(crate::storage::text_artifact(
                &root.join(relative),
                &sheet,
                check,
            )?);
        }
    }
    Ok(report.join("\n"))
}
