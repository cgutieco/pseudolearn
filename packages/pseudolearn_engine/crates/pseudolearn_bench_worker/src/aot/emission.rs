use crate::corpus::CorpusCase;
use pseudolearn_api::{
    BenchmarkObject, ExecuteRequest, build_benchmark_object, conformance_build_request,
};
use std::time::Instant;

const REPETITIONS: usize = 30;

pub struct Emission {
    pub object: BenchmarkObject,
    pub milliseconds: f64,
}

pub fn measure(case: &CorpusCase) -> Result<Emission, String> {
    let request = conformance_build_request(&ExecuteRequest {
        program: case.source.clone(),
        ..ExecuteRequest::default()
    });
    let mut timings = Vec::new();
    let mut last = None;
    for _ in 0..REPETITIONS {
        let started = Instant::now();
        let object = build_benchmark_object(&request)
            .map_err(|failure| format!("{}: {failure:?}", case.name))?;
        timings.push(started.elapsed().as_secs_f64() * 1000.0);
        last = Some(object);
    }
    Ok(Emission {
        object: last.ok_or("No emission was measured")?,
        milliseconds: super::statistics::median(&timings),
    })
}
