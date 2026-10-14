use see_model::Corpus;
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};

pub fn check(manifest: &Value, index: &str, corpus: &Corpus) -> Result<(), String> {
    let sections = manifest
        .get("secciones")
        .and_then(Value::as_object)
        .ok_or("SEE-COVERAGE: missing sections")?;
    let mapping = manifest
        .get("correspondencias")
        .and_then(Value::as_object)
        .ok_or("SEE-COVERAGE: missing mapping")?;
    let required: BTreeSet<_> = sections.keys().collect();
    if required.is_empty() || required != mapping.keys().collect() {
        return Err("SEE-COVERAGE: incomplete correspondence".to_owned());
    }
    let table = table(index)?;
    if table.keys().collect::<BTreeSet<_>>() != required {
        return Err("SEE-COVERAGE: index section mismatch".to_owned());
    }
    let available: BTreeSet<_> = corpus
        .iter()
        .map(|specification| specification.metadata.id.as_str())
        .collect();
    for (section, references) in mapping {
        let references = see_model::strings(Some(references));
        if references.is_empty()
            || references
                .iter()
                .any(|reference| !available.contains(reference))
        {
            return Err(format!("SEE-COVERAGE: undefined destination for {section}"));
        }
        let expected: BTreeSet<_> = references.iter().copied().collect();
        if table.get(section).is_none_or(|actual| actual != &expected) {
            return Err(format!(
                "SEE-COVERAGE: index destinations mismatch for {section}"
            ));
        }
    }
    Ok(())
}

fn table(index: &str) -> Result<BTreeMap<String, BTreeSet<&str>>, String> {
    let mut rows = BTreeMap::new();
    let mut active = false;
    for line in index.lines() {
        if line == "## Correspondencia del corpus" {
            active = true;
            continue;
        }
        if line.starts_with("## ") {
            active = false;
            continue;
        }
        if active && line.starts_with('|') {
            insert(line, &mut rows)?;
        }
    }
    Ok(rows)
}

fn insert<'text>(
    line: &'text str,
    rows: &mut BTreeMap<String, BTreeSet<&'text str>>,
) -> Result<(), String> {
    let cells: Vec<_> = line.split('|').map(str::trim).collect();
    let section = cells.get(1).ok_or("SEE-COVERAGE: missing table section")?;
    if !section.starts_with(|character: char| character.is_ascii_digit()) {
        return Ok(());
    }
    let references = cells
        .get(3)
        .ok_or("SEE-COVERAGE: missing table references")?;
    let contracts = references
        .split('`')
        .enumerate()
        .filter(|(offset, _)| offset % 2 == 1)
        .map(|(_, contract)| contract)
        .collect();
    if rows.insert((*section).to_owned(), contracts).is_some() {
        return Err("SEE-COVERAGE: duplicate section".to_owned());
    }
    Ok(())
}
