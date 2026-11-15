use see_model::{Block, Corpus, field, strings};
use std::collections::{BTreeMap, BTreeSet};

const COVERED_CLASSES: [&str; 3] = ["semantica", "ejecucion", "ampliacion"];

pub fn check(corpus: &Corpus) -> Vec<String> {
    let instructions = instruction_names(corpus);
    if instructions.is_empty() {
        return Vec::new();
    }
    let mut errors = duplicate_instructions(corpus);
    errors.extend(trap_codes(corpus));
    let mut entries = BTreeMap::<&str, usize>::new();
    for entry in blocks(corpus, "cobertura") {
        let counter = entries.entry(field(entry, "regla")).or_default();
        *counter = counter.saturating_add(1);
        errors.extend(entry_shape(entry, &instructions));
    }
    let required = required_rules(corpus);
    for rule in &required {
        if entries.get(rule.as_str()) != Some(&1) {
            errors.push(format!(
                "SEE-IR-COVERAGE: {rule} needs exactly one coverage entry"
            ));
        }
    }
    errors.extend(
        entries
            .keys()
            .filter(|rule| !required.contains(**rule))
            .map(|rule| format!("SEE-IR-COVERAGE: coverage for uncovered rule {rule}")),
    );
    errors
}

pub fn required_rules(corpus: &Corpus) -> BTreeSet<String> {
    corpus
        .iter()
        .filter(|specification| {
            ["LANG.", "LIB."]
                .iter()
                .any(|prefix| specification.metadata.id.starts_with(prefix))
        })
        .flat_map(|specification| {
            specification
                .blocks
                .iter()
                .filter(|block| {
                    block.kind == "regla" && COVERED_CLASSES.contains(&field(block, "clase"))
                })
                .map(|rule| format!("{}#{}", specification.metadata.id, field(rule, "id")))
        })
        .collect()
}

fn blocks<'corpus>(corpus: &'corpus Corpus, kind: &str) -> Vec<&'corpus Block> {
    corpus
        .iter()
        .flat_map(|specification| &specification.blocks)
        .filter(|block| block.kind == kind)
        .collect()
}

fn instruction_names(corpus: &Corpus) -> BTreeSet<&str> {
    blocks(corpus, "instruccion")
        .into_iter()
        .map(|instruction| field(instruction, "nombre"))
        .collect()
}

fn duplicate_instructions(corpus: &Corpus) -> Vec<String> {
    let mut seen = BTreeSet::new();
    blocks(corpus, "instruccion")
        .into_iter()
        .map(|instruction| field(instruction, "nombre"))
        .filter(|name| !seen.insert(*name))
        .map(|name| format!("SEE-DUPLICATE: duplicate instruction {name}"))
        .collect()
}

fn entry_shape(entry: &Block, instructions: &BTreeSet<&str>) -> Vec<String> {
    let rule = field(entry, "regla");
    let listed = entry.fields.contains_key("instrucciones");
    if listed == entry.fields.contains_key("sin_ri") {
        return vec![format!(
            "SEE-IR-COVERAGE: {rule} needs instructions or a reason without IR"
        )];
    }
    strings(entry.fields.get("instrucciones"))
        .into_iter()
        .filter(|name| !instructions.contains(name))
        .map(|name| format!("SEE-IR-UNKNOWN: {rule} cites unknown instruction {name}"))
        .collect()
}

fn trap_codes(corpus: &Corpus) -> Vec<String> {
    let Some(catalog) =
        crate::cli::resource(corpus, "diagnostics").and_then(serde_json::Value::as_object)
    else {
        return Vec::new();
    };
    blocks(corpus, "instruccion")
        .into_iter()
        .flat_map(|instruction| strings(instruction.fields.get("trampas")))
        .filter(|code| !catalog.contains_key(*code))
        .map(|code| format!("SEE-IR-UNKNOWN: unknown trap diagnostic {code}"))
        .collect()
}
