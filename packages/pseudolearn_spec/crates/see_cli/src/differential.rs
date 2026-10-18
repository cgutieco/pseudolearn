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
    let first = compare(("reference", "engine"), (&reference, &engine), &known);
    storage::artifact(
        &arguments.root.join("results/r5-differential.json"),
        &first.rendered,
        false,
    )?;
    let mut message = summary(&first.report)?;
    let aot_path = arguments.root.join("results/aot.json");
    if aot_path.exists() {
        let aot: Evidence = storage::read_json(&aot_path)?;
        ensure_current(corpus, &aot)?;
        let none = Exemptions {
            core: BTreeMap::new(),
            registry: Vec::new(),
        };
        let second = compare(("engine", "aot"), (&engine, &aot), &none);
        storage::artifact(
            &arguments.root.join("results/r6-differential.json"),
            &second.rendered,
            false,
        )?;
        message = format!("{message}; native: {}", summary(&second.report)?);
    }
    Ok(message)
}

struct Comparison {
    report: Report,
    rendered: Value,
}

fn compare(
    labels: (&'static str, &'static str),
    evidence: (&Evidence, &Evidence),
    known: &Exemptions,
) -> Comparison {
    let left_index = index(evidence.0);
    let right_index = index(evidence.1);
    let mut report = Report {
        labels,
        ..Report::default()
    };
    for (key, left_observation) in &left_index {
        if let Some(right_observation) = right_index.get(key)
            && !left_observation.actual.is_null()
            && !right_observation.actual.is_null()
        {
            report.classify(key, (left_observation, right_observation), known);
        }
    }
    let rendered = report.render((left_index.len(), right_index.len()));
    Comparison { report, rendered }
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
    labels: (&'static str, &'static str),
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
    fn contract_view(&self, actual: &Value) -> Value {
        if self.labels.1 == "aot" {
            let mut result = contract_view(actual);
            let errors: Vec<Value> = actual
                .get("diagnostics")
                .and_then(Value::as_array)
                .into_iter()
                .flatten()
                .filter(|diagnostic| diagnostic.get("severity") == Some(&json!("error")))
                .map(|diagnostic| {
                    json!({"code":diagnostic.get("code"),
                    "arguments":diagnostic.get("arguments"), "span":diagnostic.get("span")})
                })
                .collect();
            if let Some(fields) = result.as_object_mut() {
                fields.insert("error_diagnostics".to_owned(), json!(errors));
            }
            result
        } else {
            contract_view(actual)
        }
    }

    fn classify(&mut self, key: &Key, pair: (&Observation, &Observation), known: &Exemptions) {
        let (left, right) = pair;
        self.compared = self.compared.saturating_add(1);
        let entry = self.entry(key, (&left.verdict, &right.verdict));
        let (left_core, right_core) = (
            self.contract_view(&left.actual),
            self.contract_view(&right.actual),
        );
        if left_core != right_core {
            let detail = self.with_views(entry, left_core, right_core);
            match known.justification(key, left) {
                Some(reason) => self
                    .exempt
                    .push(json!({"difference":detail,"exemption":reason})),
                None => self.unresolved.push(detail),
            }
        } else if normalized(&left.actual) == normalized(&right.actual) {
            self.coincide = self.coincide.saturating_add(1);
        } else {
            self.informational.push(entry);
        }
    }

    fn entry(&self, key: &Key, verdicts: (&str, &str)) -> Value {
        let mut entry = json!({"specification":key.0,"rule":key.1,"case":key.2,"profile":key.3,
            "strictness":key.4});
        if let Some(object) = entry.as_object_mut() {
            object.insert(format!("{}_verdict", self.labels.0), json!(verdicts.0));
            object.insert(format!("{}_verdict", self.labels.1), json!(verdicts.1));
        }
        entry
    }

    fn with_views(&self, mut entry: Value, left: Value, right: Value) -> Value {
        if let Some(object) = entry.as_object_mut() {
            object.insert(self.labels.0.to_owned(), left);
            object.insert(self.labels.1.to_owned(), right);
        }
        entry
    }

    fn render(&self, totals: (usize, usize)) -> Value {
        json!({format!("{}_observations", self.labels.1):totals.1,
            format!("{}_observations", self.labels.0):totals.0,
            "compared":self.compared,"coincide":self.coincide,
            "contract_scope": if self.labels.1 == "aot" {
                "output, termination and error diagnostic codes, arguments and source ranges"
            } else { "output, termination and error diagnostic codes" },
            "exempt_differences":self.exempt,
            "uncontracted_span_or_notice_differences":self.informational.len(),
            "uncontracted_differences":self.informational,
            "unresolved_differences":self.unresolved})
    }
}
