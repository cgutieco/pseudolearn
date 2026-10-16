use std::time::Instant;

use pseudolearn_vm::{ChangeBuffer, TwinMode, machine_change_buffer, machine_events};
use serde_json::{Value, json};

use super::programs::{CompiledCase, depth_case, storage_case};
use super::runner::{machine_for, nanoseconds, run_to_end};
use super::stats::{count_to_float, median, regression_slope};

pub const DEPTHS: [usize; 3] = [1_000, 10_000, 100_000];

struct Run {
    nanoseconds: f64,
    events: usize,
}

#[derive(Default)]
struct DeltaSink {
    scalars: Vec<(u16, u64)>,
    references: Vec<(u16, u32)>,
    scalar_offset: usize,
    reference_offset: usize,
}

impl DeltaSink {
    fn consume(&mut self, buffer: &ChangeBuffer) {
        if buffer.modified_scalars.len() < self.scalar_offset {
            self.scalar_offset = 0;
        }
        if buffer.modified_references.len() < self.reference_offset {
            self.reference_offset = 0;
        }
        if let Some(tail) = buffer.modified_scalars.get(self.scalar_offset..) {
            self.scalars.extend_from_slice(tail);
        }
        if let Some(tail) = buffer.modified_references.get(self.reference_offset..) {
            self.references.extend_from_slice(tail);
        }
        self.scalar_offset = buffer.modified_scalars.len();
        self.reference_offset = buffer.modified_references.len();
    }
}

fn probed_run(case: &CompiledCase, capture: bool) -> Result<Run, String> {
    let mut machine = machine_for(case, TwinMode::Probed)?;
    let mut seen = 0_usize;
    let mut sink = DeltaSink::default();
    let started = Instant::now();
    run_to_end(&mut machine, |current, _| {
        let count = machine_events(current).len();
        if count > seen {
            seen = count;
            if capture {
                sink.consume(machine_change_buffer(current));
            }
        }
        Ok(())
    })?;
    let elapsed = nanoseconds(started);
    std::hint::black_box(&sink);
    Ok(Run {
        nanoseconds: elapsed,
        events: seen,
    })
}

struct Comparison {
    ratio: f64,
    per_event: Vec<f64>,
    document: Value,
}

fn compare(case: &CompiledCase, iterations: usize) -> Result<Comparison, String> {
    let mut baseline = Vec::new();
    let mut with_deltas = Vec::new();
    let mut per_event = Vec::new();
    for iteration in 0..iterations {
        let delta_first = !iteration.is_multiple_of(2);
        let first = probed_run(case, delta_first)?;
        let second = probed_run(case, !delta_first)?;
        let (without, with) = if delta_first {
            (second, first)
        } else {
            (first, second)
        };
        per_event
            .push((with.nanoseconds - without.nanoseconds) / count_to_float(with.events.max(1)));
        baseline.push(without.nanoseconds);
        with_deltas.push(with.nanoseconds);
    }
    let ratio = median(&with_deltas) / median(&baseline);
    let document = json!({"workload":case.name,"ratio":ratio,
        "baselineNanoseconds":baseline,"deltaNanoseconds":with_deltas,"deltaNanosecondsPerEvent":per_event});
    Ok(Comparison {
        ratio,
        per_event,
        document,
    })
}

pub fn measure(iterations: usize) -> Result<(Value, Value), String> {
    let mut cases = Vec::new();
    for depth in DEPTHS {
        cases.push(depth_case(depth)?);
    }
    cases.push(named_case("sieve")?);
    cases.push(storage_case(6)?);
    let mut documents = Vec::new();
    let mut worst = 0.0_f64;
    let mut points = Vec::new();
    for (position, case) in cases.iter().enumerate() {
        let comparison = compare(case, iterations)?;
        worst = worst.max(comparison.ratio);
        if let Some(depth) = DEPTHS.get(position) {
            for sample in &comparison.per_event {
                points.push((count_to_float(*depth), *sample));
            }
        }
        documents.push(comparison.document);
    }
    let fitted = regression_slope(&points);
    let overhead = json!({"id":"E06-DELTA","name":"state delta overhead over events alone",
        "criterion":"every workload <= 1.3x","value":worst,"passed":worst <= 1.3,
        "workloads":documents});
    let independence = json!({"id":"E06-DEPTH","name":"per-event cost independent of depth",
        "criterion":"slope of the delta cost per event (paired with-minus-without) against depth is indistinguishable from zero at 95%",
        "slopeNanosecondsPerFrame":fitted.slope,"margin":fitted.margin,
        "passed":fitted.is_indistinguishable_from_zero()});
    Ok((overhead, independence))
}

fn named_case(name: &str) -> Result<CompiledCase, String> {
    let source = crate::corpus::awfy_cases()?
        .into_iter()
        .find(|case| case.name == name)
        .ok_or("Missing workload")?;
    super::programs::compile_case(&source.name, &source.source, source.inputs)
}
