use see_model::Corpus;
use serde_json::Value;
use std::collections::BTreeMap;
use std::path::Path;

const PENDING: &str = "pendiente";
const EXEMPT: &str = "exento";
const UNMEASURED: [&str; 2] = [PENDING, EXEMPT];

pub(crate) struct RuleStatus {
    subject: String,
    states: BTreeMap<String, String>,
}

impl RuleStatus {
    pub(crate) fn load(root: &Path, subject: &str) -> Result<Self, String> {
        let Some(path) = crate::bindings::manifest_path(root, subject) else {
            return Ok(Self::from_states(subject, BTreeMap::new()));
        };
        if !path.exists() {
            return Ok(Self::from_states(subject, BTreeMap::new()));
        }
        let conformance = crate::subject_adapters::load_bindings(&path)?;
        Ok(Self::from_states(
            subject,
            conformance
                .vinculos
                .into_iter()
                .map(|binding| (binding.regla, binding.estado))
                .collect(),
        ))
    }

    pub(crate) fn from_states(subject: &str, states: BTreeMap<String, String>) -> Self {
        Self {
            subject: subject.to_owned(),
            states,
        }
    }

    pub(crate) fn is_pending(&self, rule: &str) -> bool {
        self.states.get(rule).is_some_and(|state| state == PENDING)
    }

    pub(crate) fn case_is_measured(&self, corpus: &Corpus, fixture: &Value) -> bool {
        let identity = fixture["specification"].as_str().unwrap_or("");
        let rule = fixture["rule"].as_str().unwrap_or("");
        let Some(specification) = corpus
            .iter()
            .find(|specification| specification.metadata.id == identity)
        else {
            return false;
        };
        if !specification.metadata.sujetos.contains(&self.subject) {
            return false;
        }
        let reference = format!("{identity}@{}#{rule}", specification.metadata.version);
        self.states
            .get(&reference)
            .is_none_or(|state| !UNMEASURED.contains(&state.as_str()))
    }

    pub(crate) fn property_is_pending(&self, corpus: &Corpus, reference: &str) -> bool {
        property_rule(corpus, reference).is_some_and(|rule| self.is_pending(&rule))
    }

    pub(crate) fn property_is_exempt(&self, corpus: &Corpus, reference: &str) -> bool {
        property_rule(corpus, reference)
            .is_some_and(|rule| self.states.get(&rule).is_some_and(|state| state == EXEMPT))
    }
}

fn property_rule(corpus: &Corpus, reference: &str) -> Option<String> {
    let (versioned, property) = reference.split_once('#')?;
    let (identity, _) = versioned.split_once('@')?;
    let specification = corpus
        .iter()
        .find(|specification| specification.metadata.id == identity)?;
    let rule = specification
        .blocks
        .iter()
        .filter(|block| block.kind == "propiedad")
        .find(|block| block.fields.get("id").and_then(Value::as_str) == Some(property))?
        .fields
        .get("regla")?
        .as_str()?;
    Some(format!("{versioned}#{rule}"))
}
