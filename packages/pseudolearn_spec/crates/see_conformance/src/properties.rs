use crate::property_scenarios::{self, Scenario};
use see_generators::program::GenerationSeed;
use see_model::{
    Corpus,
    contract::Vocabulary,
    properties::{PropertyBinding, PropertyRun},
};
use serde_json::Value;

pub trait PropertySubject {
    fn declaration(&self) -> &Value;
    fn exchange(&mut self, request: &Value) -> Result<Value, String>;
}

impl PropertySubject for crate::protocol::Session {
    fn declaration(&self) -> &Value {
        &self.hello
    }
    fn exchange(&mut self, request: &Value) -> Result<Value, String> {
        self.request(request)
    }
}

pub struct PropertyContext<'corpus> {
    pub corpus: &'corpus Corpus,
    pub vocabulary: &'corpus Vocabulary,
    pub subject: &'corpus str,
    pub first_sample: u32,
    pub exhaustive: bool,
}

pub fn run(
    binding: &PropertyBinding,
    context: &PropertyContext<'_>,
    subject: &mut impl PropertySubject,
) -> Result<PropertyRun, String> {
    if !crate::property_comparison::available(binding.executor, subject.declaration()) {
        return crate::property_evidence::pending(binding);
    }
    let scenarios = property_scenarios::executions(context.corpus, context.vocabulary)?;
    run_samples(binding, context, subject, &scenarios)
}

fn run_samples(
    binding: &PropertyBinding,
    context: &PropertyContext<'_>,
    subject: &mut impl PropertySubject,
    scenarios: &[Scenario],
) -> Result<PropertyRun, String> {
    let mut report = crate::property_evidence::pending(binding)?;
    report.samples = planned_samples(binding.samples, context.exhaustive, scenarios.len())?;
    for offset in 0..report.samples {
        let sample = context
            .first_sample
            .checked_add(offset)
            .ok_or("SEE-PROPERTY: sample overflow")?;
        let scenario = scenario(binding, context, scenarios, sample)?;
        if let Some((expected, actual)) =
            crate::property_comparison::check(binding.executor, &scenario, subject)?
        {
            report.counterexample = Some(crate::property_evidence::counterexample(
                binding,
                context,
                (sample, &scenario),
                (expected, actual),
            ));
            report.verdict = "incumple".to_owned();
            return Ok(report);
        }
        report.completed = report
            .completed
            .checked_add(1)
            .ok_or("SEE-PROPERTY: count overflow")?;
    }
    report.verdict = "cumple".to_owned();
    Ok(report)
}

fn scenario(
    binding: &PropertyBinding,
    context: &PropertyContext<'_>,
    scenarios: &[Scenario],
    sample: u32,
) -> Result<Scenario, String> {
    let index = usize::try_from(sample).map_err(|error| error.to_string())?;
    if let Some(scenario) = scenarios.get(index) {
        return Ok(scenario.clone());
    }
    property_scenarios::generated(
        GenerationSeed {
            seed: binding.seed,
            sample,
        },
        if sample & 1 == 0 { "es" } else { "en" },
        if sample & 2 == 0 {
            "strict"
        } else {
            "flexible"
        },
        context.vocabulary,
    )
}

fn planned_samples(requested: u32, exhaustive: bool, cases: usize) -> Result<u32, String> {
    let cases = if exhaustive {
        u32::try_from(cases).map_err(|error| error.to_string())?
    } else {
        0
    };
    requested
        .checked_add(cases)
        .ok_or("SEE-PROPERTY: count overflow".to_owned())
}
