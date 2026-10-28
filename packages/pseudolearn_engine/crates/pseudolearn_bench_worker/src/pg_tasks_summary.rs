use crate::pg_tasks_agendas::Agenda;
use serde_json::{Value, json};
use std::collections::BTreeMap;

#[derive(Default)]
pub struct Summary {
    per_family: BTreeMap<u64, u64>,
    divergences: Vec<(u64, Vec<String>)>,
}

impl Summary {
    pub fn record(&mut self, agenda: &Agenda, found: Vec<String>) {
        let count = self.per_family.entry(agenda.family).or_insert(0);
        *count = count.saturating_add(1);
        if !found.is_empty() {
            self.divergences.push((agenda.seed, found));
        }
    }

    pub fn total(&self) -> u64 {
        self.per_family
            .values()
            .fold(0, |sum, count| sum.saturating_add(*count))
    }

    pub fn divergent_seeds(&self) -> Vec<u64> {
        self.divergences.iter().map(|(seed, _)| *seed).collect()
    }

    pub fn document(&self) -> Value {
        let details: Vec<Value> = self
            .divergences
            .iter()
            .map(|(seed, found)| json!({"seed": seed, "differences": found}))
            .collect();
        json!({
            "total": self.total(),
            "per_family": self.per_family,
            "divergences": details,
        })
    }
}
