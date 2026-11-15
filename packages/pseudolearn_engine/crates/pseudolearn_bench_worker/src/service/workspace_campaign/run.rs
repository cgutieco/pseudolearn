use crate::service::workspace_campaign::case::{Case, SETTLE_ID};
use crate::service::workspace_campaign::clock::{Clock, nanos_to_millis};
use crate::service::workspace_campaign::comparison::{Outcome, equivalent, merge};
use crate::service::workspace_campaign::observation::{observe, settle};
use crate::service::workspace_campaign::transport::Transport;
use crate::service::workspace_campaign::wire::document_symbols;
use serde_json::Value;

pub struct Samples {
    pub candidate_millis: Vec<f64>,
    pub control_millis: Vec<f64>,
}

fn settled(setup: &[Value]) -> Vec<Value> {
    let mut messages = setup.to_vec();
    messages.push(document_symbols(SETTLE_ID, "app/main"));
    messages
}

fn measure_session<Link: Transport, Timer: Clock>(
    transport: &mut Link,
    clock: &mut Timer,
    setup: &[Value],
    step: &[Value],
) -> Result<(Outcome, u64), String> {
    let prior = settle(transport, &settled(setup))?;
    let observation = observe(transport, clock, step)?;
    let outcome = Outcome {
        published: merge(prior, observation.published),
        response: observation.response,
    };
    Ok((outcome, observation.nanos))
}

pub fn run_case<Link: Transport, Timer: Clock>(
    connect: &mut impl FnMut() -> Result<Link, String>,
    clock: &mut Timer,
    case: &Case,
    sample_count: usize,
) -> Result<Samples, String> {
    let mut samples = Samples {
        candidate_millis: Vec::new(),
        control_millis: Vec::new(),
    };
    for _ in 0..sample_count {
        let (candidate, candidate_nanos) =
            measure_session(&mut connect()?, clock, &case.base_setup, &case.step)?;
        let (control, control_nanos) =
            measure_session(&mut connect()?, clock, &case.cold_setup, &case.cold_step)?;
        equivalent(&candidate, &control)?;
        samples
            .candidate_millis
            .push(nanos_to_millis(candidate_nanos));
        samples.control_millis.push(nanos_to_millis(control_nanos));
    }
    Ok(samples)
}
