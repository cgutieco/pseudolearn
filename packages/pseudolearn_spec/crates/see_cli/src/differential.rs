use crate::{arguments::Arguments, storage};
use see_model::{
    Corpus,
    evidence::{Conformance, Evidence, Observation},
};
use serde_json::{Value, json};
use std::collections::BTreeMap;

type Key = (String, String, String, String, String);

pub fn execute(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let engine: Evidence = storage::read_json(&arguments.root.join("results/engine.json"))?;
    let reference: Evidence = storage::read_json(&arguments.root.join("results/reference.json"))?;
    ensure_current(corpus, &engine)?;
    ensure_current(corpus, &reference)?;
    let known = Exemptions {
        core: exempt_rules(arguments)?,
        registry: registry(arguments)?,
    };
    let engine_index = index(&engine);
    let reference_index = index(&reference);
    let mut report = Report::default();
    for (key, reference_observation) in &reference_index {
        if let Some(engine_observation) = engine_index.get(key) {
            report.classify(key, (reference_observation, engine_observation), &known);
        }
    }
    let rendered = report.render((engine_index.len(), reference_index.len()));
    storage::artifact(
        &arguments.root.join("results/r5-differential.json"),
        &rendered,
        false,
    )?;
    summary(&report)
}

fn summary(report: &Report) -> Result<String, String> {
    if report.unresolved.is_empty() {
        Ok(format!(
            "Compared {} observations; {} exempt; {} uncontracted span or notice differences; 0 unresolved",
            report.compared,
            report.exempt.len(),
            report.informational.len()
        ))
    } else {
        Err(format!(
            "SEE-DIFFERENTIAL: {} unresolved differences",
            report.unresolved.len()
        ))
    }
}

fn registry(arguments: &Arguments) -> Result<Vec<Value>, String> {
    let value: Value = storage::read_json(&arguments.root.join("differential-exemptions.json"))?;
    Ok(value
        .get("exemptions")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default())
}

fn ensure_current(corpus: &Corpus, evidence: &Evidence) -> Result<(), String> {
    for (id, hash) in &evidence.corpus_hashes {
        let specification = corpus
            .iter()
            .find(|specification| &specification.metadata.id == id)
            .ok_or("SEE-STALE: unknown evidence specification")?;
        if &see_change::hash(specification)? != hash {
            return Err(format!(
                "SEE-STALE: {} evidence is outdated for {id}",
                evidence.subject
            ));
        }
    }
    Ok(())
}

fn exempt_rules(arguments: &Arguments) -> Result<BTreeMap<String, String>, String> {
    let path = arguments.root.join("../pseudolearn_core/conformance.yaml");
    let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
    let conformance: Conformance =
        serde_saphyr::from_str(&text).map_err(|error| error.to_string())?;
    Ok(conformance
        .vinculos
        .into_iter()
        .filter(|binding| binding.estado == "exento")
        .map(|binding| (binding.regla, binding.justificacion.unwrap_or_default()))
        .collect())
}

fn index(evidence: &Evidence) -> BTreeMap<Key, &Observation> {
    evidence
        .observations
        .iter()
        .map(|observation| {
            (
                (
                    observation.specification.clone(),
                    observation.rule.clone(),
                    observation.case.clone(),
                    observation.profile.clone(),
                    observation.strictness.clone(),
                ),
                observation,
            )
        })
        .collect()
}

fn contract_view(actual: &Value) -> Value {
    let errors: Vec<&Value> = actual
        .get("diagnostics")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter(|diagnostic| diagnostic.get("severity") == Some(&json!("error")))
        .filter_map(|diagnostic| diagnostic.get("code"))
        .collect();
    json!({"output":actual.get("output"),
        "termination":{"kind":actual.pointer("/termination/kind"),
            "code":actual.pointer("/termination/code")},
        "error_codes":errors})
}

fn normalized(actual: &Value) -> Value {
    let diagnostics: Vec<Value> = actual
        .get("diagnostics")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .map(|diagnostic| {
            json!({"code":diagnostic.get("code"),"severity":diagnostic.get("severity"),
                "span":diagnostic.get("span")})
        })
        .collect();
    json!({"output":actual.get("output"),
        "termination":{"kind":actual.pointer("/termination/kind"),
            "code":actual.pointer("/termination/code")},
        "diagnostics":diagnostics})
}

#[derive(Default)]
struct Report {
    compared: usize,
    coincide: usize,
    exempt: Vec<Value>,
    informational: Vec<Value>,
    unresolved: Vec<Value>,
}

struct Exemptions {
    core: BTreeMap<String, String>,
    registry: Vec<Value>,
}

impl Exemptions {
    fn justification(&self, key: &Key, reference: &Observation) -> Option<String> {
        let registered = self.registry.iter().find(|entry| {
            let field = |name: &str| entry.get(name).and_then(Value::as_str);
            field("specification") == Some(key.0.as_str())
                && field("rule") == Some(key.1.as_str())
                && field("case") == Some(key.2.as_str())
        });
        if let Some(entry) = registered {
            return entry
                .get("justification")
                .and_then(Value::as_str)
                .map(str::to_owned);
        }
        if reference.verdict != "incumple" {
            return None;
        }
        self.core
            .iter()
            .find(|(rule, _)| {
                rule.starts_with(&format!("{}@", key.0)) && rule.ends_with(&format!("#{}", key.1))
            })
            .map(|(_, reason)| reason.clone())
    }
}

impl Report {
    fn classify(&mut self, key: &Key, pair: (&Observation, &Observation), known: &Exemptions) {
        let (reference, engine) = pair;
        self.compared = self.compared.saturating_add(1);
        let entry = json!({"specification":key.0,"rule":key.1,"case":key.2,"profile":key.3,
            "strictness":key.4,"reference_verdict":reference.verdict,
            "engine_verdict":engine.verdict});
        let (reference_core, engine_core) = (
            contract_view(&reference.actual),
            contract_view(&engine.actual),
        );
        if reference_core != engine_core {
            let detail = with_views(entry, reference_core, engine_core);
            match known.justification(key, reference) {
                Some(reason) => self
                    .exempt
                    .push(json!({"difference":detail,"exemption":reason})),
                None => self.unresolved.push(detail),
            }
        } else if normalized(&reference.actual) == normalized(&engine.actual) {
            self.coincide = self.coincide.saturating_add(1);
        } else {
            self.informational.push(entry);
        }
    }

    fn render(&self, totals: (usize, usize)) -> Value {
        json!({"engine_observations":totals.0,"reference_observations":totals.1,
            "compared":self.compared,"coincide":self.coincide,
            "contract_scope":"output, termination and error diagnostic codes",
            "exempt_differences":self.exempt,
            "uncontracted_span_or_notice_differences":self.informational.len(),
            "uncontracted_differences":self.informational,
            "unresolved_differences":self.unresolved})
    }
}

fn with_views(mut entry: Value, reference: Value, engine: Value) -> Value {
    if let Some(object) = entry.as_object_mut() {
        object.insert("reference".to_owned(), reference);
        object.insert("engine".to_owned(), engine);
    }
    entry
}
