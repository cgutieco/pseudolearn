use serde_json::{Value, json};

use super::programs::awfy_compiled;
use super::{deep_stack, deltas, latency, observer, retention, rss};

fn selected(name: &str) -> bool {
    std::env::var("E06_METRICS").is_ok_and(|list| list.split(',').any(|entry| entry == name))
        || std::env::var("E06_METRICS").is_err()
}

pub const EXPECTED_METRICS: usize = 8;

pub fn all_passed(metrics: &[Value]) -> bool {
    metrics.len() == EXPECTED_METRICS
        && metrics
            .iter()
            .all(|metric| metric.get("passed").and_then(Value::as_bool) == Some(true))
}

pub fn build(iterations: usize) -> Result<Value, String> {
    let cases = awfy_compiled()?;
    let mut metrics = Vec::new();
    if selected("observer") {
        metrics.push(observer::measure(&cases, iterations)?);
    }
    if selected("deltas") {
        let (overhead, independence) = deltas::measure(iterations)?;
        metrics.push(overhead);
        metrics.push(independence);
    }
    if selected("stack") {
        metrics.push(deep_stack::measure()?);
    }
    if selected("step") {
        metrics.push(latency::measure_step(&cases)?);
    }
    if selected("rewind") {
        metrics.push(latency::measure_rewind(&cases)?);
    }
    if selected("retention") {
        metrics.push(retention::measure()?);
    }
    if selected("rss") {
        metrics.push(rss::measure()?);
    }
    let all_passed = all_passed(&metrics);
    Ok(
        json!({"experiment":"E-06","status":"measured","all_passed":all_passed,
        "protocol":{"iterations":iterations,"processes":1,
            "retentionStatements":retention::target_statements()},
        "metrics":metrics}),
    )
}
