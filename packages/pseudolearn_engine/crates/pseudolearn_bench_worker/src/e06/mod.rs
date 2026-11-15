mod deep_stack;
mod deltas;
mod latency;
mod observer;
mod programs;
mod report;
mod retention;
mod rss;
mod runner;
mod stats;

#[cfg(test)]
mod report_tests;
#[cfg(test)]
mod stats_tests;

pub fn collect() -> Result<(), String> {
    let iterations = std::env::var("E06_ITERATIONS")
        .ok()
        .and_then(|text| text.parse().ok())
        .unwrap_or(30);
    let document = report::build(iterations)?;
    println!(
        "{}",
        serde_json::to_string_pretty(&document).map_err(|error| error.to_string())?
    );
    Ok(())
}

pub fn rss_child(mode: &str) -> Result<(), String> {
    rss::child(mode)
}
