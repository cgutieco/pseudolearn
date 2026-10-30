use crate::service::statistics::summarize;
use crate::service::workspace_campaign::observation::Published;
use crate::service::workspace_campaign::scenario::Scenario;
use serde_json::Value;

pub struct Outcome {
    pub published: Published,
    pub response: Value,
}

pub fn merge(mut setup: Published, step: Published) -> Published {
    setup.extend(step);
    setup
}

pub fn equivalent(candidate: &Outcome, control: &Outcome) -> Result<(), String> {
    for (uri, diagnostics) in &control.published {
        match candidate.published.get(uri) {
            None => return Err(format!("diagnostics for {uri} were never published")),
            Some(published) if published != diagnostics => {
                return Err(format!(
                    "diagnostics for {uri} differ from the cold control"
                ));
            }
            Some(_) => {}
        }
    }
    if let Some(extra) = candidate
        .published
        .keys()
        .find(|uri| !control.published.contains_key(*uri))
    {
        return Err(format!("unexpected diagnostics for {extra}"));
    }
    if candidate.response != control.response {
        return Err("the barrier response differs from the cold control".to_owned());
    }
    Ok(())
}

pub fn p95(samples: &[f64]) -> Option<f64> {
    summarize(samples).map(|summary| summary.p95)
}

pub fn within_threshold(scenario: Scenario, p95_millis: f64) -> Option<bool> {
    scenario
        .threshold_millis()
        .map(|threshold| p95_millis <= threshold)
}
