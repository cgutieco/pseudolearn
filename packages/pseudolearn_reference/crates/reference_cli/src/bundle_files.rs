use crate::workspace_files::{files_with_extension, relative};
use reference_export::Bundle;
use reference_model::{RuleId, Violation};
use std::collections::BTreeMap;
use std::path::Path;

pub fn write(output: &Path, bundles: &BTreeMap<String, Bundle>) -> Result<(), String> {
    if output.exists() {
        std::fs::remove_dir_all(output)
            .map_err(|error| format!("cannot clear {}: {error}", output.display()))?;
    }
    for (edition, bundle) in bundles {
        for (path, text) in &bundle.files {
            let target = output.join(edition).join(path);
            if let Some(parent) = target.parent() {
                std::fs::create_dir_all(parent).map_err(|error| error.to_string())?;
            }
            std::fs::write(&target, text)
                .map_err(|error| format!("cannot write {}: {error}", target.display()))?;
        }
    }
    Ok(())
}

pub fn compare(
    output: &Path,
    bundles: &BTreeMap<String, Bundle>,
) -> Result<Vec<Violation>, String> {
    let mut expected = BTreeMap::new();
    for (edition, bundle) in bundles {
        for (path, text) in &bundle.files {
            expected.insert(format!("{edition}/{path}"), text);
        }
    }
    let mut violations = Vec::new();
    let present = files_with_extension(output, "json")?;
    for path in &present {
        let key = relative(output, path);
        let stale = match expected.remove(&key) {
            Some(text) => {
                std::fs::read_to_string(path).map_err(|error| error.to_string())? != *text
            }
            None => true,
        };
        if stale {
            violations.push(Violation::new(
                RuleId::BundleStale,
                key,
                "differs from the compiler output: run `reference build`",
            ));
        }
    }
    for missing in expected.keys() {
        violations.push(Violation::new(
            RuleId::BundleStale,
            missing.clone(),
            "is missing: run `reference build`",
        ));
    }
    Ok(violations)
}
